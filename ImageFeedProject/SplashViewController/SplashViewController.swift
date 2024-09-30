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
    
    private var isFetchingProfile = false
    
    private lazy var splashScreenLogoImage: UIImageView = {
        let splashScreenLogo = UIImageView()
        return splashScreenLogo
    }()
    
    //private let token = OAuth2TokenStorage().token
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    //private let oauth2Service = OAuth2Service.shared
    
    private(set) var profileImageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupScreen()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = OAuth2TokenStorage().token {
            // Если токен есть, загружаем профиль
            fetchProfile(token)
        } else {
            // Иначе переходим к экрану авторизации
            showAuthViewController()
        }
    }
    
    private func setupScreen() {
        let safeArea = view.safeAreaLayoutGuide
        let splashScreenLogoImage = self.splashScreenLogoImage
        splashScreenLogoImage.image = UIImage(named: "splash_screen_logo")
        
        splashScreenLogoImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashScreenLogoImage)
        NSLayoutConstraint.activate([
            splashScreenLogoImage.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            splashScreenLogoImage.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
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
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти Auth")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
}


extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String) {
        // Сохраняем токен
        OAuth2TokenStorage().token = token
        // Закрываем AuthViewController
        vc.dismiss(animated: true) {
            // Загружаем профиль
            self.fetchProfile(token)
        }
    }
}

extension SplashViewController {
    private func fetchProfile(_ token: String) {
        guard !isFetchingProfile else { return }
        isFetchingProfile = true
        
        // Показываем индикатор загрузки на главном потоке
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            // Скрываем индикатор загрузки на главном потоке
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
            }
            
            switch result {
            case .success(let profile):
                self.fetchProfileImageURL(username: profile.username)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Не удалось загрузить профиль")
                }
                print("[SplashViewController]: Ошибка при загрузке профиля - \(error.localizedDescription)")
            }
        }
    }

    
    private func fetchProfileImageURL(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imageURL):
                self.switchToTabBarController()
                print("URL аватарки: \(imageURL)")
            case .failure(let error):
                self.showErrorAlert(message: "Не удалось загрузить аватарку")
                print("[SplashViewController]: Ошибка получения URL аватарки - \(error.localizedDescription)")
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        // Проверяем, что представление загружено и находится в окне
        guard isViewLoaded, view.window != nil else {
            print("[SplashViewController]: Представление не в иерархии окон, алерт не будет показан")
            return
        }
        
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
}






