//
//  MessageError.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/2.
//

import Foundation

struct MessageError: Error, LocalizedError {

    var message: String

    var errorDescription: String? {
        return self.message
    }

}
