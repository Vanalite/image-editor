//
//  ViewController.swift
//  CropImage
//
//  Created by ea on 11/20/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

class BBMCropRotateImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @objc public var image: UIImage! {
        didSet {
            self.imageView.image = image
            let width = image.size.width
            let height = image.size.height
            self.imageView.frame = CGRect(x: 0, y:0, width: width, height: height)
            self.imageView.center = self.view.center;
        }
    }
    let imageView = CroppableImageView()
    let cropView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.image = UIImage(named: "Image2")
        self.setupUI()
        self.setupGesture()
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
        
//        self.imageView.frame = self.scrollView.bounds
//        self.imageView.autoresizingMask = UIViewAutoresizing(rawValue: 0xFF)  //Fill, stretch and scale
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.isUserInteractionEnabled = true
        self.view.addSubview(self.imageView)
        self.view.sendSubview(toBack: self.imageView)
//        self.setupCropView()
    }
    
    func setupCropView() {
        self.cropView.frame = CGRect(x: 0, y: 0, width: self.scrollView.frame.size.width / 2, height: self.scrollView.frame.size.width / 2)
        self.cropView.backgroundColor = .clear
        self.cropView.layer.borderWidth = 2
        self.cropView.layer.borderColor = UIColor.red.cgColor
            self.cropView.center = CGPoint(x: self.scrollView.frame.size.width / 2, y: self.scrollView.frame.size.height / 2)
            self.imageView.addSubview(self.cropView)
    }
    
    func setupGesture() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.zoomImage))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(self.move(sender:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        self.cropView.addGestureRecognizer(panRecognizer)
    }
    
    @objc func zoomImage() {
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
    }
    
    @objc func move(sender: UIPanGestureRecognizer) {
        guard let senderView = sender.view else { return }
        self.view.bringSubview(toFront: senderView)
        var translatedPoint = sender.translation(in: senderView.superview)
        
        translatedPoint = CGPoint(x: senderView.center.x + translatedPoint.x, y: senderView.center.y + translatedPoint.y)
        var finalX = translatedPoint.x
        var finalY = translatedPoint.y
        let senderViewHalfWidth = senderView.frame.size.width / 2
        let senderViewHalfHeight = senderView.frame.size.height / 2
        
        if finalX <= senderViewHalfWidth {
            finalX = senderViewHalfWidth
        } else if finalX >= self.view.frame.size.width - senderViewHalfWidth {
            finalX = self.view.frame.size.width - senderViewHalfWidth
        }
        
        if finalY <= senderViewHalfHeight {
            finalY = senderViewHalfHeight
        } else if finalY >= self.view.frame.size.height - senderViewHalfHeight {
            finalY = self.view.frame.size.height - senderViewHalfHeight
        }
        senderView.center = CGPoint(x: finalX, y: finalY)
        
        sender.setTranslation(.zero, in:senderView)
    }
    
    // MARK: User Interactions
    @IBAction func rotateButtonTouched(_ sender: Any) {
        guard let image = self.imageView.image else { return }
        let radians = atan2f(Float(self.imageView.transform.b), Float(self.imageView.transform.a))
        let newImage = self.rotateImage(image, angle:CGFloat(radians - .pi / 2))
        UIView.animate(withDuration: 0.5) {
            self.imageView.image = newImage
        }
    }
    
    @IBAction func doneButtonTouched(_ sender: Any) {
        self.cropImage()
    }
    
    func cropImage() {
        //Failed
//        UIGraphicsBeginImageContext(self.cropView.frame.size)
//        if let context = UIGraphicsGetCurrentContext() {
//            self.cropView.layer.draw(in: context)
//        }
//        let screenShot = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        self.imageView.image = screenShot;
        
//        let croppedRect = self.cropView.convert(self.cropView.frame, to: self.imageView)
//        if let cgImage = self.imageView.image?.cgImage {
//            if let subImage = cgImage.cropping(to: croppedRect) {
//                let croppedImage = UIImage(cgImage: subImage)
//                self.imageView.image = croppedImage;
//            }
//        }
        
        self.imageView.cropImage()
    }
    
    @IBAction func cropButtonTouched(_ sender: Any) {
        self.cropImage()
    }
    
    @IBAction func resetButtonTouched(_ sender: Any) {
        self.image = UIImage(named: "Image2")
    }
    
    @IBAction func cancelButtonTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func rotateImage(_ image: UIImage, angle: CGFloat) -> UIImage  {
        let ciImage = CIImage(image:image)
        guard let filter = CIFilter(name:"CIAffineTransform") else { return UIImage() }
        
        filter.setValue(ciImage, forKey:kCIInputImageKey)
        filter.setDefaults()
        
        let newAngle = angle * -1.0
        
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, newAngle, 0, 0, 1)
        
        let affineTransform = CATransform3DGetAffineTransform(transform)
        filter.setValue(NSValue(cgAffineTransform: affineTransform), forKey: "inputTransform")
        
        let contex = CIContext(options: [kCIContextUseSoftwareRenderer: true])
        
        guard let outputImage = filter.outputImage, let cgImage = contex.createCGImage(outputImage, from:outputImage.extent) else {
            return UIImage()
        }
        let result = UIImage(cgImage: cgImage)
        return result
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
