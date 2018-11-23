//
//  BBMFreeHandDrawingViewController.swift
//  Alaska
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

struct LineDrawCommand : DrawCommand {
    var points = [CGPoint]()
    
    let width: CGFloat
    let color: UIColor

    // MARK: DrawCommand
    
    func execute(canvas: Canvas) {
        self.configure(canvas: canvas)

        if self.points.count == 3 {
            self.drawQuadCurve(canvas: canvas)
        } else if self.points.count >= 3 {
            self.drawCurve(canvas: canvas)
        } else {
            self.drawLine(canvas: canvas)
        }
    }
    
    private func configure(canvas: Canvas) {
        canvas.context.setStrokeColor(self.color.cgColor)
        canvas.context.setLineWidth(self.width)
        canvas.context.setLineCap(.round)
    }
    
    private func drawLine(canvas: Canvas) {
        canvas.context.move(to: self.points[self.points.count - 2])
        canvas.context.addLine(to: self.points[self.points.count - 1])
        canvas.context.strokePath()
    }
    
    private func drawCurve(canvas: Canvas) {
        canvas.context.move(to: points[0])
        canvas.context.addCurve(to: points[3], control1: points[1], control2: points[2])
        canvas.context.strokePath()
    }
    
    private func drawQuadCurve(canvas: Canvas) {
        canvas.context.move(to: points[0])
        canvas.context.addQuadCurve(to: points[2], control: points[1])
        canvas.context.strokePath()
    }
}
