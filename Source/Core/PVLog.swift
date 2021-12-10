//
//  PVLog.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/29.
//

import Foundation

internal struct PVLog {

    static var enabled: Bool = false

    internal static func verbose(_ closure: @autoclosure ()->Any) {
        #if (debug || DEBUG)
        if Self.enabled {
            print(String.init(describing: closure()))
        }
        #endif
    }

}
