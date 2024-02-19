//
//  SingleImageViewController.swift
//  ImageFeedProject
//
//  Created by  Игорь Килеев on 23.11.2023.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBOutlet private var shareButton: NSLayoutConstraint!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        imageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
    }
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: UIButton) {
        let share = UIActivityViewController(
            activityItems: [image!],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale,max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
}
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
            let height = scrollView.bounds.size.height
            
            let contentWidth = scrollView.contentSize.width
            let contentHeight = scrollView.contentSize.height
            
            let horizontalInset = max(0, (width - contentWidth) / 2)
            let verticalInset = max(0, (height - contentHeight) / 2)
            
            scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

