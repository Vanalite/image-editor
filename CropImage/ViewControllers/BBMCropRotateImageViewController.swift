//
//  ViewController.swift
//  Alaska
//
//  Created by ea on 11/20/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

class BBMCropRotateImageViewController: UIViewController, UIScrollViewDelegate {
    
    @objc weak var delegate : ImageEditorDelegate? = nil
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalImage = self.image
        self.setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc private func rotated() {
        self.imageView.resetState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView.image = self.image
    }
    
    override func viewDidLayoutSubviews() {
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
    
    private func setupUI() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupScrollView()
        self.setupImageView()
        self.setupGesture()
        self.setupFrameActionSheet()
    }
    
    private func setupScrollView() {
        self.scrollView.delegate = self
        self.scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView.isUserInteractionEnabled = false
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.isHidden = true
    }
    
    private func setupImageView() {
        let imageContentView = UIView()
        imageContentView.translatesAutoresizingMaskIntoConstraints = false
        self.imageContainerView.addSubview(imageContentView)
        imageContentView.leadingAnchor.constraint(equalTo: self.imageContainerView.leadingAnchor, constant: 10).isActive = true
        imageContentView.trailingAnchor.constraint(equalTo: self.imageContainerView.trailingAnchor, constant: -10).isActive = true
        imageContentView.topAnchor.constraint(equalTo: self.imageContainerView.topAnchor, constant: 10).isActive = true
        imageContentView.bottomAnchor.constraint(equalTo: self.imageContainerView.bottomAnchor, constant: -10).isActive = true
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isUserInteractionEnabled = true
        imageContentView.addSubview(self.imageView)
        self.view.sendSubview(toBack: self.imageContainerView)
    }
    
    private func setupFrameActionSheet() {
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] (action) in
            self?.frameActionSheet.dismiss(animated: true, completion: nil)
        }
        self.frameActionSheet.addAction(cancel)
        
        let original = UIAlertAction(title: "Original", style: .default) { [weak self] (action) in
            self?.selectFixRatio(.original)
        }
        self.frameActionSheet.addAction(original)
        
        let fitToScreen = UIAlertAction(title: "Fit to screen", style: .default) { [weak self]  (action) in
            self?.selectFixRatio(.fitToScreen)
        }
        self.frameActionSheet.addAction(fitToScreen)
        
        let square = UIAlertAction(title: "Square", style: .default) { [weak self] (action) in
            self?.selectFixRatio(.square)
        }
        self.frameActionSheet.addAction(square)
        
        let twoThird = UIAlertAction(title: "2:3", style: .default) { [weak self] (action) in
            self?.selectFixRatio(.twoThird)
        }
        self.frameActionSheet.addAction(twoThird)
        
        let threeFifth = UIAlertAction(title: "3:5", style: .default) { [weak self] (action) in
            self?.selectFixRatio(.threeFifth)
        }
        self.frameActionSheet.addAction(threeFifth)
        
        let threeFourth = UIAlertAction(title: "3:4", style: .default) { [weak self] (action) in
            self?.selectFixRatio(.threeFourth)
        }
        self.frameActionSheet.addAction(threeFourth)
        
        let fourFifth = UIAlertAction(title: "4:5", style: .default) { [weak self] (action) in
            self?.selectFixRatio(.fourFifth)
        }
        self.frameActionSheet.addAction(fourFifth)
        
        let fiveSeventh = UIAlertAction(title: "5:7", style: .default) { [weak self] (action) in
            self?.selectFixRatio(.fiveSeventh)
        }
        self.frameActionSheet.addAction(fiveSeventh)
    }
    
    private func switchToNoneFixedRatio() {
        self.customFrameButton.setImage(UIImage(named: icRatioImgName), for: .normal)
        self.imageView.fixCropFrame(fixRatio: .none)
    }
    
    private func selectFixRatio(_ fixRatio: FixedRatioFrame) {
        self.customFrameButton.setImage(UIImage(named: icRatioSelectedImgName), for: .normal)
        self.imageView.fixCropFrame(fixRatio: fixRatio)
        self.frameActionSheet.dismiss(animated: true, completion: nil)
    }
    
    private func dismiss() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
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
        self.delegate?.didFinishEditingImage(self.image)
        self.dismiss()
    }
    
    @IBAction func resetButtonTouched(_ sender: Any) {
        self.image = self.originalImage
        switchToNoneFixedRatio()
        self.imageView.resetState()
    }
    
    @IBAction func cancelButtonTouched(_ sender: Any) {
        self.dismiss()
    }
    
    @IBAction func customFrameButtonTouched(_ sender: Any) {
        if (self.imageView.fixRatio == .none) {
            self.present(self.frameActionSheet, animated: true, completion: nil)
        } else {
            switchToNoneFixedRatio()
        }
    }
    
}

extension BBMCropRotateImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
