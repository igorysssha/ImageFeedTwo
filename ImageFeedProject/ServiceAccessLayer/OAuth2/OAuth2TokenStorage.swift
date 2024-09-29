import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let tokenKey = "token"
    
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(
                    token,
                    forKey: tokenKey,
                    withAccessibility: .afterFirstUnlockThisDeviceOnly
                )
                if !isSuccess {
                    print("Ошибка сохранения токена в Keychain")
                }
            } else {
                let isSuccess = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if !isSuccess {
                    print("Ошибка удаления токена из Keychain")
                }
            }
        }
    }
}
