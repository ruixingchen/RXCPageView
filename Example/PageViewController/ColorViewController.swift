//
//  ColorViewController.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/19.
//

import UIKit

class ColorViewController: UITableViewController {

    init(color: UIColor) {
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        print(self.title! + "viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        print(self.title! + "viewDidAppear")
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        print(self.title! + "\(self.view.safeAreaInsets)")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell.init()
    }

}
