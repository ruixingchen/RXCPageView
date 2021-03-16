//
//  PVLog.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/29.
//

import Foundation

internal struct PVLog {

    internal static func verbose(_ closure: @autoclosure ()->Any) {
        #if (debug || DEBUG)
        print(String.init(describing: closure()))
        #endif
    }

}
