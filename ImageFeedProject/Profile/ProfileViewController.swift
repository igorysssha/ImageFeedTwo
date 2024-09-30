import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let profileService = ProfileService.shared
    
    private let token = OAuth2TokenStorage().token
    
    private lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImageView()
        return avatarImage
    }()
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private lazy var loginNameLabel: UILabel = {
        let nameLabel = UILabel()
        return nameLabel
    }()
    private lazy var desriptionLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private  lazy var logoutButton: UIButton = {
        let button = UIButton()
        return button
    }()
    @objc func didTapLogoutButton() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        if let profile = profileService.profile {
            updateUIWithProfile(profile)
        }
        setupLabels()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.clipsToBounds = true
    }
    
    private func updateAvatar() {
        guard
            let smallImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: smallImageURL)
        else { return }
        
        avatarImageView.kf.setImage(with: url,
                                    placeholder: UIImage(named: "Photo")) { result in
            switch result {
            case .success(let value):
                print("Изображение загружено: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupLabels() {
        
        let safeArea = view.safeAreaLayoutGuide
        
        let avatarImageView = self.avatarImageView
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: safeArea.topAnchor , constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        nameLabel.textColor = .ypWhite
        view.addSubview(nameLabel)
        self.nameLabel = nameLabel
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16)
        ])
        
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        
        loginNameLabel.textColor = .ypGray
        view.addSubview(loginNameLabel)
        self.loginNameLabel = loginNameLabel
        
        NSLayoutConstraint.activate([
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
       
        let desriptionLabel = UILabel()
        desriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        desriptionLabel.font = UIFont.systemFont(ofSize: 13)
        
        desriptionLabel.textColor = .ypWhite
        view.addSubview(desriptionLabel)
        self.desriptionLabel = desriptionLabel
        
        NSLayoutConstraint.activate([
            desriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            desriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor)
        ])
        
        guard let exitImage = UIImage(named: "Exit") else {
            assertionFailure("Не удалось загрузить изображение 'Exit'")
            return
        }
        let logoutButton = UIButton.systemButton(with: exitImage,
                                                 target: self,
                                                 action: #selector(Self.didTapLogoutButton))
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.tintColor = .ypRed
        
        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func updateUIWithProfile(_ profile: Profile) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.nameLabel.text = profile.name
            self.loginNameLabel.text = profile.loginName
            self.desriptionLabel.text = profile.bio
        }
    }
    
}

