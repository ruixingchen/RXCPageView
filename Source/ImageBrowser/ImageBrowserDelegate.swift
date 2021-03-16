//
//  ImageBrowserDelegate.swift
//  Example
//
//  Created by ruixingchen on 2021/2/2.
//

import Foundation

public protocol ImageBrowserDelegate: PageViewDelegate {

    func imageBrowser(_ browser: ImageBrowser, didChangeLoaidngStateAtPage page: Int, thumbnailState: ImageLoadingState, originalState: ImageLoadingState)

    func imageBrowser(_ browser: ImageBrowser, didSingleTapAt page: Int)

    func imageBrowser(_ browser: ImageBrowser, didLongPressAt page: Int)

}
