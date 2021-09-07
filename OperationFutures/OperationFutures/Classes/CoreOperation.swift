//
//  CoreOperation.swift
//  OperationFutures
//
//  Created by Maksym Usenko on 3/25/19.
//  Copyright © 2019 SprinkleGroup. All rights reserved.
//

import Foundation

open class CoreOperation<InputType, OutputType>: Operation, QueueConformable {
    
    // MARK: - Properties
    public final var input: Result<InputType, Error> {
        get {
            defer { inputLock.unlock() }
            inputLock.lock()
            return inputValue
        }
        set {
            defer { inputLock.unlock() }
            inputLock.lock()
            inputValue = newValue
        }
    }
    public final var output: Result<OutputType, Error> {
        get {
            defer { outputLock.unlock() }
            outputLock.lock()
            return outputValue
        }
        set {
            defer { outputLock.unlock() }
            outputLock.lock()
            outputValue = newValue
        }
    }
    public private(set) var queue: OperationQueue
    public var completed: (() -> Void) = {}
    public var outputUpdated: ((_ data: Result<OutputType, Error>) -> Void)?
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }

    private let inputLock = NSLock()
    private let outputLock = NSLock()
    private var inputValue: Result<InputType, Error> = .failure(Errors.inputDataNotSetted)
    private var outputValue: Result<OutputType, Error> = .failure(Errors.outputDataNotSetted)
    
    // MARK: - Overriden properties
    override public final var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override public final var isExecuting: Bool {
        return state == .executing
    }
    
    override public final var isFinished: Bool {
        return state == .finished
    }
    
    override public final var isCancelled: Bool {
        return state == .cancelled
    }
    
    // MARK: - Init/Deinit
    public init(in operationQueue: OperationQueue) {
        queue = operationQueue
    }
    
    // MARK: - Life Cycle
    override public final func start() {
        guard canProceed() else { return }
        
        main()
    }
    
    override open func main() {
        output = input.flatMap(handle)
        finished()
    }
    
    override open func cancel() {
        guard !isCancelled else { return }
        
        output = input.flatMap { (input) -> Result<OutputType, Error> in
            return .failure(Errors.cancelled)
        }
        state = .cancelled
        super.cancel()
    }
    
    // MARK: - Public methods
    public final func finished() {
        completed()
        state = .finished
        completed = {}
    }
    
    public final func canProceed() -> Bool {
        guard !isCancelled else {
            finished()
            return false
        }
        
        state = .executing
        return true
    }
    
    // MARK: - Private methods
    public func handle(input: InputType) -> Result<OutputType, Error> {
        guard let data = input as? OutputType else {
            return .failure(Errors.cantCastToOutputType)
        }
        
        return .success(data)
    }
}

// MARK: - Errors
extension CoreOperation {
    
    enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
        case cancelled = "isCancelled"
    }
    
    public enum Errors: Error {
        case firstInputDataNotSetted
        case inputDataNotSetted
        case outputDataNotSetted
        case cancelled
        case cantCastToOutputType
    }
}
