//
//  CGSize+Extension.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/18.
//

import UIKit

internal extension CGSize {

    ///保持比例缩放到fit目标尺寸
    func scale(aspectFit boundingSize: CGSize)->CGSize {
        let widthScale = boundingSize.width / self.width
        let heightScale = boundingSize.height / self.height
        let scale = min(widthScale, heightScale)
        let scaled = CGSize.init(width: self.width*scale, height: self.height*scale)
        return scaled
    }

    ///保持比例缩放到fill目标尺寸
    func scale(aspectFill boundingSize: CGSize)->CGSize {
        let widthScale = boundingSize.width / self.width
        let heightScale = boundingSize.height / self.height
        let scale = max(widthScale, heightScale)
        let scaled = CGSize.init(width: self.width*scale, height: self.height*scale)
        return scaled
    }


}
