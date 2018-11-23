//
//  BBMFreeHandDrawingViewController.swift
//  Alaska
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

struct CircleDrawCommand : DrawCommand {
    
    let center: CGPoint
    let radius: CGFloat
    let color: UIColor
    
    // MARK: DrawCommand
    
    func execute(canvas: Canvas) {
        canvas.context.setFillColor(self.color.cgColor)
        canvas.context.addArc(center: self.center, radius: self.radius, startAngle: 0, endAngle: 2 * CGFloat(Double.pi), clockwise: true)

        canvas.context.fillPath()
    }
}
