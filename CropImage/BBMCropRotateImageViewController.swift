//
//  ViewController.swift
//  CropImage
//
//  Created by ea on 11/20/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

let imageName = "Image3"

class BBMCropRotateImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @objc public var image: UIImage! {
        didSet {
            self.imageView.image = image
        }
    }
    var originalImage: UIImage?
    let imageView = CroppableImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalImage = UIImage(named: imageName)
        self.image = UIImage(named: imageName)
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.image = self.image
    }
    
    func setupUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.scrollView.delegate = self
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.isUserInteractionEnabled = false
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.isHidden = true
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isUserInteractionEnabled = true
        self.view.addSubview(self.imageView)
        self.view.sendSubview(toBack: self.imageView)
    }
    
    @objc func zoomImage() {
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
    }
    
    // MARK: User Interactions
    @IBAction func rotateButtonTouched(_ sender: Any) {
        self.imageView.rotate()
    }
    
    @IBAction func doneButtonTouched(_ sender: Any) {
        self.imageView.cropImage()
    }
    
    @IBAction func cropButtonTouched(_ sender: Any) {
        self.imageView.cropImage()
    }
    
    @IBAction func resetButtonTouched(_ sender: Any) {
        self.image = self.originalImage
        self.imageView.resetState()
    }
    
    @IBAction func cancelButtonTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension BBMCropRotateImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
