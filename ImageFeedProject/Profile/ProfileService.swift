//
//  ProfileService.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 11.03.2024.
//

import Foundation

enum ProfileError: Error {
    case unauthorized
    case other(Error)
}

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    private init() {}
    private(set) var profile: Profile?
    
    let token = OAuth2TokenStorage().token
    
    func makeProfileRequest(withToken token: String )-> URLRequest {
        let url = URL(string: "https://api.unsplash.com/me")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        let request = makeProfileRequest(withToken: token)
        
        let task = URLSession.shared.dataTask(with: request) { data, response , error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(ProfileError.other(error)))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(ProfileError.other(URLError(.badServerResponse))))
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    if httpResponse.statusCode == 401 {
                        completion(.failure(ProfileError.unauthorized))
                    } else {
                        completion(.failure(ProfileError.other(URLError(.badServerResponse))))
                    }
                    return
                }
                guard let data = data else {
                    completion(.failure(ProfileError.other(URLError(.cannotParseResponse))))
                    return
                }
                do {
                    let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                    let profile = Profile(from: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                } catch {
                    completion(.failure(ProfileError.other(error)))
                }
            }
        }
        task.resume()
    }
}
struct ProfileResult: Codable {
    let id: String
    let updatedAt: String
    let username: String
    let firstName: String?
    let lastName: String?
    let twitterUsername: String?
    let portfolioURL: String?
    let bio: String?
    let location: String?
    let totalLikes: Int
    let totalPhotos: Int
    let totalCollections: Int
    let followedByUser: Bool
    let downloads: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case updatedAt = "updated_at"
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case twitterUsername = "twitter_username"
        case portfolioURL = "portfolio_url"
        case bio
        case location
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case followedByUser = "followed_by_user"
        case downloads
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
    
    init(from profileResult: ProfileResult) {
        
        self.username = profileResult.username
        self.name = "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")"
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio ?? ""
        
    }
}



