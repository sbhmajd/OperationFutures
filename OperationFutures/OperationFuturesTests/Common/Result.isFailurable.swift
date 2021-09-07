//
//  REsult.swift
//  OperationFuturesTests
//
//  Created by Maksym Usenko on 8/28/19.
//  Copyright © 2019 SprinkleGroup. All rights reserved.
//

import Foundation

extension Result {
    
    var isFailurable: Bool {
        if case .failure = self {
            return true
        }
        
        return false
    }
}
