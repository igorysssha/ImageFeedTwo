//
//  OAuth2Service.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 28.12.2023.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private(set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        var components =  URLComponents(string: "https://unsplash.com/oauth/token")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = components?.url else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Выполнение сетевого запроса
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let responseBody):
                    let authToken = responseBody.accessToken
                    self.authToken = authToken
                    completion(.success(authToken))
                case .failure(let error):
                    print("[OAuth2Service]: Ошибка получения токена - \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private struct OAuthTokenResponseBody: Codable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createAt: Int
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createAt = "created_at"
        }
    }
}

// MARK: - HTTP Request

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = DefaultBaseURL
    ) -> URLRequest? {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            print("Не удалось создать URL из пути \(path)")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}


extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            let fulfillCompletionOnMainThread: (Result<Data,Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            if let data = data,
               let response = response as? HTTPURLResponse {
                if 200 ..< 300 ~= response.statusCode {
                    fulfillCompletionOnMainThread(.success(data))
                } else {
                    let error = NetworkError.httpStatusCode(response.statusCode)
                    print("[dataTask]: NetworkError - код ошибки \(response.statusCode)")
                    fulfillCompletionOnMainThread(.failure(error))
                }
            } else if let error = error {
                let error = NetworkError.urlRequestError(error)
                print("[dataTask]: URLRequestError - \(error.localizedDescription)")
                fulfillCompletionOnMainThread(.failure(error))
            } else {
                let error = NetworkError.urlSessionError
                print("[dataTask]: URLSessionError - не удалось получить ответ от сервера")
                fulfillCompletionOnMainThread(.failure(error))
            }
        }
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(object))
                    }
                } catch {
                    print("[objectTask]: DecodingError - \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("[objectTask]: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}



