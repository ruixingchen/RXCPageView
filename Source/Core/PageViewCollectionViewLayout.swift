//
//  PageViewCollectionViewLayout.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit

open class PageViewCollectionViewLayout: UICollectionViewFlowLayout {

    open var pageSpacing: CGFloat = 0

    open override var minimumLineSpacing: CGFloat {
        set {}
        get {0}
    }

    open override var minimumInteritemSpacing: CGFloat {
        set {}
        get {0}
    }

    ///这里必须重写itemSize, 如果在prepare中使用这个逻辑会导致第一次接收到contenOffset的KVO通知的时候, Cell的尺寸依然是系统默认的尺寸
    open override var itemSize: CGSize {
        set {
            super.itemSize = newValue
        }
        get {
            var full: Bool = true
            if let delegate = self.collectionView?.delegate, delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
                full = false
            }
            if full {
                if let boundSize = self.collectionView?.bounds.size, boundSize.width > 0, boundSize.height > 0 {
                    return boundSize
                }
            }
            return super.itemSize
        }
    }

    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //idea from YBImageBrowser
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect)?.map({$0.copy() as! UICollectionViewLayoutAttributes}) else {return nil}
        guard self.pageSpacing != 0 else {return layoutAttributes}

        let halfWidth = (self.collectionView?.bounds.size.width ?? 0)/2
        let centerX = (self.collectionView?.contentOffset.x ?? 0) + halfWidth
        for i in layoutAttributes.enumerated() {
            let x = i.element.center.x + (i.element.center.x - centerX)/halfWidth*self.pageSpacing/2
            i.element.center = CGPoint.init(x: x, y: i.element.center.y)
        }
        return layoutAttributes
    }

    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

}
