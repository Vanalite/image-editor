//
//  CroppableImageView.swift
//  CropImage
//
//  Created by ea on 11/20/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

class CroppableImageView: UIImageView {
    let cropView = UIView()

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
        self.cropView.layer.borderColor = UIColor.red.cgColor
//        self.cropView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.addSubview(self.cropView)
    }
    
    func setupGesture() {
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.zoomImage))
//        doubleTap.numberOfTapsRequired = 2
//        self.addGestureRecognizer(doubleTap)
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(self.move(sender:)))
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        self.cropView.addGestureRecognizer(panRecognizer)
    }
    
    @objc private func move(sender: UIPanGestureRecognizer) {
        guard let senderView = sender.view else { return }
        self.bringSubview(toFront: senderView)
        var translatedPoint = sender.translation(in: senderView.superview)
        
        translatedPoint = CGPoint(x: senderView.center.x + translatedPoint.x, y: senderView.center.y + translatedPoint.y)
        var finalX = translatedPoint.x
        var finalY = translatedPoint.y
        let senderViewHalfWidth = senderView.frame.size.width / 2
        let senderViewHalfHeight = senderView.frame.size.height / 2
        
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
        senderView.center = CGPoint(x: finalX, y: finalY)
        
        sender.setTranslation(.zero, in:senderView)
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
        
        let croppedRect = self.cropView.frame
        if let cgImage = self.image?.cgImage {
            if let subImage = cgImage.cropping(to: croppedRect) {
                let croppedImage = UIImage(cgImage: subImage)
                self.image = croppedImage;
            }
        }
    }
}
