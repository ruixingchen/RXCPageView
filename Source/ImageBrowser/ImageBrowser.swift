//
//  ImageBrowser.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/30.
//

import UIKit

open class ImageBrowser: PageView, PageViewDataSource, ImageBrowserCellDelegate {

    open var imagePageDatas:[ImagePageData]

    public init(images:[ImagePageData], page: Int) {
        self.imagePageDatas = images
        super.init(page: page, scrollDirection: .horizontal)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func initCollectionView() -> UICollectionView {
        let collectionView = super.initCollectionView()
        (collectionView.collectionViewLayout as? PageViewCollectionViewLayout)?.pageSpacing = 24
        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }

    open override func initSetup() {
        super.initSetup()
        self.backgroundColor = UIColor.black
        self.dataSource = self
        self.registerCell(cellClassOrNib: ImageBrowserCell.self, identifier: "image_normal")
    }

    public func numberOfPages(in pageView: PageView) -> Int {
        return self.imagePageDatas.count
    }

    public func pageView(_ pageView: PageView, pageDataAt page: Int) -> PageData {
        return self.imagePageDatas[page]
    }

    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        if let imageCell = cell as? ImageBrowserCell {
            imageCell.delegate = self
            imageCell.browser = self
        }
        return cell
    }

    //MARK: - ImageBrowserCellDelegate

//    open func imageBrowserCell(_ cell: ImageBrowserCell, didChangeLoaidngStateWith thumbnailState: ImageLoadingState, originalState: ImageLoadingState) {
//        //当加载状态发生变化的时候, 需要通知代理
//        guard let indexPath = self.collectionView.indexPath(for: cell) else {return}
//        self.enumerateDelegates(closure: {($0 as? ImageBrowserDelegate)?.imageBrowser(self, didChangeLoaidngStateAtPage: indexPath.item, thumbnailState: cell.thumbnailLoadingState, originalState: cell.originalLoadingState)})
//    }

    open func imageBrowserCellDidSingleTap(_ cell: ImageBrowserCell) {
        guard let page = self.collectionView.indexPath(for: cell)?.item else {return}
        self.enumerateDelegates(closure: {($0 as? ImageBrowserDelegate)?.imageBrowser(self, didSingleTapAt: page)})
    }

    open func imageBrowserCellDidLongPress(_ cell: ImageBrowserCell, gestureRecognizer: UILongPressGestureRecognizer) {
        guard let page = self.collectionView.indexPath(for: cell)?.item else {return}
        guard gestureRecognizer.state == .recognized else {return}
        self.enumerateDelegates(closure: {($0 as? ImageBrowserDelegate)?.imageBrowser(self, didLongPressAt: page)})
    }

    public func imageBrowserCellDidChangeLoadingState(_ cell: ImageBrowserCell) {
        //当Cell的数据加载状态发生变化的时候, 需要通知自己的代理
        guard let indexPath = self.collectionView.indexPath(for: cell) else {return}
        guard let imageData = cell.bindedPageData as? ImagePageData else {return}
        self.enumerateDelegates(closure: {($0 as? ImageBrowserDelegate)?.imageBrowser(self, didChangeLoaidngStateAtPage: indexPath.item, thumbnailState: imageData.thumbnailState, originalState: imageData.originalState)})
    }

}
