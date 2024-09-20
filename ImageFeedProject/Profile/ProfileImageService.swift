//
//  ProfileImageService.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 04.04.2024.
//

import Foundation
enum ProfileImageError: Error {
    case other(Error)
    case unauthorized
}

final class ProfileImageService: ProfileImageServiceProtocol {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private(set) var avatarURL: String?
    static let shared = ProfileImageService()
    private init() {}
    
    let token = OAuth2TokenStorage().token
    
    func makeProfileRequest(withToken token: String )-> URLRequest {
        let url = URL(string: "https://api.unsplash.com/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
        
        enum CodingKeys: String,CodingKey {
            case small = "small"
            case medium = "medium"
            case large = "large"
        }
    }
    
    struct UserResult: Codable {
        let profileImage: ProfileImage
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    func fetchProfileImageURL(username: String,  completion: @escaping (Result<String,Error>) -> Void) {
        guard let token = token else { return }
        let request = makeProfileRequest(withToken: token)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(ProfileImageError.other(error)))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(ProfileImageError.other(URLError(.badServerResponse))))
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    if httpResponse.statusCode == 401 {
                        completion(.failure(ProfileImageError.unauthorized))
                    } else {
                        completion(.failure(ProfileImageError.other(URLError(.badServerResponse))))
                    }
                    return
                }
                guard let data = data else {
                    completion(.failure(ProfileImageError.other(URLError(.cannotParseResponse))))
                    return
                }
                
                do {
                    let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                    //print(String(data: data, encoding: .utf8) ?? "No valid data")
                    
                    let smallImageURL = userResult.profileImage.small
                    self.avatarURL = smallImageURL
                    print("Small Image URL1: \(smallImageURL)")
                    completion(.success(smallImageURL))
                    NotificationCenter.default
                        .post(name: ProfileImageService.didChangeNotification,
                              object: self,
                              userInfo: ["URL" : smallImageURL])
                    
                } catch {
                    print("Ошибка декодирования \(error)")
                    completion(.failure(ProfileImageError.other(error)))
                }
                
            }
            
        }
        task.resume()
        
    }
}



