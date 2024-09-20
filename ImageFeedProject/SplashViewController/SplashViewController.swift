//
//  SplashViewController.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 28.12.2023.
//

import UIKit
import ProgressHUD

class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    
    private let profileImageService = ProfileImageService.shared
    
    private let token = OAuth2TokenStorage().token
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    
    private(set) var profileImageURL: String?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oauth2Service.authToken != nil {
            guard let token = token else { return }
            
            switchToTabBarController()
            fetchProfile(token)
            
            print("Small Image URL: \(String(describing: ProfileImageService.shared.avatarURL))")
            
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
                    
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)")}
            
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = token else { return }
        fetchProfile(token)
        
    }
    
    private func fetchProfile(_ token: String) {
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
            self.profileService.fetchProfile(token) { [weak self] result  in
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    switchToTabBarController()
                    profileImageService.fetchProfileImageURL(username: profile.username) { imageResult in
                        
                        DispatchQueue.main.async {
                            switch imageResult {
                            case .success(let imageURL):
                                
                                print("URL аватарки: \(imageURL)")
                            case .failure(let error):
                                print("Oшибка получения URL аватарки: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Ошибка при загрузке профился с Unsplash: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            print("Результат запроса токена: \(result)")
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let token):
                OAuth2TokenStorage().token = token
                vc.dismiss(animated: true) {
                    self?.fetchProfile(token)
                }
            case .failure(let error):
                print("Ошибка получения токена: \(error.localizedDescription)")
                vc.dismiss(animated: true)
            }
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.switchToTabBarController()
                    UIBlockingProgressHUD.dismiss()
                case . failure:
                    UIBlockingProgressHUD.dismiss()
                    break
                }
            }
        }
    }
}



