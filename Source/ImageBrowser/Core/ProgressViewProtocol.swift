//
//  ProgressViewProtocol.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/30.
//

import UIKit

///描述描述一个可以显示进度的View
public protocol ProgressViewProtocol where Self: UIView {

    ///任务开始
    func onTaskStart()
    ///任务进度变化
    func onTaskProgress(_ progress: Float)
    ///任务结束
    func onTaskFinish()

}
