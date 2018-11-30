//
//  BBMFreeHandDrawingViewController.swift
//  Alaska
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

func modulatedWidth(width: CGFloat, velocity: CGPoint, previousVelocity: CGPoint, previousWidth: CGFloat) -> CGFloat {
    let velocityAdjustement: CGFloat = 600.0
    let speed = velocity.length() / velocityAdjustement
    let previousSpeed = previousVelocity.length() / velocityAdjustement
    
    let modulated = width / (0.6 * speed + 0.4 * previousSpeed)
    let limited = clamp(value: modulated, min: 0.75 * previousWidth, max: 1.25 * previousWidth)
    let final = clamp(value: limited, min: 0.2*width, max: width)
    
    return final
}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt((self.x * self.x) + (self.y * self.y))
    }
}

func clamp<T: Comparable>(value: T, min: T, max: T) -> T {
    if (value < min) {
        return min
    }
    
    if (value > max) {
        return max
    }
    
    return value
}
