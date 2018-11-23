//
//  VerticalSlider.swift
//  CropImage
//
//  Created by ea on 11/23/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

@IBDesignable open class VerticalSlider: UIView {
    
    public let slider = UISlider()
    private let imageView = UIImageView()
    
    // required for IBDesignable class to properly render
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    // required for IBDesignable class to properly render
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    fileprivate func initialize() {
        self.imageView.frame = self.bounds.insetBy(dx: 2, dy: 5)
        if let clearImage = UIImage(named: "icVerticalSlider") {
            self.imageView.image = clearImage
            self.imageView.layer.opacity = 0.4
            self.imageView.backgroundColor = .clear
        }
        self.addSubview(self.imageView)
        updateSlider()
        self.addSubview(slider)
    }
    
    fileprivate func updateSlider() {
        if !ascending {
            slider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) * -0.5)
        } else {
            slider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi) * 0.5).scaledBy(x: 1, y: -1)
        }
        
        slider.minimumValue = minimumValue
        slider.maximumValue = maximumValue
        slider.value = value
        slider.thumbTintColor = thumbTintColor
        slider.minimumTrackTintColor = minimumTrackTintColor
        slider.maximumTrackTintColor = maximumTrackTintColor
        slider.isContinuous = isContinuous
    }
    
    @IBInspectable open var ascending: Bool = false {
        didSet {
            updateSlider()
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        slider.bounds.size.width = bounds.height
        slider.center.x = bounds.midX
        slider.center.y = bounds.midY
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: slider.intrinsicContentSize.height, height: slider.intrinsicContentSize.width)
        }
    }
    
    @IBInspectable open var minimumValue: Float = -1 {
        didSet {
            updateSlider()
        }
    }
    
    @IBInspectable open var maximumValue: Float = 1 {
        didSet {
            updateSlider()
        }
    }
    
    @IBInspectable open var value: Float {
        get {
            return slider.value
        }
        set {
            slider.setValue(newValue, animated: true)
        }
    }
    
    @IBInspectable open var thumbTintColor: UIColor? {
        didSet {
            updateSlider()
        }
    }
    
    @IBInspectable open var minimumTrackTintColor: UIColor? {
        didSet {
            updateSlider()
        }
    }
    
    @IBInspectable open var maximumTrackTintColor: UIColor? {
        didSet {
            updateSlider()
        }
    }
    
    @IBInspectable open var isContinuous: Bool = true {
        didSet {
            updateSlider()
        }
    }
}
