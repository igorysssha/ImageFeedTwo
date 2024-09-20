//
//  OAuth2TokenStorage.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 28.12.2023.
//

import Foundation

final class OAuth2TokenStorage {
    
    private let tokenKey = "token"
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
