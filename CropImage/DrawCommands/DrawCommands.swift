//
//  BBMFreeHandDrawingViewController.swift
//  Alaska
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

import UIKit

protocol Canvas {
    var context: CGContext {get}
    func reset()
}

protocol DrawCommand {
    func execute(canvas: Canvas)
}

protocol DrawCommandReceiver {
    func executeCommands(commands: [DrawCommand])
}
