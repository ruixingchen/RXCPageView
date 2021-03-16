//
//  AnimatedImageCell.swift
//  Example
//
//  Created by ruixingchen on 2021/2/1.
//

import UIKit
import SDWebImage
import YYImage

class AnimatedImageCell: ImageBrowserCell {

    override func initImageContentView() -> UIView {
        let view = SDAnimatedImageView.init()
        view.clipsToBounds = true
        return view
    }

}
