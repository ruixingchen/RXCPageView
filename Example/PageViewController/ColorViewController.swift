//
//  ColorViewController.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/19.
//

import UIKit

class ColorViewController: UIViewController {

    init(color: UIColor) {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
