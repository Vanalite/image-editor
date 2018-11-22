//
//  ViewController.swift
//  CropImage
//
//  Created by ea on 11/20/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

let imageName = "Image2"

class BBMCropRotateImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageContainerView: UIView!
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
        // Changed in real app
        self.image = UIImage(named: imageName)
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.image = self.image
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.imageView.resetState()
    }
    
    func setupUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupScrollView()
        self.setupImageView()
    }
    
    func setupScrollView() {
        self.scrollView.delegate = self
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.isUserInteractionEnabled = false
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.isHidden = true
    }
    
    func setupImageView() {
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isUserInteractionEnabled = true
        self.imageContainerView.addSubview(self.imageView)
        self.view.sendSubview(toBack: self.imageContainerView)
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
        self.imageView.showGridView()
    }
    
    @IBAction func cancelButtonTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.imageView.hideGridView()
    }
}

extension BBMCropRotateImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
