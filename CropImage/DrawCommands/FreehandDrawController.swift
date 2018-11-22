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
    var width: CGFloat = 5.0
    
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
            self.continueAtPoint(point: point, velocity: sender.velocity(in: sender.view))
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
        self.lastPoint = point
        self.lineStrokeCommand = ComposedCommand(commands: [])
    }
    
    private func continueAtPoint(point: CGPoint, velocity: CGPoint) {
        let segmentWidth = modulatedWidth(width: self.width, velocity: velocity, previousVelocity: self.lastVelocity, previousWidth: self.width)
        let segment = Segment(a: self.lastPoint, b: point, width: segmentWidth)
        
        let lineCommand = LineDrawCommand(current: segment, previous: lastSegment, width: segmentWidth, color: self.color)
        
        self.canvas.executeCommands(commands: [lineCommand])

        self.lineStrokeCommand?.addCommand(command: lineCommand)
        self.lastPoint = point
        self.lastSegment = segment
        self.lastVelocity = velocity
        self.lastWidth = segmentWidth
    }
    
    private func endAtPoint(point: CGPoint) {
        if let lineStrokeCommand = self.lineStrokeCommand {
            self.commandQueue.append(lineStrokeCommand)
        }
        
        self.lastPoint = .zero
        self.lastSegment = nil
        self.lastVelocity = .zero
        self.lastWidth = nil
        self.lineStrokeCommand = nil
    }
    
    private func tapAtPoint(point: CGPoint) {
        let circleCommand = CircleDrawCommand(center: point, radius: self.width/2.0, color: self.color)
        self.canvas.executeCommands(commands:[circleCommand])
        self.commandQueue.append(circleCommand)
    }
    
    private let canvas: Canvas & DrawCommandReceiver
    private var lineStrokeCommand: ComposedCommand?
    private var commandQueue: Array<DrawCommand> = []
    private var lastPoint: CGPoint = .zero
    private var lastSegment: Segment?
    private var lastVelocity: CGPoint = .zero
    private var lastWidth: CGFloat?
}
