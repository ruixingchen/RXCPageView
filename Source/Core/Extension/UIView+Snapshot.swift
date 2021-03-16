//
//  UIView+Snapshot.swift
//  Example
//
//  Created by ruixingchen on 2021/2/5.
//

import UIKit

public extension UIView {

    func snapshot(in rect: CGRect? = nil, afterScreenUpdates: Bool = false) -> UIImage {
        return UIGraphicsImageRenderer.init(bounds: rect ?? self.bounds).image { (context) in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }

    private func fastSnapshot(rect: CGRect?, afterScreenUpdates: Bool = false) -> UIImage? {
        let cropRect: CGRect = rect ?? self.bounds
        UIGraphicsBeginImageContextWithOptions(cropRect.size, false, UIScreen.main.scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: afterScreenUpdates)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    private func snapshot(rect: CGRect = CGRect.zero) -> UIImage? {
        var cropRect: CGRect = rect
        if cropRect.size.width <= 0 || cropRect.height <= 0 {
            cropRect = self.bounds
        }
        UIGraphicsBeginImageContextWithOptions(cropRect.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}
