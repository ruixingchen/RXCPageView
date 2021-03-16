//
//  AsyncSerialOperationQueue.swift
//  RXCAsyncSerialOperationQueue
//
//  Created by ruixingchen on 2020/10/27.
//

import Foundation

///一个定制的串行OperationQueue, 任务执行完毕后必须通知本队列, 之后才会进行下一个任务
public class AsyncSerialOperationQueue {

    ///同时运行的任务数量
    public var maxConcurrentOperationCount: Int = 3
    ///添加任务后自动开始, 如果为false, 则需要手动调用run方法后开始
    public var runAutomatically: Bool = true
    ///等待中的任务
    private var waitingOperations:[()->Void] = []
    ///运行中的任务数量
    private var runningOperationNum: Int = 0

    ///每次当前所有任务都完成的时候都会被调用, 注意如果是分批向本queue添加任务, 这个closure可能会多次调用
    private var _completionClosure:(()->Void)?

    ///任务运行的queue, nil表示当前queue
    public var queue: DispatchQueue?

    ///completion运行的queue, nil表示当前queue
    private var completionQueue:DispatchQueue?

    public init(queue: DispatchQueue?, maxConcurrentOperationCount:Int = 3, runAutomatically: Bool = true) {
        self.queue = queue
        self.maxConcurrentOperationCount = maxConcurrentOperationCount
        self.runAutomatically = runAutomatically
    }

    #if (debug || DEBUG)
    deinit {
        print("AsyncSerialOperationQueue DEINIT")
    }
    #endif

    ///开始运行
    public func run() {
        if self.waitingOperations.isEmpty && self.runningOperationNum == 0 {
            //开始运行的时候既没有等待中的任务, 也没有正在运行的任务, 直接调用completion
            self._runCompletion()
            return
        }
        guard !self.waitingOperations.isEmpty else {return}
        guard self.runningOperationNum < self.maxConcurrentOperationCount else {return}
        self.runningOperationNum += 1
        let task = self.waitingOperations.remove(at: 0)
        self._runTask(task: task)
    }

    ///添加一个任务, 注意任务的调用顺序遵循FIFO原则
    public func addOperation(closure: @escaping ()->Void) {
        self.waitingOperations.append(closure)
        if self.runAutomatically {
            self.run()
        }
    }

    ///当任务完成的时候, 需要手动调用本方法, 队列才会进行下一个方法的调用
    public func operationComplete() {
        guard self.runningOperationNum > 0 else {
            assertionFailure("complete on no task running")
            return
        }
        self.runningOperationNum -= 1
        if self.runningOperationNum == 0 && self.waitingOperations.isEmpty {
            self._runCompletion()
        }else {
            self.run()
        }
    }

    public func completion(queue: DispatchQueue?, closure:@escaping ()->Void) {
        self.completionQueue = queue
        self._completionClosure = closure
    }

    private func _runTask(task: @escaping ()->Void) {
        if let __queue = self.queue {
            __queue.async {
                task()
            }
        }else {
            task()
        }
    }

    private func _runCompletion() {
        guard self._completionClosure != nil else {return}
        if let __queue = self.completionQueue {
            __queue.async {
                self._completionClosure?()
            }
        }else {
            self._completionClosure?()
        }
    }

}

