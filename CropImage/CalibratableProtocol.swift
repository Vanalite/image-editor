//
//  CalibratableProtocol.swift
//  CropImage
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

import Foundation
import UIKit

protocol Calibratable {
    func calibrateView()
}

extension Calibratable where Self: UIImageView {
    func calibrateView() {
        guard let assignedImage = self.image,
            let superView = self.superview else { return }
        var width = assignedImage.size.width
        var height = assignedImage.size.height
        let viewSize = superView.frame.size
        let ratio = height / width
        width = viewSize.width
        height = width * ratio
        if height > viewSize.height {
            height = viewSize.height
            width = height / ratio
        }
        let x = viewSize.width / 2 - (width / 2)
        let y = viewSize.height / 2 - (height / 2)
        self.frame = CGRect(x: x, y: y, width: width, height: height)
    }
}


