//
//  ImageBrowserViewControllerZoomAnimationDelegate.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/18.
//

import UIKit

public protocol ImageBrowserViewControllerZoomAnimationDelegate: ImageBrowserViewControllerDelegate {

    func imageBrowser(_ browser: ImageBrowserViewController, sourceViewForAnimatingAt page: Int)->UIView?

}
