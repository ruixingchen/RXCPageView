//
//  ZoomAnimatedTransitioning.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/2/3.
//

import UIKit

///用于提供动画所需的信息
public protocol ZoomAnimatedTransitioningDelegate: AnyObject {

    ///返回投影对象, 可以是投影View的截图
    func animatedTransitioningProjectiveImage(for transitioning: AnimatedTransitioning, context: UIViewControllerContextTransitioning, appearing: Bool, completion:@escaping((UIImage, CGRect)?)->Void)
    ///返回目标图片对象和位置
    func animatedTransitioningDestinationImage(for transitioning: AnimatedTransitioning, context: UIViewControllerContextTransitioning, appearing: Bool, completion:@escaping((UIImage, CGRect)?)->Void)
}

open class ZoomAnimatedTransitioning: NSObject, AnimatedTransitioning {

    public var appearing: Bool = true

    public weak var browserViewController: ImageBrowserViewController?

    public let maskView: UIView = {let view = UIView(); view.backgroundColor = UIColor.black; return view}()
    ///用于显示投影View截图的漂浮View
    public let floatingView: UIImageView = UIImageView.init(frame: CGRect.zero)
    ///用于显示图片浏览器View截图的漂浮View
    public let floatingView2: UIImageView = UIImageView.init(frame: CGRect.zero)

