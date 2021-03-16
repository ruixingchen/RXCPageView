//
//  TitlePageTabBarTextCell.swift
//  Example
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

open class TitlePageTabBarTextCell: UICollectionViewCell, TitlePageTabBarCell {

    let titleLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSetup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initSetup()
    }

    open func initSetup() {
        self.contentView.addSubview(self.titleLabel)
    }

    public func highlight(percentage: CGFloat, with item: PageTabBarItem, style: TitlePageTabBarStyle) {
        self.titleLabel.text = item.title
        self.titleLabel.font = style.font
        self.titleLabel.textColor = self.calculateTextColor(percentage: percentage, style: style)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    open func calculateTextColor(percentage: CGFloat, style: TitlePageTabBarStyle)->UIColor {
        var fromR:CGFloat=0, fromG:CGFloat=0, fromB:CGFloat=0, fromA:CGFloat=0
        style.textColor.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        var toR:CGFloat=0, toG:CGFloat=0, toB:CGFloat=0, toA:CGFloat=0
        style.highlightTextColor.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
        let color = UIColor(red: fromR+(toR-fromR)*percentage, green: fromG+(toG-fromG)*percentage, blue: fromB+(toB-fromB)*percentage, alpha: fromA+(toA-fromA)*percentage)
        return color
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.titleLabel.intrinsicContentSize
        let x = self.contentView.bounds.midX - size.width/2
        let y = self.contentView.bounds.midY - size.height/2
        self.titleLabel.frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
    }

}
