import Foundation

enum ProfileImageError: Error {
    case other(Error)
    case unauthorized
    case invalidURL
    case missingToken
}

final class ProfileImageService: ProfileImageServiceProtocol {
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private(set) var avatarURL: String?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var token: String? {
        return OAuth2TokenStorage().token
    }
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = token else {
            completion(.failure(ProfileImageError.missingToken))
            return
        }
        
        guard let request = makeProfileRequest(username: username, token: token) else {
            completion(.failure(ProfileImageError.invalidURL))
            return
        }
        
        // Отменяем предыдущую задачу, если она есть
        task?.cancel()
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                let smallImageURL = userResult.profileImage.medium
                self.avatarURL = smallImageURL
                completion(.success(smallImageURL))
                
                
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": smallImageURL])
            case .failure(let error):
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    // Задача была отменена, ничего не делаем
                    return
                } else if let networkError = error as? NetworkError,
                          case .httpStatusCode(let statusCode) = networkError,
                          statusCode == 401 {
                    print("[ProfileImageService]: Unauthorized - код ошибки \(statusCode)")
                    completion(.failure(ProfileImageError.unauthorized))
                } else {
                    print("[ProfileImageService]: Ошибка получения аватарки - \(error.localizedDescription)")
                    completion(.failure(ProfileImageError.other(error)))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(username: String, token: String) -> URLRequest? {
        let urlString = "https://api.unsplash.com/users/\(username)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private init() {}
    
    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }
    
    struct UserResult: Codable {
        let profileImage: ProfileImage
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
}
