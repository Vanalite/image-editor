/*
The MIT License (MIT)

Copyright (c) 2015-present Badoo Trading Limited.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import UIKit

struct LineDrawCommand : DrawCommand {
    let current: Segment
    let previous: Segment?
    
    let width: CGFloat
    let color: UIColor

    // MARK: DrawCommand
    
    func execute(canvas: Canvas) {
        self.configure(canvas: canvas)

        if let _ = self.previous {
            self.drawQuadraticCurve(canvas: canvas)
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
        canvas.context.move(to: self.current.a)
        canvas.context.addLine(to: self.current.b)
        canvas.context.strokePath()
    }
    
    private func drawQuadraticCurve(canvas: Canvas) {
        if let previousMid = self.previous?.midPoint {
            let currentMid = self.current.midPoint
            canvas.context.move(to: previousMid)
            canvas.context.addQuadCurve(to: current.a, control: currentMid)
            canvas.context.strokePath()
        }
    }
}
