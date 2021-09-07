//
//  OperationQueue.swift
//  OperationFutures
//
//  Created by Maksym Usenko on 3/25/19.
//  Copyright © 2019 SprinkleGroup. All rights reserved.
//

import Foundation

extension OperationQueue {
        
    // MARK: - Private methods
    private func add(dependencies: [Operation & QueueConformable]) {
        for dependency in dependencies {
            if !dependency.dependencies.isEmpty {
                let dependencies = dependency.dependencies.compactMap{ $0 as? Operation & QueueConformable }
                add(dependencies: dependencies)
            }
            dependency.queue.addOperation(dependency)
        }
    }
    
    func addOperationChain(_ operation: Operation & QueueConformable) {
        let dependencies = operation.dependencies.compactMap{ $0 as? Operation & QueueConformable }
        add(dependencies: dependencies)
        operation.queue.addOperation(operation)
    }
}
