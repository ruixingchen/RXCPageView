//
//  PVLog.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/29.
//

import Foundation

struct PVLog {

    static func verbose(_ closure: @autoclosure ()->Any) {
        #if (debug || DEBUG)
        print(String.init(describing: closure()))
        #endif
    }

}
