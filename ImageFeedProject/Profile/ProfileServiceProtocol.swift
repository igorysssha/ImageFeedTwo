//
//  ProfileServiceProtocol.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 22.04.2024.
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}
