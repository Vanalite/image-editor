//
//  CroppableImageView.swift
//  Alaska
//
//  Created by ea on 11/20/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

let kTouchValidatePaddingRation: CGFloat = 0.2
let kCornerSideLength: CGFloat = 20

enum FixedRatioFrame : Int {
    case none = 0
    case original
    case fitToScreen
    case square
    case twoThree
    case count
}

enum CropFrameAction : Int {
    case None = 0
    case Move = 1
    case Resize = 2
}

class CroppableImageView: UIImageView, Calibratable {
    private let cropView = UIView()
    private var firstTouchLocation: CGPoint?
    private var verticalGridView = UIView()
    private var horizontalGridView = UIView()
    private var darkLayer: CALayer?
    var defaultMinimumFrameSize: CGFloat = 50.0
    var changedEdge: UIRectEdge?
    var cropAction = CropFrameAction.None
    var validatingTouchingFrame: CGRect?
    var fixRation = FixedRatioFrame.none
    var frameRatio: CGFloat = 0.0
    
    override var image: UIImage? {
        didSet {
            self.calibrateView()
        }
    }

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
        self.cropView.frame = .zero
        self.cropView.clipsToBounds = false
        self.cropView.backgroundColor = .clear
        self.cropView.layer.borderWidth = 1
        self.cropView.layer.borderColor = UIColor.white.cgColor
        self.addSubview(self.cropView)
        self.setupGridView()
        self.setupCropViewCorners()
        // Testing only
        self.addDebugDragingFrame()
    }
    
    func createShapeLayer(path: UIBezierPath) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.path = path.cgPath
        shapeLayer.position = .zero
        return shapeLayer
    }
    
    func createCornerView(layer: CAShapeLayer) -> UIView {
        let cornerView = UIView()
        cornerView.backgroundColor = .clear
        cornerView.layer.addSublayer(layer)
        cornerView.translatesAutoresizingMaskIntoConstraints = false
        cornerView.heightAnchor.constraint(equalToConstant: kCornerSideLength).isActive = true
        cornerView.widthAnchor.constraint(equalToConstant: kCornerSideLength).isActive = true
        return cornerView
    }
    
    func setupCropViewCorners() {
        var path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: kCornerSideLength))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: kCornerSideLength, y: 0))
        let topLeftLayer = createShapeLayer(path: path)
        let topLeftView = createCornerView(layer: topLeftLayer)
        self.cropView.addSubview(topLeftView)
        topLeftView.leadingAnchor.constraint(equalTo: self.cropView.leadingAnchor, constant: -1).isActive = true
        topLeftView.topAnchor.constraint(equalTo: self.cropView.topAnchor, constant: -1).isActive = true
        
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: kCornerSideLength))
        path.addLine(to: CGPoint(x: kCornerSideLength, y: kCornerSideLength))
        let bottomLeftLayer = createShapeLayer(path: path)
        let bottomLeftView = createCornerView(layer: bottomLeftLayer)
        self.cropView.addSubview(bottomLeftView)
        bottomLeftView.leadingAnchor.constraint(equalTo: self.cropView.leadingAnchor, constant: -1).isActive = true
        bottomLeftView.bottomAnchor.constraint(equalTo: self.cropView.bottomAnchor, constant: 1).isActive = true
        
        path = UIBezierPath()
        path.move(to: CGPoint(x: kCornerSideLength, y: 0))
        path.addLine(to: CGPoint(x: kCornerSideLength, y: kCornerSideLength))
        path.addLine(to: CGPoint(x: 0, y: kCornerSideLength))
        let bottomRightLayer = createShapeLayer(path: path)
        let bottomRightView = createCornerView(layer: bottomRightLayer)
        self.cropView.addSubview(bottomRightView)
        bottomRightView.trailingAnchor.constraint(equalTo: self.cropView.trailingAnchor, constant: 1).isActive = true
        bottomRightView.bottomAnchor.constraint(equalTo: self.cropView.bottomAnchor, constant: 1).isActive = true
        
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: kCornerSideLength, y: 0))
        path.addLine(to: CGPoint(x: kCornerSideLength, y: kCornerSideLength))
        
        let topRightLayer = createShapeLayer(path: path)
        let topRightView = createCornerView(layer: topRightLayer)
        self.cropView.addSubview(topRightView)
        topRightView.trailingAnchor.constraint(equalTo: self.cropView.trailingAnchor, constant: 1).isActive = true
        topRightView.topAnchor.constraint(equalTo: self.cropView.topAnchor, constant: -1).isActive = true
        
        self.cropView.layoutSubviews()
    }
    
    func renderDarkOverlay() {
        let path = UIBezierPath(rect: self.cropView.frame)
        let fullPath = UIBezierPath(rect: self.bounds)
        path.append(fullPath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor(white: 0, alpha: 0.8).cgColor
        fillLayer.opacity = 0.5
        self.darkLayer?.removeFromSuperlayer()
        self.darkLayer = fillLayer
        self.layer.insertSublayer(fillLayer, below: self.cropView.layer)
    }
    
    func addDebugDragingFrame() {
        let touchView = UIView(frame: .zero)
        touchView.layer.borderColor = UIColor.red.cgColor
        touchView.layer.borderWidth = 2
        self.cropView.addSubview(touchView)
        touchView.translatesAutoresizingMaskIntoConstraints = false
        touchView.centerXAnchor.constraint(equalTo: self.cropView.centerXAnchor).isActive = true
        touchView.centerYAnchor.constraint(equalTo: self.cropView.centerYAnchor).isActive = true
        touchView.heightAnchor.constraint(equalTo: self.cropView.heightAnchor, multiplier: 0.8).isActive = true
        touchView.widthAnchor.constraint(equalTo: self.cropView.widthAnchor, multiplier: 0.8).isActive = true
        self.cropView.layoutSubviews()
    }
    
    func setupGridView() {
        self.verticalGridView.layer.borderColor = UIColor.white.cgColor
        self.verticalGridView.layer.borderWidth = 1
        self.cropView.addSubview(self.verticalGridView)
        self.verticalGridView.translatesAutoresizingMaskIntoConstraints = false
        self.verticalGridView.centerXAnchor.constraint(equalTo: self.cropView.centerXAnchor).isActive = true
        self.verticalGridView.centerYAnchor.constraint(equalTo: self.cropView.centerYAnchor).isActive = true
        self.verticalGridView.heightAnchor.constraint(equalTo: self.cropView.heightAnchor).isActive = true
        self.verticalGridView.widthAnchor.constraint(equalTo: self.cropView.widthAnchor, multiplier: 1/3).isActive = true
        
        self.horizontalGridView.layer.borderColor = UIColor.white.cgColor
        self.horizontalGridView.layer.borderWidth = 1
        self.cropView.addSubview(self.horizontalGridView)
        self.horizontalGridView.translatesAutoresizingMaskIntoConstraints = false
        self.horizontalGridView.centerXAnchor.constraint(equalTo: self.cropView.centerXAnchor).isActive = true
        self.horizontalGridView.centerYAnchor.constraint(equalTo: self.cropView.centerYAnchor).isActive = true
        self.horizontalGridView.heightAnchor.constraint(equalTo: self.cropView.heightAnchor, multiplier: 1/3).isActive = true
        self.horizontalGridView.widthAnchor.constraint(equalTo: self.cropView.widthAnchor).isActive = true
    }
    
    func showGridView() {
        self.verticalGridView.isHidden = false
        self.horizontalGridView.isHidden = false
    }
    
    func hideGridView() {
        self.verticalGridView.isHidden = true
        self.horizontalGridView.isHidden = true
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
        self.renderDarkOverlay()
    }
    
    func resizeCropFrame(touchedPoint touchPoint: CGPoint) {
        if self.fixRation != .none {
            self.resizeFixedCropFrame(touchedPoint: touchPoint)
            return
        }
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
        self.renderDarkOverlay()
        self.firstTouchLocation = touchPoint
    }
    
    func resizeFixedCropFrame(touchedPoint touchPoint: CGPoint) {
        guard let firstTouchLocation = self.firstTouchLocation,
            let changedEdge = self.changedEdge else {
                return
        }
        var cropFrame = self.cropView.frame
        
        var deltaX = changedEdge.contains(.left) || changedEdge.contains(.right) ? touchPoint.x - firstTouchLocation.x : 0
        var deltaY = changedEdge.contains(.top) || changedEdge.contains(.bottom) ? touchPoint.y - firstTouchLocation.y : 0
        if abs(deltaX) > abs(deltaY) {
            deltaY = deltaX / self.frameRatio
        } else {
            deltaX = deltaY * self.frameRatio
        }
        
        let t0 = CGAffineTransform(translationX: -(cropFrame.origin.x + cropFrame.width), y: -cropFrame.origin.y)
        let t1 =  (scaleX: 1.001, y: 1.001)
        let t2 = CGAffineTransform(translationX: (cropFrame.origin.x + cropFrame.width), y: cropFrame.origin.y)
        cropFrame = cropFrame.applying(t0.concatenating(t1).concatenating(t2))
        self.cropView.frame = cropFrame
        self.cropView.layoutSubviews()
        self.renderDarkOverlay()
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
        guard let currentCgImage = self.image?.cgImage else { return }
        let image = UIImage(cgImage: currentCgImage, scale: 1.0, orientation: .up)
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
        if let cgImage = image.cgImage {
            if let subImage = cgImage.cropping(to: croppedRect) {
                let croppedImage = UIImage(cgImage: subImage)
                self.image = croppedImage;
            }
        }
        self.resetState()
    }
    
    func resetState() {
        self.calibrateView()
        self.resetCropViewFrame()
    }
    
    func rotate() {
        guard let image = self.image else { return }
        let radians = atan2f(Float(self.transform.b), Float(self.transform.a))
        let newImage = self.rotateImage(image, angle:CGFloat(radians - .pi / 2))
        self.image = newImage
        self.resetState()
    }
    
    func fixCropFrame(fixRatio: FixedRatioFrame) {
        self.fixRation = fixRatio
        self.frameRatio = self.ratioValue(fixRatio: fixRatio)
        if self.cropView.frame.width < self.cropView.frame.height {
            self.assignCropFrameRation(width: self.cropView.frame.width, height: nil)
        } else {
            self.assignCropFrameRation(width: nil, height: self.cropView.frame.height)
        }
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
    
    private func assignCropFrameRation(width: CGFloat?, height: CGFloat?) {
        var fWidth, fHeight : CGFloat!
        
        if width == nil, let height = height {
            fWidth = height * self.frameRatio
            fHeight = height
        } else if height == nil, let width = width {
            fWidth = width
            fHeight = width / self.frameRatio
        } else if let width = width, let height = height {
            fHeight = height
            fWidth = width
        }
        
        let cropFrame = CGRect(x: 0, y: 0, width: fWidth, height: fHeight)
        self.cropView.frame = cropFrame
        self.cropView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.cropView.layoutSubviews()
        self.renderDarkOverlay()

    }
    
    private func resetCropViewFrame() {
        let size = self.bounds.size
        self.cropView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.cropView.center = CGPoint(x: size.width / 2, y: size.height / 2)
        self.renderDarkOverlay()
    }
    
    private func ratioValue(fixRatio: FixedRatioFrame) -> CGFloat {
        switch fixRatio {
        case .original:
            guard let image = self.image else { return 0 }
            return image.size.width / image.size.height
        case .square:
            return 1.0
        case .twoThree:
            return 2.0 / 3.0
        default:
            return 0
        }
    }
}