    open weak var delegate: ZoomAnimatedTransitioningDelegate?

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.33
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.appearing {
            self.playAppearingAnimation(context: transitionContext)
        }else {
            self.dismissAnimation(context: transitionContext)
        }
    }

    open func playAppearingAnimation(context: UIViewControllerContextTransitioning) {

        guard let toView = context.view(forKey: .to) else {return}
        //先将浏览器添加到containerView上, 让浏览器初始化
        toView.frame = context.containerView.bounds
        context.containerView.addSubview(toView)
        toView.alpha = 0

        guard let _delegate = self.delegate else {
            self.playBackupAppearingAnimation(context: context)
            return
        }

        //尝试读取缓存的图片
        //这里要注意,如果图片非常大, 那么可能会导致图片浏览器无法立刻弹出,不过一般情况下加载一张图片不会超过0.5秒,问题也不大
        //如果真的是非常大的图,那卡一下也没办法

        func showToView(completion: @escaping ()->Void) {
            UIView.animate(withDuration: 0.1) {
                toView.alpha = 1
            } completion: { (_) in
                completion()
            }
        }

        func step2(sourceImage: UIImage, sourceRect: CGRect, destinationImage: UIImage, destinationRect: CGRect) {
            //根据图片计算目标View的位置
            //开始执行动画
            let containerView = context.containerView

            self.maskView.alpha = 0
            self.maskView.frame = containerView.bounds
            containerView.addSubview(self.maskView)

            self.floatingView2.frame = sourceRect
            self.floatingView2.alpha = 1
            self.floatingView2.image = destinationImage
            containerView.addSubview(self.floatingView2)

            self.floatingView.frame = sourceRect
            self.floatingView.image = sourceImage
            self.floatingView.alpha = 1
            containerView.addSubview(self.floatingView)

            UIView.animate(withDuration: self.transitionDuration(using: context), delay: 0, options: []) {
                self.floatingView.alpha = 0
                self.floatingView.frame = destinationRect
                self.floatingView2.alpha = 1
                self.floatingView2.frame = destinationRect
                self.maskView.alpha = 1
            } completion: { (_) in
                showToView {
                    self.maskView.removeFromSuperview()
                    self.floatingView.removeFromSuperview()
                    self.floatingView2.removeFromSuperview()
                    context.completeTransition(!context.transitionWasCancelled)
                }
            }
        }

        ///当只有sourceView的时候, 执行一个漂浮动画, 让整个效果更好一点
        func playFloatingAnimation(sourceImage: UIImage, sourceRect: CGRect) {
            let containerView = context.containerView

            self.maskView.alpha = 0
            self.maskView.frame = containerView.bounds
            containerView.addSubview(self.maskView)

            self.floatingView.frame = sourceRect
            self.floatingView.image = sourceImage
            self.floatingView.alpha = 1
            containerView.addSubview(self.floatingView)

            UIView.animate(withDuration: self.transitionDuration(using: context), delay: 0, options: .curveEaseInOut) {
                let size = sourceRect.size.scale(aspectFit: containerView.bounds.size)
                let x = containerView.bounds.midX - size.width/2
                let y = containerView.bounds.midY - size.height/2
                let destinationRect = CGRect.init(x: x, y: y, width: size.width, height: size.height)
                self.floatingView.alpha = 0
                self.floatingView.frame = destinationRect
                self.floatingView2.alpha = 1
                self.floatingView2.frame = destinationRect
                self.maskView.alpha = 1
            } completion: { (_) in
                showToView {
                    self.maskView.removeFromSuperview()
                    self.floatingView.removeFromSuperview()
                    self.floatingView2.removeFromSuperview()
                    context.completeTransition(!context.transitionWasCancelled)
                }
            }
        }

        _delegate.animatedTransitioningProjectiveImage(for: self, context: context, appearing: self.appearing, completion: { (tuple) in
            guard let sourceImage = tuple?.0, let sourceRect = tuple?.1 else {
                self.playBackupAppearingAnimation(context: context)
                return
            }
            //获取到了source相关的信息, 开始获取destination相关的信息
            _delegate.animatedTransitioningDestinationImage(for: self, context: context, appearing: self.appearing) { (tuple) in
                guard let destinationImage = tuple?.0, let destinationRect = tuple?.1 else {
                    playFloatingAnimation(sourceImage: sourceImage, sourceRect: sourceRect)
                    return
                }
                //开始动画
                step2(sourceImage: sourceImage, sourceRect: sourceRect, destinationImage: destinationImage, destinationRect: destinationRect)
            }

        })
    }

    open func dismissAnimation(context: UIViewControllerContextTransitioning) {
        guard let vc = context.viewController(forKey: .from) else {return}
        vc.view.removeFromSuperview()
        context.completeTransition(!context.transitionWasCancelled)
    }

    ///备选动画方案,使用渐变
    open func playBackupAppearingAnimation(context: UIViewControllerContextTransitioning) {
        guard let toVC = context.viewController(forKey: .to) as? ImageBrowserViewController else {
            context.completeTransition(!context.transitionWasCancelled)
            return
        }
        toVC.view.frame = context.containerView.bounds
        toVC.view.isHidden = false
        toVC.view.alpha = 0
        context.containerView.addSubview(toVC.view)
        UIView.animate(withDuration: self.transitionDuration(using: context)) {
            toVC.view.alpha = 1
        } completion: { (_) in
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

    ///将原始View渐隐的Appear动画
    private func vanishplayAppearingAnimation(context: UIViewControllerContextTransitioning, sourceView: UIView) {
        self.maskView.frame = context.containerView.bounds
        context.containerView.addSubview(self.maskView)
        context.containerView.addSubview(self.floatingView)
        self.maskView.alpha = 0
        self.floatingView2.isHidden = true
        let sourceRect = sourceView.convert(sourceView.bounds, to: context.containerView)
        self.floatingView.isHidden = false
        self.floatingView.frame = sourceRect
        self.floatingView.image = sourceView.snapshot()
        self.floatingView.alpha = 1
        context.view(forKey: .to)?.isHidden = true
        UIView.animate(withDuration: self.transitionDuration(using: context), delay: 0, options: .beginFromCurrentState) {
            //将图片动画到中心
            let size = sourceRect.size.scale(aspectFit: context.containerView.bounds.size)
            let x = context.containerView.bounds.midX - size.width/2
            let y = context.containerView.bounds.midY - size.height/2
            self.floatingView.frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
            self.maskView.alpha = 1
        } completion: { (_) in
            context.view(forKey: .to)?.alpha = 1
            self.floatingView.removeFromSuperview()
            self.floatingView2.removeFromSuperview()
            self.maskView.removeFromSuperview()
            context.view(forKey: .to)?.isHidden = false
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

    private func zoomScaleplayAppearingAnimation(context: UIViewControllerContextTransitioning) {

    }

    ///备选动画方案
    open func alternativeDismissAnimation(context: UIViewControllerContextTransitioning) {
        guard let fromVC = context.viewController(forKey: .from) else {
            context.completeTransition(!context.transitionWasCancelled)
            return
        }
        UIView.animate(withDuration: self.transitionDuration(using: context)) {
            fromVC.view.alpha = 0
        } completion: { (_) in
            fromVC.view.removeFromSuperview()
            context.completeTransition(!context.transitionWasCancelled)
        }
    }

}
