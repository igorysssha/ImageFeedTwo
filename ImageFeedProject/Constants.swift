//
//  Constants.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 20.12.2023.
//

import Foundation

let AccessKey = "jVoi2R_qE9PMAbX9XiUXuI2zN97x-4Og-IQx4sLowRU"
let SecretKey = "Tf3ybkuK1vqhPxq4wfI1al-pQhBfxk0dhPZIZn7qKug"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseURL: URL = {
    guard let url = URL(string: "https://api.unsplash.com") else {
        fatalError("Не удалось создать URL из строки https://api.unsplash.com")
    }
    return url
}()

