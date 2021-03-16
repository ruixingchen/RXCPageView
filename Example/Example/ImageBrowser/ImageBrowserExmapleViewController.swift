//
//  ImageBrowserExmapleViewController.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/30.
//

import UIKit
import SDWebImage

class ImageBrowserExmapleViewController: UITableViewController {

    enum Row: String {
        case present = "present"
    }

    var rows:[Row] = [.present]

    let picArray:[String] = [
        "http://image.coolapk.com/feed/2021/0121/13/2003123_b3138cb0_8626_4308@342x350.jpeg",
        "http://image.coolapk.com/feed/2021/0121/13/2003123_3dff56f0_8626_4311@2493x3324.jpeg",
        //"http://image.coolapk.com/feed/2021/0121/13/2003123_a98e93f2_8626_4313@1080x500.jpeg",
        //"http://image.coolapk.com/feed/2021/0121/13/2003123_e9160e9a_8626_4315@1944x2592.jpeg",
        //"http://image.coolapk.com/feed/2021/0121/13/2003123_f72bbbee_8626_4317@1448x1448.jpeg",
        //"http://image.coolapk.com/feed/2021/0121/13/2003123_fd2e96d2_8626_4319@3322x2495.jpeg",
        //"http://image.coolapk.com/feed/2021/0121/13/2003123_42978fe7_8626_4321@2592x1944.jpeg",
        //"http://image.coolapk.com/feed/2021/0121/13/2003123_6ba9cb9c_8626_4323@2667x2667.jpeg",
        //"http://image.coolapk.com/feed/2021/0121/13/2003123_e524f454_8626_4325@3322x2495.jpeg",

        //"http://image.coolapk.com/feed/2021/0126/09/1682265_b820031d_4315_3834@1330x6233.jpeg",
        //"http://image.coolapk.com/feed/2021/0126/09/1682265_9e3f64f6_4315_3836@1477x5609.jpeg",
        //"http://image.coolapk.com/feed/2021/0126/09/1682265_a4fcf6cb_4315_3838@1462x5668.jpeg",
        //"http://image.coolapk.com/feed/2021/0126/09/1682265_d1ad72f9_4315_384@1446x5730.jpeg",
        //"http://image.coolapk.com/feed/2021/0126/09/1682265_95888915_4315_3842@1461x5672.jpeg",
        //"http://image.coolapk.com/feed/2021/0126/09/1682265_4ade9289_4315_3844@1500x4500.jpeg",
        //"http://image.coolapk.com/feed/2021/0126/09/1682265_abd2d443_4315_3845@1468x5643.jpeg",
        "http://image.coolapk.com/feed/2021/0126/09/1682265_2a0c37a7_4315_3847@1500x4830.jpeg",
        "http://image.coolapk.com/feed/2021/0126/09/1682265_c16a8f3a_4315_3849@1444x5740.jpeg",

        "http://image.coolapk.com/feed/2021/0126/23/1948945_c06ca082_4078_7254@780x360.gif"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
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
        case .present:
            let vc = ImageBrowserPreviewViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
