//
//  SingleImageViewController.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 23.11.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage!
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}


