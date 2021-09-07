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
    public required init(with input: InputType? = nil, in queue: OperationQueue,
                         closure: @escaping (_: Result<InputType, Error>) -> Result<OutputType, Error>) {
        
        self.execution = closure
        super.init(in: queue)
        if let input = input {
            self.input = Result.success(input)
        } else {
            self.input = Result.failure(Errors.firstInputDataNotSetted)
        }
    }
    
    // MARK: - Life Cycle
    public override func main() {
        guard canProceed() else { return }
        
        if case Result.failure(let error) = input, error.localizedDescription != Errors.firstInputDataNotSetted.localizedDescription {
            output = input.flatMap(handle)
            finished()
            return
        }
        
        output = execution(input)
        finished()
    }
}
