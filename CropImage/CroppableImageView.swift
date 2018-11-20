//
//  CroppableImageView.swift
//  CropImage
//
//  Created by ea on 11/20/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

let kTouchValidatePaddingRation: CGFloat = 0.2

enum CropFrameAction : Int {
    case None = 0
    case Move = 1
    case Resize = 2
}

class CroppableImageView: UIImageView {
    private let cropView = UIView()
    private var firstTouchLocation: CGPoint?
    var defaultMinimumFrameSize: CGFloat = 50.0
    var defaultCropFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
    var changedEdge: UIRectEdge?
    var cropAction = CropFrameAction.None
    var validatingTouchingFrame: CGRect?

    init() {
        super.init(frame: .zero)
        self.setupUI()
        self.setupGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.setupCropView()
        self.setupGesture()
    }
    
    func setupCropView() {
        self.cropView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.cropView.backgroundColor = .clear
        self.cropView.layer.borderWidth = 2
        self.cropView.layer.borderColor = UIColor.white.cgColor
        self.addSubview(self.cropView)
        self.addGridView()
        // Testing only
        self.addDebugDragingFrame()
    }
    
    func resetCropViewFrame() {
        let size = min(self.frame.size.width, self.frame.size.height)
        self.cropView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        self.cropView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
    }
    
