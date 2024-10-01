import Foundation

enum ProfileError: Error {
    case unauthorized
    case other(Error)
}

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    private init() {}
    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    
    private var token: String? {
        return OAuth2TokenStorage().token
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeProfileRequest(withToken: token) else {
            completion(.failure(ProfileError.other(URLError(.badURL))))
            return
        }
        
        // Отменяем предыдущую задачу, если она есть
        task?.cancel()
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    // Задача была отменена, ничего не делаем
                    return
                } else if let networkError = error as? NetworkError,
                          case .httpStatusCode(let statusCode) = networkError,
                          statusCode == 401 {
                    print("[ProfileService]: Unauthorized - код ошибки \(statusCode)")
                    completion(.failure(ProfileError.unauthorized))
                } else {
                    print("[ProfileService]: Ошибка получения профиля - \(error.localizedDescription)")
                    completion(.failure(ProfileError.other(error)))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(withToken token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
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
