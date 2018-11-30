//
//  CroppableImageView.swift
//  Alaska
//
//  Created by ea on 11/20/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

let kTouchValidatePaddingRatio: CGFloat = 0.2
let kCornerSideLength: CGFloat = 20

enum FixedRatioFrame : Int {
    case none = 0
    case original
    case fitToScreen
    case square
    case twoThird
    case threeFifth
    case threeFourth
    case fourFifth
    case fiveSeventh
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
    var fixRatio = FixedRatioFrame.none
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
    
    private func setupUI() {
        self.setupCropView()
        self.setupGesture()
    }
    
    private func setupCropView() {
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
    
    private func createShapeLayer(path: UIBezierPath) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.path = path.cgPath
        shapeLayer.position = .zero
        return shapeLayer
    }
    
    private func createCornerView(layer: CAShapeLayer) -> UIView {
        let cornerView = UIView()
        cornerView.backgroundColor = .clear
        cornerView.layer.addSublayer(layer)
        cornerView.translatesAutoresizingMaskIntoConstraints = false
        cornerView.heightAnchor.constraint(equalToConstant: kCornerSideLength).isActive = true
        cornerView.widthAnchor.constraint(equalToConstant: kCornerSideLength).isActive = true
        return cornerView
    }
    
    private func setupCropViewCorners() {
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
    
    private func renderDarkOverlay() {
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
    
    private func addDebugDragingFrame() {
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
    
    private func setupGridView() {
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
    
    private func setupGesture() {
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(self.handlePanMove(sender:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        self.addGestureRecognizer(panRecognizer)
    }
    
    // MARK: Private Methods
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
    
    private func assignActionForCropFrame(withPoint point: CGPoint) {
        var cropFrame = self.cropView.frame
        let deltaWidth = cropFrame.width * kTouchValidatePaddingRatio
        let deltaHeight = cropFrame.height * kTouchValidatePaddingRatio
        cropFrame = cropFrame.insetBy(dx: deltaWidth, dy: deltaHeight)
        self.validatingTouchingFrame = cropFrame
        if cropFrame.contains(point) {
            self.prepareToMoveCropFrame(initialPoint: point)
        } else {
            self.prepareToResizeCropFrame(initialPoint: point)
        }
    }
    
    private func prepareToMoveCropFrame(initialPoint point:CGPoint) {
        self.bringSubview(toFront: self.cropView)
        self.cropAction = .Move
    }

    private func prepareToResizeCropFrame(initialPoint point:CGPoint) {
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
    
    private func endCropAction() {
        self.cropAction = .None
        self.firstTouchLocation = nil
        self.changedEdge = nil
    }
    
    private func moveCropFrame(touchedPoint point: CGPoint) {
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
    
    private func resizeCropFrame(touchedPoint touchPoint: CGPoint) {
        if self.fixRatio != .none {
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
        }
        if changedEdge.contains(.right) {
            cropFrame.size.width += deltaX
        }
        if changedEdge.contains(.top) {
            cropFrame.size.height -= deltaY
            cropFrame.origin.y += deltaY
        }
        if changedEdge.contains(.bottom) {
            cropFrame.size.height += deltaY
        }
        cropFrame = self.refineFreeCropFrame(frame: cropFrame)
        self.assignCropFrameRatio(cropFrame: cropFrame)
        self.firstTouchLocation = touchPoint
    }
    
    private func resizeFixedCropFrame(touchedPoint touchPoint: CGPoint) {
        guard let firstTouchLocation = self.firstTouchLocation,
            let changedEdge = self.changedEdge else {
                return
        }
        
        var touchDeltaX = changedEdge.contains(.left) || changedEdge.contains(.right) ? touchPoint.x - firstTouchLocation.x : 0
        var touchDeltaY = changedEdge.contains(.top) || changedEdge.contains(.bottom) ? touchPoint.y - firstTouchLocation.y : 0
        if touchDeltaX == 0 && touchDeltaY == 0 {
            return
        }
        var dx : CGFloat = 0
        var dy : CGFloat = 0
        var dwidth: CGFloat = 0
        var dheight: CGFloat = 0
        
        if abs(touchDeltaX) > abs(touchDeltaY) {
            touchDeltaY = touchDeltaX / self.frameRatio
            if changedEdge.contains(.left) {
                if changedEdge.contains(.top) {
                    dy = touchDeltaY
                } else if changedEdge.contains(.bottom) {
                    dy = 0
                } else {
                    dy = touchDeltaY / 2
                }
                dheight = -touchDeltaY
                dwidth = -touchDeltaX
                dx = touchDeltaX
            } else if changedEdge.contains(.right) {
                if changedEdge.contains(.top) {
                    dy = -touchDeltaY
                } else if changedEdge.contains(.bottom) {
                    dy = 0
                } else {
                    dy = -touchDeltaY / 2
                }
                dheight = touchDeltaY
                dwidth = touchDeltaX
                dx = 0
            }
        } else {
            touchDeltaX = touchDeltaY * self.frameRatio
            if changedEdge.contains(.top) {
                if changedEdge.contains(.left) {
                    dx = touchDeltaX
                } else if changedEdge.contains(.right) {
                    dx = 0
                } else {
                    dx = touchDeltaX / 2
                }
                dwidth = -touchDeltaX
                dheight = -touchDeltaY
                dy = touchDeltaY
            } else if changedEdge.contains(.bottom) {
                if changedEdge.contains(.left) {
                    dx = -touchDeltaX
                } else if changedEdge.contains(.right) {
                    dx = 0
                } else {
                    dx = -touchDeltaX / 2
                }
                dwidth = touchDeltaX
                dheight = touchDeltaY
                dy = 0
            }
        }
        let frame = self.adjustFrame(self.cropView.frame, dx: dx, dy: dy, dwidth: dwidth, dheight: dheight)
        self.adjustFixedCropFrameDeltas(frame, dx: &dx, dy: &dy, dwidth: &dwidth, dheight: &dheight)
        let cropFrame = self.adjustFrame(self.cropView.frame, dx: dx, dy: dy, dwidth: dwidth, dheight: dheight)
        self.assignCropFrameRatio(cropFrame: cropFrame)
        self.firstTouchLocation = touchPoint
    }
    
    private func adjustFrame(_ frame: CGRect, dx: CGFloat, dy: CGFloat, dwidth: CGFloat, dheight: CGFloat) -> CGRect {
        var adjustedFrame = frame
        adjustedFrame.size.width += dwidth
        adjustedFrame.origin.x += dx
        adjustedFrame.size.height += dheight
        adjustedFrame.origin.y += dy
        return adjustedFrame
    }
    
    
    private func adjustFixedCropFrameDeltas(_ fixedFrame: CGRect, dx: inout CGFloat, dy: inout CGFloat, dwidth: inout CGFloat, dheight: inout CGFloat) {
        var frame = fixedFrame
        if frame.minX < 0 {
            let delta = -frame.minX
            let decreasedRatio = 1 - abs(delta / dx)
            dx = dx * decreasedRatio
            dy = dy * decreasedRatio
            dwidth = dwidth * decreasedRatio
            dheight = dheight * decreasedRatio
            frame = self.adjustFrame(self.cropView.frame, dx: dx, dy: dy, dwidth: dwidth, dheight: dheight)
        }
        if frame.maxX > self.frame.width {
            let delta = frame.maxX - self.frame.width
            let decreasedRatio = 1 - abs(delta / (frame.maxX - self.cropView.frame.maxX))
            dx = dx * decreasedRatio
            dy = dy * decreasedRatio
            dwidth = dwidth * decreasedRatio
            dheight = dheight * decreasedRatio
            frame = self.adjustFrame(self.cropView.frame, dx: dx, dy: dy, dwidth: dwidth, dheight: dheight)
        }
        if frame.minY < 0 {
            let delta = -frame.minY
            let decreasedRatio = 1 - abs(delta / dy)
            dx = dx * decreasedRatio
            dy = dy * decreasedRatio
            dwidth = dwidth * decreasedRatio
            dheight = dheight * decreasedRatio
            frame = self.adjustFrame(self.cropView.frame, dx: dx, dy: dy, dwidth: dwidth, dheight: dheight)
        }
        if frame.maxY > self.frame.height {
            let delta = frame.maxY - self.frame.height
            let decreasedRatio = 1 - abs(delta / (frame.maxY - self.cropView.frame.maxY))
            dx = dx * decreasedRatio
            dy = dy * decreasedRatio
            dwidth = dwidth * decreasedRatio
            dheight = dheight * decreasedRatio
            frame = self.adjustFrame(self.cropView.frame, dx: dx, dy: dy, dwidth: dwidth, dheight: dheight)
        }
    }
    
    private func refineFreeCropFrame(frame: CGRect) -> CGRect {
        var cropFrame = frame
        if cropFrame.minX < 0 {
            let delta = -cropFrame.minX
            cropFrame.origin.x = 0
            cropFrame.size.width -= delta
        }
        if cropFrame.maxX > self.frame.width {
            let delta = cropFrame.maxX - self.frame.width
            cropFrame.size.width -= delta
        }
        if cropFrame.minY < 0 {
            let delta = -cropFrame.minY
            cropFrame.origin.y = 0
            cropFrame.size.height -= delta
        }
        if cropFrame.maxY > self.frame.height {
            let delta = cropFrame.maxY - self.frame.height
            cropFrame.size.height -= delta
        }
        return cropFrame
    }
    
    private func isCropFrameExceedLimit(_ cropFrame: CGRect) -> Bool {
        if (cropFrame.size.height < self.defaultMinimumFrameSize || cropFrame.size.width < self.defaultMinimumFrameSize) ||
            (!self.bounds.contains(cropFrame)) {
            return true
        }
        return false
    }
}

extension CroppableImageView {
    func showGridView() {
        self.verticalGridView.isHidden = false
        self.horizontalGridView.isHidden = false
    }
    
    func hideGridView() {
        self.verticalGridView.isHidden = true
        self.horizontalGridView.isHidden = true
    }

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
        if self.fixRatio == .none {
            assignCropFrameRatio(cropFrame: self.bounds)
        } else {
            fixCropFrame(fixRatio: self.fixRatio)
        }
    }
    
    func rotate() {
        guard let image = self.image else { return }
        let radians = atan2f(Float(self.transform.b), Float(self.transform.a))
        let newImage = self.rotateImage(image, angle:CGFloat(radians - .pi / 2))
        self.image = newImage
        self.resetState()
    }
    
    func fixCropFrame(fixRatio: FixedRatioFrame) {
        self.fixRatio = fixRatio
        if fixRatio != .none {
            self.frameRatio = self.ratioValue(fixRatio: fixRatio)
            if self.frame.width / self.frameRatio > self.frame.height {
                self.assignDefaultCropFrameRatio(width: nil, height: self.frame.height)
            } else if self.frame.width < self.frame.height * self.frameRatio {
                self.assignDefaultCropFrameRatio(width: self.frame.width, height: nil)
            }
            self.assignDefaultCropFrameRatio(width: nil, height: self.frame.height)
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
    
    private func assignDefaultCropFrameRatio(width: CGFloat?, height: CGFloat?) {
        var fWidth, fHeight, fx, fy : CGFloat!
        
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
        let center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        fx = center.x - fWidth/2
        fy = center.y - fHeight/2
        
        let cropFrame = CGRect(x: fx, y: fy, width: fWidth, height: fHeight)
        self.assignCropFrameRatio(cropFrame: cropFrame)
    }
    
    private func assignCropFrameRatio(cropFrame: CGRect) {
        if (self.isCropFrameExceedLimit(cropFrame)) {
            return
        }
        self.cropView.frame = cropFrame
        self.cropView.layoutSubviews()
        self.renderDarkOverlay()
    }
    
    private func ratioValue(fixRatio: FixedRatioFrame) -> CGFloat {
        switch fixRatio {
        case .original:
            guard let image = self.image else { return 0 }
            return image.size.width / image.size.height
        case .square:
            return 1.0
        case .twoThird:
            return 2.0 / 3.0
        case .fitToScreen:
            return UIScreen.main.bounds.width / UIScreen.main.bounds.height
        case .threeFifth:
            return 3.0 / 5.0
        case .threeFourth:
            return 3.0 / 4.0
        case .fourFifth:
            return 4.0 / 5.0
        case .fiveSeventh:
            return 5.0 / 7.0
        default:
            return 0
        }
    }
}
