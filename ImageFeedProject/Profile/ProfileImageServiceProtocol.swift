//
//  ProfileImageServiceProtocol.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 07.04.2024.
//

import Foundation

protocol ProfileImageServiceProtocol {
     //var networkClient: NetworkClientProtocol { get }

     func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void)
 }
