//
//  ResultTests.swift
//  OperationFutures
//
//  Created by Maksym Usenko on 3/25/19.
//  Copyright © 2019 SprinkleGroup. All rights reserved.
//

import Foundation

public final class CoreOperationClosure<InputType, OutputType>: CoreOperation<InputType, OutputType> {

    // MARK: - Properties
    private var execution: (_ input: Result<InputType, Error>) -> Result<OutputType, Error>

    // MARK: - Init / Deinit methods
    public required init(in queue: OperationQueue,
                            closure: @escaping (_: Result<InputType, Error>) -> Result<OutputType, Error>) {

        execution = closure
        super.init(in: queue)
    }

    // MARK: - Life Cycle
    public override func main() {
        guard canProceed() else { return }

        output = execution(input)
        finished()
    }
}