    func addDebugDragingFrame() {
        let touchView = UIView(frame: .zero)
        touchView.layer.borderColor = UIColor.red.cgColor
        touchView.layer.borderWidth = 2
        self.cropView.addSubview(touchView)
        touchView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: touchView, attribute: .centerX, relatedBy: .equal, toItem: self.cropView, attribute: .centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: touchView, attribute: .centerY, relatedBy: .equal, toItem: self.cropView, attribute: .centerY, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: touchView, attribute: .height, relatedBy: .equal, toItem: self.cropView, attribute: .height, multiplier: 0.8, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: touchView, attribute: .width, relatedBy: .equal, toItem: self.cropView, attribute: .width, multiplier: 0.8, constant: 0)
        self.cropView.addConstraints([horizontalConstraint, verticalConstraint, heightConstraint, widthConstraint])
        self.cropView.layoutSubviews()
    }
    
    func addGridView() {
        let verticalGridView = UIView()
        verticalGridView.layer.borderColor = UIColor.white.cgColor
        verticalGridView.layer.borderWidth = 1
        self.cropView.addSubview(verticalGridView)
        verticalGridView.translatesAutoresizingMaskIntoConstraints = false
        var horizontalConstraint = NSLayoutConstraint(item: verticalGridView, attribute: .centerX, relatedBy: .equal, toItem: self.cropView, attribute: .centerX, multiplier: 1, constant: 0)
        var verticalConstraint = NSLayoutConstraint(item: verticalGridView, attribute: .centerY, relatedBy: .equal, toItem: self.cropView, attribute: .centerY, multiplier: 1, constant: 0)
        var heightConstraint = NSLayoutConstraint(item: verticalGridView, attribute: .height, relatedBy: .equal, toItem: self.cropView, attribute: .height, multiplier: 1, constant: 0)
        var widthConstraint = NSLayoutConstraint(item: verticalGridView, attribute: .width, relatedBy: .equal, toItem: self.cropView, attribute: .width, multiplier: 1/3, constant: 0)
        self.cropView.addConstraints([horizontalConstraint, verticalConstraint, heightConstraint, widthConstraint])
        
        let horizontalGridView = UIView()
        horizontalGridView.layer.borderColor = UIColor.white.cgColor
        horizontalGridView.layer.borderWidth = 1
        self.cropView.addSubview(horizontalGridView)
        horizontalGridView.translatesAutoresizingMaskIntoConstraints = false
        horizontalConstraint = NSLayoutConstraint(item: horizontalGridView, attribute: .centerX, relatedBy: .equal, toItem: self.cropView, attribute: .centerX, multiplier: 1, constant: 0)
        verticalConstraint = NSLayoutConstraint(item: horizontalGridView, attribute: .centerY, relatedBy: .equal, toItem: self.cropView, attribute: .centerY, multiplier: 1, constant: 0)
        heightConstraint = NSLayoutConstraint(item: horizontalGridView, attribute: .height, relatedBy: .equal, toItem: self.cropView, attribute: .height, multiplier: 1/3, constant: 0)
        widthConstraint = NSLayoutConstraint(item: horizontalGridView, attribute: .width, relatedBy: .equal, toItem: self.cropView, attribute: .width, multiplier: 1, constant: 0)
        self.cropView.addConstraints([horizontalConstraint, verticalConstraint, heightConstraint, widthConstraint])
    }
    
    func setupGesture() {
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(self.handlePanMove(sender:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panRecognizer)
    }
    
    @objc private func handlePanMove(sender: UIPanGestureRecognizer) {
        guard let senderView = sender.view else { return }
        let locationPoint = sender.location(in: senderView)
        switch sender.state {
        case .began:
            self.assignActionForCropFrame(withPoint: locationPoint)
        case .changed:
            switch self.cropAction {
            case .Move:
                let translatedPoint = sender.translation(in: senderView)
                self.moveCropFrame(touchedPoint: translatedPoint)
            case .Resize:
                self.resizeCropFrame(touchedPoint: locationPoint)
            case .None:
                break
            }
        case .ended:
            self.cropAction = .None
            
        default:
            break
        }
        sender.setTranslation(.zero, in:senderView)
    }
    
    func assignActionForCropFrame(withPoint point: CGPoint) {
        var cropFrame = self.cropView.frame
        let deltaWidth = cropFrame.width * kTouchValidatePaddingRation
        let deltaHeight = cropFrame.height * kTouchValidatePaddingRation
        cropFrame = cropFrame.insetBy(dx: deltaWidth, dy: deltaHeight)
        self.validatingTouchingFrame = cropFrame
        if cropFrame.contains(point) {
            self.prepareToMoveCropFrame(initialPoint: point)
        } else {
            self.prepareToResizeCropFrame(initialPoint: point)
        }
    }
    
    func prepareToMoveCropFrame(initialPoint point:CGPoint) {
        self.bringSubview(toFront: self.cropView)
        self.cropAction = .Move
    }

    func prepareToResizeCropFrame(initialPoint point:CGPoint) {
        guard let cropFrame = self.validatingTouchingFrame else { return }
        self.cropAction = .Resize
        self.firstTouchLocation = point
        var changedEdge: UIRectEdge = []
        if point.x <= cropFrame.minX {
            changedEdge.insert(.left)
        } else if point.x >= cropFrame.maxX  {
            changedEdge.insert(.right)
        }
        if point.y <= cropFrame.minY {
            changedEdge.insert(.top)
        } else if point.y >= cropFrame.maxY {
            changedEdge.insert(.bottom)
        }
        self.changedEdge = changedEdge
    }
    
    func endCropAction() {
        self.cropAction = .None
        self.firstTouchLocation = nil
        self.changedEdge = nil
    }
    
    func moveCropFrame(touchedPoint point: CGPoint) {
        self.bringSubview(toFront: self.cropView)
        let translatedPoint = CGPoint(x: self.cropView.center.x + point.x, y: self.cropView.center.y + point.y)

        var finalX = translatedPoint.x
        var finalY = translatedPoint.y
        let senderViewHalfWidth = self.cropView.frame.size.width / 2
        let senderViewHalfHeight = self.cropView.frame.size.height / 2
        
        if finalX <= senderViewHalfWidth {
            finalX = senderViewHalfWidth
        } else if finalX >= self.frame.size.width - senderViewHalfWidth {
            finalX = self.frame.size.width - senderViewHalfWidth
        }
        
        if finalY <= senderViewHalfHeight {
            finalY = senderViewHalfHeight
        } else if finalY >= self.frame.size.height - senderViewHalfHeight {
            finalY = self.frame.size.height - senderViewHalfHeight
        }
        self.cropView.center = CGPoint(x: finalX, y: finalY)
    }
    
    func resizeCropFrame(touchedPoint touchPoint: CGPoint) {
        guard let firstTouchLocation = self.firstTouchLocation,
            let changedEdge = self.changedEdge else {
            return
        }
        var cropFrame = self.cropView.frame

        let deltaX = changedEdge.contains(.left) || changedEdge.contains(.right) ? touchPoint.x - firstTouchLocation.x : 0
        let deltaY = changedEdge.contains(.top) || changedEdge.contains(.bottom) ? touchPoint.y - firstTouchLocation.y : 0
        
        if changedEdge.contains(.left) {
            cropFrame.size.width -= deltaX
            cropFrame.origin.x += deltaX
            if cropFrame.origin.x < 0 {
                let delta = -cropFrame.origin.x
                cropFrame.origin.x = 0
                cropFrame.size.width -= delta
            }
        }
        if changedEdge.contains(.right) {
            cropFrame.size.width += deltaX
            if cropFrame.maxX > self.frame.width {
                let delta = cropFrame.maxX - self.frame.width
                cropFrame.size.width -= delta
            }
        }
        
        if changedEdge.contains(.top) {
            cropFrame.size.height -= deltaY
            cropFrame.origin.y += deltaY
            if cropFrame.origin.y < 0 {
                let delta = -cropFrame.origin.y
                cropFrame.origin.y = 0
                cropFrame.size.height -= delta
            }
        }
        if changedEdge.contains(.bottom) {
            cropFrame.size.height += deltaY
            if cropFrame.maxY > self.frame.height {
                let delta = cropFrame.maxY - self.frame.height
                cropFrame.size.height -= delta
            }
        }
        if (self.isCropFrameExceedLimit(cropFrame)) {
            return
        }
        self.cropView.frame = cropFrame
        self.cropView.layoutSubviews()
        self.firstTouchLocation = touchPoint
    }
    
    func isCropFrameExceedLimit(_ cropFrame: CGRect) -> Bool {
        if (cropFrame.size.height < self.defaultMinimumFrameSize || cropFrame.size.width < self.defaultMinimumFrameSize) ||
            (!self.bounds.contains(cropFrame)) {
            return true
        }
        return false
    }
}

