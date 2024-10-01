//
//  AuthViewController.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 21.12.2023.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    
    let ShowWebViewIdentifer = "ShowWebView"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewIdentifer {
            guard
                let webViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewIdentifer)") }
            webViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    private func fetchOAuthToken(_ code: String) {
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let token):
                    // Успешно получили токен, уведомляем делегата
                    self.delegate?.authViewController(self, didAuthenticateWithToken: token)
                case .failure(let error):
                    // Произошла ошибка, показываем алерт
                    self.showAuthErrorAlert()
                    print("[AuthViewController]: Ошибка авторизации - \(error.localizedDescription)")
                }
            }
        }
    }
    private func showAuthErrorAlert() {
            let alert = UIAlertController(
                title: "Что-то пошло не так(",
                message: "Не удалось войти в систему",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true)
        }
}
extension AuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthencateWithCode code: String) {
        // Закрываем WebViewController
        vc.dismiss(animated: true)
        // Запускаем получение OAuth токена
        fetchOAuthToken(code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

