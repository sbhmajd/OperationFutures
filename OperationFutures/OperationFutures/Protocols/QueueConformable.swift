//
//  QueueConformable.swift
//  OperationFutures
//
//  Created by Maksym Usenko on 3/25/19.
//  Copyright © 2019 SprinkleGroup. All rights reserved.
//

import Foundation

public protocol QueueConformable: class {
    var queue: OperationQueue { get }
}
