//
//  DrawableImageView.swift
//  Alaska
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

class DrawableImageView: UIImageView, Calibratable, Canvas, DrawCommandReceiver {
    var originalImage: UIImage?
    override var image: UIImage? {
        didSet {
            self.calibrateView()
        }
    }

    var context: CGContext {
        return UIGraphicsGetCurrentContext()!
    }
    
    func reset() {
        self.image = self.originalImage
        self.layer.contents = nil
    }

    func executeCommands(commands: [DrawCommand]) {
        autoreleasepool {
            self.image = self.drawInContext(code: { context in
                let _ = commands.map { $0.execute(canvas: self) }
            })
            self.layer.contents = self.image?.cgImage ?? nil
        }
    }
    
    private func drawInContext(code:(_ context: CGContext) -> Void) -> UIImage? {
        let size = self.bounds.size
        
        // Initialize a full size image. Opaque because we don't need to draw over anything. Will be more performant.
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(self.backgroundColor?.cgColor ?? UIColor.white.cgColor)
        context.fill(self.bounds)
        
        // Draw previous buffer first
        if let buffer = self.image {
            buffer.draw(in: self.bounds)
        }

        // Execute draw code
        code(context)
        
        // Grab updated buffer and return it
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
