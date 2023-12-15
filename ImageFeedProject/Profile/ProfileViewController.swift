//
//  ProfileViewController.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 21.11.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    
    private var avatarImageView: UIImageView!
    weak var nameLabel: UILabel!
    weak var loginNameLabel: UILabel!
    weak var desriptionLabel: UILabel!
    
    weak var logoutButton: UIButton!
    @objc func didTapLogoutButton() {
        
    }
    
    
    override func viewDidLoad() {
     super.viewDidLoad()
        // safeArea констрейнт
        let safeArea = view.safeAreaLayoutGuide
        // Изображение Аватара and constraint
        let avatarImage = UIImage(named: "Photo")
        let avatarImageView = UIImageView(image: avatarImage)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: safeArea.topAnchor , constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
            
        ])
        
       
        
        
        // label с именем and constraints
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        view.addSubview(nameLabel)
        self.nameLabel = nameLabel
        
        NSLayoutConstraint.activate([
            nameLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20)
            
        ])
        
        // loginName label and constraints
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.textColor = .white
        view.addSubview(loginNameLabel)
        self.loginNameLabel = loginNameLabel
        
        NSLayoutConstraint.activate([
            loginNameLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
        
        //desriptionLabel and constraints
        let desriptionLabel = UILabel()
        desriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        desriptionLabel.font = UIFont.systemFont(ofSize: 13)
        desriptionLabel.text = "Hello World!"
        desriptionLabel.textColor = .white
        view.addSubview(desriptionLabel)
        self.desriptionLabel = desriptionLabel
        
        NSLayoutConstraint.activate([
            desriptionLabel.bottomAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 20),
            desriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor)
        ])
        
        // logout button and constraint
        let logoutButton = UIButton.systemButton(with: UIImage(named: "Exit")!,
                                                 target: self,
                                                 action: #selector(Self.didTapLogoutButton))
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.tintColor = .red
        
        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
        
    }
    
}
