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
    
    let icRatioImgName = "icRatio"
    let icRatioSelectedImgName = "icRatioSelected"
    let frameActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let touchInset: CGFloat = 30
    
    @objc public var image: UIImage! {
        didSet {
            self.imageView.image = image
        }
    }
    var originalImage: UIImage?
    let imageView = CroppableImageView()
    var fixedRatioFrame = FixedRatioFrame.none;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalImage = self.image
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.image = self.image
        self.imageView.resetState()
    }

    private func setupGesture() {
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(self.handlePanMove(sender:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        self.imageContainerView.addGestureRecognizer(panRecognizer)
    }
    
    @objc private func handlePanMove(sender: UIPanGestureRecognizer) {
        let frame = self.imageView.frame.insetBy(dx: -touchInset, dy: -touchInset)
        let locationInContainerPoint = sender.location(in: self.imageContainerView)
        if sender.state == .began && !frame.contains(locationInContainerPoint) {
            return
        }
        self.imageView.handlePanMove(sender: sender)
    }
    
    func setupUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupScrollView()
        self.setupImageView()
        self.setupGesture()
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
        let imageContentView = UIView(frame: CGRect(origin: .zero, size: self.imageContainerView.frame.size))
        imageContentView.frame = imageContentView.frame.insetBy(dx: 10, dy: 10)
        imageContentView.addSubview(self.imageView)
        self.imageContainerView.addSubview(imageContentView)
        self.view.sendSubview(toBack: self.imageContainerView)
    }
    
    func setupFrameActionSheet() {
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.frameActionSheet.dismiss(animated: true, completion: nil)
        }
        self.frameActionSheet.addAction(cancel)

        let original = UIAlertAction(title: "Original", style: .default) { (action) in
            self.selectFixRatio(.original)
        }
        self.frameActionSheet.addAction(original)
        
        let fitToScreen = UIAlertAction(title: "Fit to screen", style: .default) { (action) in
            self.selectFixRatio(.fitToScreen)
        }
        self.frameActionSheet.addAction(fitToScreen)

        let square = UIAlertAction(title: "Square", style: .default) { (action) in
            self.selectFixRatio(.square)
        }
        self.frameActionSheet.addAction(square)
        
        let twoThird = UIAlertAction(title: "2:3", style: .default) { (action) in
            self.selectFixRatio(.twoThird)
        }
        self.frameActionSheet.addAction(twoThird)
        
        let threeFifth = UIAlertAction(title: "3:5", style: .default) { (action) in
            self.selectFixRatio(.threeFifth)
        }
        self.frameActionSheet.addAction(threeFifth)
        
        let threeFourth = UIAlertAction(title: "3:4", style: .default) { (action) in
            self.selectFixRatio(.threeFourth)
        }
        self.frameActionSheet.addAction(threeFourth)
        
        let fourFifth = UIAlertAction(title: "4:5", style: .default) { (action) in
            self.selectFixRatio(.fourFifth)
        }
        self.frameActionSheet.addAction(fourFifth)
        
        let fiveSeventh = UIAlertAction(title: "5:7", style: .default) { (action) in
            self.selectFixRatio(.fiveSeventh)
        }
        self.frameActionSheet.addAction(fiveSeventh)
    }
    
    private func selectFixRatio(_ fixRatio: FixedRatioFrame) {
        self.fixedRatioFrame = fixRatio
        self.customFrameButton.setImage(UIImage(named: icRatioSelectedImgName), for: .normal)
        self.imageView.fixCropFrame(fixRatio: fixRatio)
        self.frameActionSheet.dismiss(animated: true, completion: nil)
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
        if (self.fixedRatioFrame == .none) {
            self.present(self.frameActionSheet, animated: true, completion: nil)
        } else {
            self.customFrameButton.setImage(UIImage(named: icRatioImgName), for: .normal)
            self.fixedRatioFrame = .none
            self.imageView.fixCropFrame(fixRatio: .none)
        }
    }

}

extension BBMCropRotateImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
