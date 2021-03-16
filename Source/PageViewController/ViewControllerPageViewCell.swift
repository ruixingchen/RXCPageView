//
//  ViewControllerPageViewCell.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

///PageViewController用来显示一个ViewController的Cell, 会将Cell添加到contentView上
open class ViewControllerPageViewCell: UICollectionViewCell, PageViewCell {

    public weak var bindedViewController: UIViewController?

    open func bindPageData(_ pageData: PageData, at page: Int) {
        guard let data = pageData as? ViewControllerPageData else {return}
        self.bindedViewController = data.viewController
        data.viewController.beginAppearanceTransition(true, animated: false)
        if data.viewController.view.superview != self.contentView {
            data.viewController.view.removeFromSuperview()
            self.contentView.addSubview(data.viewController.view)
        }
        data.viewController.endAppearanceTransition()

        self.setNeedsLayout()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if let vc = self.bindedViewController, vc.isViewLoaded, vc.view.superview == self.contentView {
            vc.view.frame = self.contentView.bounds
        }
    }

    open func didEndDisplaying(at indexPath: IndexPath) {
        guard let vc = self.bindedViewController else {return}
        vc.beginAppearanceTransition(false, animated: false)
        vc.view.removeFromSuperview()
        vc.endAppearanceTransition()
        self.bindedViewController = nil
    }

}
