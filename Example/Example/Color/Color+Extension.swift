//
//  Color+Extension.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

extension UIColor {

    static func random()->UIColor {
        return UIColor.init(hue: CGFloat.random(in: 0...1), saturation: CGFloat.random(in: 0...1), brightness: CGFloat.random(in: 0...1), alpha: 1.0)
    }

}
