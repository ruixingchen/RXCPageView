//
//  AnimatedTransitioning.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/3.
//

import UIKit

public protocol AnimatedTransitioning: UIViewControllerAnimatedTransitioning {

    ///是appear还是disappear
    var appearing: Bool {get set}
    ///持有浏览器实例
    var browserViewController: ImageBrowserViewController? {get set}

}
