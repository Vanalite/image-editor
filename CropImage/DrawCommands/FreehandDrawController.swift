//
//  FreehandDrawController.swift
//  FreehandDrawing-iOS
//
//  Created by Miguel Angel Quinones on 03/06/2015.
//  Copyright (c) 2015 badoo. All rights reserved.
//

import UIKit

class FreehandDrawController : NSObject {
    var color: UIColor = .black
    var width: CGFloat = 3.0
    
    required init(canvas: Canvas & DrawCommandReceiver, view: UIView) {
        self.canvas = canvas
        super.init()
        
        self.setupGestureRecognizersInView(view: view)
    }
    
    // MARK: API
    
    func undo() {
        if self.commandQueue.count > 0{
            self.commandQueue.removeLast()
            self.canvas.reset()
            self.canvas.executeCommands(commands: self.commandQueue)
        }
    }
    
    // MARK: Gestures
    
    private func setupGestureRecognizersInView(view: UIView) {
        // Pan gesture recognizer to track lines
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(sender:)))
        view.addGestureRecognizer(panRecognizer)
        
        // Tap gesture recognizer to track points
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let point = sender.location(in: sender.view)
        switch sender.state {
        case .began:
            self.startAtPoint(point: point)
        case .changed:
            self.continueAtPoint(point: point)
        case .ended:
            self.endAtPoint(point: point)
        case .failed:
            self.endAtPoint(point: point)
        default:
            assert(false, "State not handled")
        }
    }
    
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        let point = sender.location(in: sender.view)
        if sender.state == .ended {
            self.tapAtPoint(point: point)
        }
    }
    
    // MARK: Draw commands
    
    private func startAtPoint(point: CGPoint) {
        self.lastPoints[0] = point
        self.countPoint = 0
        self.lineStrokeCommand = ComposedCommand(commands: [])
    }
    
    private func continueAtPoint(point: CGPoint) {
        self.countPoint += 1
        self.lastPoints[countPoint] = point
        self.freeDraw(point: point)
    }
    
    private func endAtPoint(point: CGPoint) {
        self.countPoint += 1
        self.lastPoints[countPoint] = point
        switch self.countPoint {
        case 2:
            self.countPoint += 1
            self.lastPoints[countPoint] = point
            fallthrough
        case 3:
            let smallListArray = [self.lastPoints[0], self.lastPoints[1], self.lastPoints[2]]
            let lineCommand = LineDrawCommand(points: smallListArray, width: self.width, color: self.color)
            self.canvas.executeCommands(commands: [lineCommand])
            self.lineStrokeCommand?.addCommand(command: lineCommand)
            
            self.lastPoints[0] = self.lastPoints[3]
            self.lastPoints[1] = self.lastPoints[4]
            self.countPoint = 1
        case 4:
            self.freeDraw(point: point)
        default:
            break;
        }
        if let lineStrokeCommand = self.lineStrokeCommand {
            self.commandQueue.append(lineStrokeCommand)
        }

        self.lineStrokeCommand = nil
    }
    
    private func freeDraw(point: CGPoint) {
        if self.countPoint == 4 {
            self.lastPoints[3] = self.midPoint(a: self.lastPoints[2], b: self.lastPoints[4])
            let lineCommand = LineDrawCommand(points: self.lastPoints, width: self.width, color: self.color)
            self.canvas.executeCommands(commands: [lineCommand])
            self.lineStrokeCommand?.addCommand(command: lineCommand)
            
            self.lastPoints[0] = self.lastPoints[3]
            self.lastPoints[1] = self.lastPoints[4]
            self.countPoint = 1
        }
    }
    
    private func tapAtPoint(point: CGPoint) {
        let circleCommand = CircleDrawCommand(center: point, radius: self.width/2.0, color: self.color)
        self.canvas.executeCommands(commands:[circleCommand])
        self.commandQueue.append(circleCommand)
    }
    
    private func midPoint(a: CGPoint, b: CGPoint) -> CGPoint {
        return CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }

    
    private let canvas: Canvas & DrawCommandReceiver
    private var lineStrokeCommand: ComposedCommand?
    private var commandQueue: Array<DrawCommand> = []
    private var lastPoints = [CGPoint].init(repeating: .zero, count: 5)
    private var countPoint = 0
}