extension CroppableImageView {
    func cropImage() {
        guard let image = self.image else { return }
        var croppedRect = self.cropView.frame
        var width = image.size.width
        var height = image.size.height

        width = croppedRect.size.width * (width / self.frame.width)
        height = croppedRect.size.height * (height / self.frame.height)
        
        let imageViewPoint = self.cropView.frame.origin;
        
        let percentX = imageViewPoint.x / frame.size.width
        let percentY = imageViewPoint.y / frame.size.height
        
        let imagePoint = CGPoint(x: image.size.width * percentX, y: image.size.height * percentY)
        croppedRect = CGRect(x: imagePoint.x, y: imagePoint.y, width: width, height: height)
        if let cgImage = self.image?.cgImage {
            if let subImage = cgImage.cropping(to: croppedRect) {
                let croppedImage = UIImage(cgImage: subImage)
                self.image = croppedImage;
            }
        }
    }
    
    func resetState() {
        self.resetCropViewFrame()
    }
    
    func rotate() {
        guard let image = self.image else { return }
        let radians = atan2f(Float(self.transform.b), Float(self.transform.a))
        let newImage = self.rotateImage(image, angle:CGFloat(radians - .pi / 2))
        self.image = newImage
    }
    
    // MARK: Private Methods
    private func rotateImage(_ image: UIImage, angle: CGFloat) -> UIImage  {
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
}
