//
//  ViewControllerPageViewCell.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

///PageViewController用来显示一个ViewController的Cell, 会将Cell添加到contentView上
open class ViewControllerPageViewCell: UICollectionViewCell, PageViewCell {

    weak var bindedViewController: UIViewController?

    open func bindPageData(_ pageData: PageData, at page: Int) {
        guard let data = pageData as? ViewControllerPageData else {return}
        self.bindedViewController = data.viewController
        self.contentView.addSubview(data.viewController.view)
        self.setNeedsLayout()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if let vc = self.bindedViewController, vc.isViewLoaded, vc.view.superview == self.contentView {
            vc.view.frame = self.contentView.bounds
        }
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        if let vc = self.bindedViewController, vc.isViewLoaded, vc.view.superview == self.contentView {
            vc.view.removeFromSuperview()
        }
    }

}
