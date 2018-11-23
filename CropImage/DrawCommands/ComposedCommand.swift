//
//  BBMFreeHandDrawingViewController.swift
//  Alaska
//
//  Created by ea on 11/22/18.
//  Copyright © 2018 ea. All rights reserved.
//

struct ComposedCommand : DrawCommand {
    init(commands: [DrawCommand]) {
        self.commands = commands;
    }
    
    // MARK: DrawCommand
    
    func execute(canvas: Canvas) {
        self.commands.forEach({ (command) in
            command.execute(canvas: canvas)
        })
    }
    
    mutating func addCommand(command: DrawCommand) {
        self.commands.append(command)
    }
    
    private var commands: [DrawCommand]
}
