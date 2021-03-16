//
//  ProgressView.swift
//  RXCPageView
//
//  Created by ruixingchen on 2021/1/30.
//

import UIKit

///一个简单的圆环进度条
public final class ProgressView: UIView {

    public var progress: CGFloat = 0 {
        didSet {
            if Thread.isMainThread {
                self.updateProgress()
            }else {
                DispatchQueue.main.async {
                    self.updateProgress()
                }
            }
        }
    }

    public var trackColor: UIColor = UIColor.gray {
        didSet {
            self.trackLayer.strokeColor = self.trackColor.cgColor
        }
    }

    public var progressColor: UIColor = UIColor.blue {
        didSet {
            self.progressLayer.strokeColor = self.progressColor.cgColor
        }
    }

    public var trackWidth: CGFloat = 4 {
        didSet {
            self.trackLayer.lineWidth = self.trackWidth
            self.progressLayer.lineWidth = self.trackWidth
        }
    }

    ///圆环轨道Layer
    private let trackLayer: CAShapeLayer = CAShapeLayer.init()
    ///圆环进度Layer
    private let progressLayer: CAShapeLayer = CAShapeLayer.init()

    ///中间的title
    public var titleLabel = UILabel()

    ///当进度到达1.0的时候自动隐藏(设置自己的isHidden属性)
    public var hideAutomatically: Bool = true {
        didSet {
            self.checkHideAutomatically()
        }
    }

    public init() {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        self.initSetup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initSetup()
    }

    private func initSetup() {

        self.isUserInteractionEnabled = false

        self.titleLabel.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        self.titleLabel.minimumScaleFactor = 0.3
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.adjustsFontForContentSizeCategory = false
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = self.progressColor
        self.addSubview(self.titleLabel)

        self.trackLayer.strokeColor = self.trackColor.cgColor
        self.trackLayer.fillColor = UIColor.clear.cgColor
        self.trackLayer.path = self.calculateTrackPath()
        self.trackLayer.lineWidth = self.trackWidth

        self.progressLayer.strokeColor = self.progressColor.cgColor
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.path = self.calculateProgressPath(progress: self.progress)
        self.progressLayer.lineWidth = self.trackWidth
        self.progressLayer.lineCap = .round

        self.layer.addSublayer(self.trackLayer)
        self.layer.addSublayer(self.progressLayer)
    }

    private func updateProgress() {
        self.checkHideAutomatically()
        self.trackLayer.path = self.calculateTrackPath()
        self.progressLayer.path = self.calculateProgressPath(progress: self.progress)
        self.titleLabel.text = "\(Int(self.progress*100))%"
        self.setNeedsLayout()
    }

    ///生成轨道的path
    private func calculateTrackPath()->CGPath {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = Swift.min(self.bounds.width, self.bounds.height)/2 - self.trackWidth/2
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        return path.cgPath
    }

    ///生成进度条的path
    private func calculateProgressPath(progress: CGFloat)->CGPath {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = Swift.min(self.bounds.width, self.bounds.height)/2 - self.trackWidth/2
        let startAngle = -CGFloat.pi/2
        let endAngle = startAngle + 2*CGFloat.pi*progress
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        return path.cgPath
    }

    private func checkHideAutomatically() {
        if self.hideAutomatically {
            let hidden = self.progress >= 1.0 || self.progress < 0.0
            self.isHidden = hidden
        }
    }

    public override var intrinsicContentSize: CGSize {
        return CGSize.init(width: 44, height: 44)
    }

    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize.init(width: 44, height: 44)
    }

    public override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return CGSize.init(width: 44, height: 44)
    }

    public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize.init(width: 44, height: 44)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        var size = self.titleLabel.intrinsicContentSize
        size.width = self.bounds.width-self.trackWidth*2
        let x = self.bounds.midX - size.width/2
        let y = self.bounds.midY - size.height/2
        self.titleLabel.frame = CGRect.init(x: x, y: y, width: size.width, height: size.height)
        self.trackLayer.frame = self.bounds
        self.progressLayer.frame = self.bounds
        self.trackLayer.path = self.calculateTrackPath()
        self.progressLayer.path = self.calculateProgressPath(progress: self.progress)
    }

}

extension ProgressView: ProgressViewProtocol {

    ///任务开始
    public func onTaskStart() {
        self.progress = 0.0
    }

    ///任务进度变化
    public func onTaskProgress(_ progress: Float) {
        self.progress = CGFloat(progress)
    }

    ///任务结束
    public func onTaskFinish() {
        self.progress = 1.0
    }

}
