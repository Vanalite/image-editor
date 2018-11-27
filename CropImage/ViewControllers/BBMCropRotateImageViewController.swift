//
//  ViewController.swift
//  Alaska
//
//  Created by ea on 11/20/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

class BBMCropRotateImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var customFrameButton: UIButton!
    let frameActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    @objc public var image: UIImage! {
        didSet {
            self.imageView.image = image
        }
    }
    var originalImage: UIImage?
    let imageView = CroppableImageView()
    var fixCropFrame = FixedRatioFrame.none;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalImage = self.image
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.image = self.image
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imageView.resetState()
    }
    
    func setupUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupScrollView()
        self.setupImageView()
        self.setupFrameActionSheet()
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
    
    func setupFrameActionSheet() {
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.frameActionSheet.dismiss(animated: true, completion: nil)
            self.customFrameButton.isHighlighted = false
        }
        self.frameActionSheet.addAction(cancel)

        let original = UIAlertAction(title: "Original", style: .default) { (action) in
            self.fixCropFrame = .original
            self.frameActionSheet.dismiss(animated: true, completion: nil)
        }
        self.frameActionSheet.addAction(original)
        
        let fitToScreen = UIAlertAction(title: "Fit to screen", style: .default) { (action) in
            self.frameActionSheet.dismiss(animated: true, completion: nil)
        }
        self.frameActionSheet.addAction(fitToScreen)

        let square = UIAlertAction(title: "Square", style: .default) { (action) in
            self.frameActionSheet.dismiss(animated: true, completion: nil)
            self.imageView.fixCropFrame(fixRatio: .square)
        }
        self.frameActionSheet.addAction(square)
        
        let twoThree = UIAlertAction(title: "2:3", style: .default) { (action) in
            self.frameActionSheet.dismiss(animated: true, completion: nil)
            self.imageView.fixCropFrame(fixRatio: .twoThree)
        }
        self.frameActionSheet.addAction(twoThree)
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
        self.image = self.imageView.image
        if let vc = self.navigationController?.viewControllers.first as? ImagePreviewViewController {
            vc.image = self.image
        }
        self.navigationController?.popViewController(animated: true)
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
    
    @IBAction func customFrameButtonTouched(_ sender: Any) {
        if (self.fixCropFrame != .none) {
            self.fixCropFrame = .none
            self.customFrameButton.isHighlighted = false
        } else {
            self.customFrameButton.isHighlighted = true
            self.present(self.frameActionSheet, animated: false, completion: nil)
        }
    }

}

extension BBMCropRotateImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
