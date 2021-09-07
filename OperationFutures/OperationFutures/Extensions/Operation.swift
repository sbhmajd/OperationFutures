//
//  Operation.swift
//  OperationFutures
//
//  Created by Maksym Usenko on 3/25/19.
//  Copyright © 2019 SprinkleGroup. All rights reserved.
//

import Foundation

extension CoreOperation {
    
    // MARK: - Public methods
    public func then<U>(_ op: CoreOperation<OutputType, U>) -> CoreOperation<OutputType, U> {
        op.addDependency(self)
        completed = { [unowned self] in
            op.input = self.output
        }
    
        return op
    }
    
    public func then<T, U>(_ op: CoreOperation<T, U>) -> CoreOperation<T, U> {
        op.addDependency(self)
        return op
    }
}

extension Operation {
    
    func cancelWithAllDependencies() {
        dependencies.forEach { $0.cancelWithAllDependencies() }
        cancel()
    }
    
    func applyQualityOfServiceForAllDependencies(with quality: QualityOfService, queuePriority priority: Operation.QueuePriority) {
        qualityOfService = quality
        queuePriority = priority
        dependencies.forEach { $0.applyQualityOfServiceForAllDependencies(with: quality, queuePriority: priority) }
    }
}
