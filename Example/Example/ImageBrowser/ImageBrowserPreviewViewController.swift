//
//  ImageBrowserPreviewViewController.swift
//  Example
//
//  Created by ruixingchen on 2021/2/5.
//

import UIKit
import SDWebImage
import RXCPageView

class ImageListCell: UICollectionViewCell {

    var imageView: UIImageView = UIImageView.init(frame: CGRect.zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.contentView.bounds
    }

}

class ImageBrowserPreviewViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ImageBrowserViewControllerZoomAnimationDelegate {

    lazy var picArray:[String] = self.makeDataSource()

    init() {
        let flow = UICollectionViewFlowLayout.init()
        flow.scrollDirection = .vertical
        flow.minimumLineSpacing = 4
        flow.minimumInteritemSpacing = 4
        super.init(collectionViewLayout: flow)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        self.collectionView.register(ImageListCell.self, forCellWithReuseIdentifier: "cell")
    }

    func makeDataSource()->[String] {
        return self.makeRemoteDataSource()
    }

    func makeLocalDataSource()->[String] {
        return []
    }

    func makeRemoteDataSource()->[String] {
        return [
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let start = Date.init().timeIntervalSince1970
        SDWebImageManager.shared.imageCache.queryImage(forKey: "http://image.coolapk.com/feed/2021/0126/09/1682265_2a0c37a7_4315_3847@1500x4830.jpeg", options: [], context: nil, cacheType: .disk) { (image, data, type) in
            print(Date.init().timeIntervalSince1970 - start)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.picArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let _cell = cell as? ImageListCell, let url = URL.init(string: self.picArray[indexPath.item].appending(".s.jpg")) {
            _cell.imageView.sd_setImage(with: url, completed: nil)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageDatas = self.picArray.map { (pic) -> ImagePageData in
            let data = ImagePageData.init(url: URL.init(string: pic)!, thumbnail: URL.init(string: pic.appending(".s.jpg"))!)
            data.imageDownloader = SDImageDownloader.shared
            data.imageCache = SDImageCache.init()
            return data
        }
        //尝试读取用户点击的图片数据的缓存
        //如果存在保持比例的缩略图缓存, 那么直接使用这些缓存来作为placeholder, 否则使用xs作为placeholder
        //开始尝试读取缓存
        let pic = self.picArray[indexPath.item]
        self.tryReadImagePlaceholder(pic: pic) { (image) in
            if let _image = image {
                imageDatas[indexPath.item].placeholder = Image.init(image: _image)
            }else {
                if let cell = collectionView.cellForItem(at: indexPath) {
                    imageDatas[indexPath.item].placeholder = Image.init(image: cell.snapshot())
                }
            }
            let browser = ImageBrowserViewController.init(images: imageDatas, page: indexPath.item)
            browser.delegate = self
            browser.browser.prefetchEnabled = false
            self.present(browser, animated: true, completion: nil)
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 4)/2
        return CGSize.init(width: width, height: width)
    }

    ///尝试读取一张图片的缓存来作为placeholder
    func tryReadImagePlaceholder(pic: String, completion: @escaping (UIImage?)->Void) {
        let pics:[String] = [
            pic,
            pic+".m.jpg",
            pic+".s.jpg",
            pic+".s2x.jpg",
            pic+"xs.jpg"
        ]

        let queue = AsyncSerialOperationQueue.init(queue: DispatchQueue.global(), maxConcurrentOperationCount: 1, runAutomatically: false)
        var image: UIImage?
        for i in pics {
            queue.addOperation {
                if image != nil {
                    queue.operationComplete()
                    return
                }
                SDWebImageManager.shared.imageCache.queryImage(forKey: i, options: .avoidDecodeImage, context: nil, cacheType: .all) { (_image, _, _) in
                    if image == nil {
                        image = _image
                    }
                    queue.operationComplete()
                }
            }
        }
        queue.completion(queue: DispatchQueue.main) {
            completion(image)
        }
        queue.run()
    }

    //MARK: - ImageBrowserViewControllerZoomAnimationDelegate

    func imageBrowser(_ browser: ImageBrowserViewController, sourceViewForAnimatingAt page: Int) -> UIView? {
        return self.collectionView.cellForItem(at: IndexPath.init(row: page, section: 0))
    }


}
