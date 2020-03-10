//
//  UnfinishedOperation.swift
//  OperationFuturesTests
//
//  Created by Maksym Usenko on 3/25/19.
//  Copyright © 2019 SprinkleGroup. All rights reserved.
//

import Foundation
import OperationFutures

final class UnfinishedOperation: CoreOperation<String, Void> {
    
    // MARK: - Life Cycle
    override func main() {
        output = .success(())
    }
}
