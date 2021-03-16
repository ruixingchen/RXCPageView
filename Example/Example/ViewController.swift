//
//  ViewController.swift
//  Example
//
//  Created by ruixingchen on 2021/1/28.
//

import UIKit
import SDWebImage

class ViewController: UITableViewController {

    enum Row: String {
        //case pageView = "pageView"
        case pageViewController = "pageViewController"
        //case imageBrowser = "imageBrowser"
        case imageBrowserViewController = "imageBrowserViewController"
    }

    let rows:[Row] = [
        .pageViewController,
        .imageBrowserViewController
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "清除缓存", style: .plain, target: self, action: #selector(self.clearCahce))
    }

    @objc func clearCahce() {
        SDWebImageManager.shared.imageCache.clear(with: .all) {
            print("清理缓存完成")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = self.rows[indexPath.row].rawValue
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.rows[indexPath.row] {
        case .pageViewController:
            let vc = ColorPageViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .imageBrowserViewController:
            let vc = ImageBrowserExmapleViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

