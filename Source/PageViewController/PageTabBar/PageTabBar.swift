//
//  PageTabBar.swift
//  Example
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

public protocol PageTabBar where Self: UIView {

    func barSize(thatFits size: CGSize)->CGSize

}
