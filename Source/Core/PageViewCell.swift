//
//  PageViewCell.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit

public protocol PageViewCell where Self: UICollectionViewCell {

    func bindPageData(_ pageData: PageData, at page: Int)

}
