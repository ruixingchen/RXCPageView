//
//  ColorPageViewCell.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/29.
//

import UIKit

class ColorPageViewCell: UICollectionViewCell, PageViewCell {

    let titleLabel = UILabel.init()

    func bindPageData(_ pageData: PageData, at page: Int) {
        self.contentView.backgroundColor = (pageData as! ColorPageData).color
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.font = UIFont.systemFont(ofSize: 24)
        self.titleLabel.text = page.description
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = self.titleLabel.intrinsicContentSize
        let x = self.contentView.bounds.midX - size.width/2
        let y = self.contentView.bounds.midY - size.height/2
        self.titleLabel.frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
    }

}
