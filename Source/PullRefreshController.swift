//
//  PullRefreshController.swift
//  edX
//
//  Created by Akiva Leffert on 8/26/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

private let StandardRefreshHeight : CGFloat = 80

public class PullRefreshView : UIView {
    fileprivate let spinner = SpinnerView()
    
    public init() {
        super.init(frame : CGRect.zero)
        accessibilityIdentifier = "PullRefreshView:view"
        spinner.accessibilityIdentifier = "PullRefreshView:spinner"
        addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self).offset(10)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: StandardRefreshHeight)
    }
    
    public var percentage : CGFloat = 1 {
        didSet {
            let totalAngle = CGFloat(2 * Double.pi * 2) // two full rotations
            let scale = (percentage * 0.9) + 0.1 // don't start from 0 scale because it looks weird
            spinner.transform = CGAffineTransform(rotationAngle: percentage * totalAngle).concatenating(CGAffineTransform(scaleX: scale, y: scale))
        }
    }
}

public protocol PullRefreshControllerDelegate : AnyObject {
    func refreshControllerActivated(controller : PullRefreshController)
}

public class PullRefreshController: NSObject, ContentInsetsSource {
    public weak var insetsDelegate : ContentInsetsSourceDelegate?
    public weak var delegate : PullRefreshControllerDelegate?
    private let view : PullRefreshView
    private var shouldStartOnTouchRelease : Bool = false
    
    private(set) var refreshing : Bool = false
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .clear
        refreshControl.backgroundColor = .clear
        return refreshControl
    }()
    
    public override init() {
        view = PullRefreshView()
        view.accessibilityIdentifier = "PullRefreshController:view"
        super.init()
    }
    
    public func setupInScrollView(scrollView : UIScrollView) {
        if !refreshControl.subviews.contains(view) {
            refreshControl.addSubview(view)
        }

        scrollView.refreshControl = refreshControl
        scrollView.contentInsetAdjustmentBehavior = .automatic
        
        view.snp.makeConstraints { make in
            make.center.equalTo(refreshControl)
        }

        scrollView.oex_addObserver(observer: self, forKeyPath: "bounds") { (observer, scrollView, _) -> Void in
            self.scrollViewDidScroll(scrollView: scrollView)
        }
    }
    
    private func triggered() {
        if !refreshing {
            refreshing = true
            refreshControl.beginRefreshing()
            view.spinner.startAnimating()
            self.insetsDelegate?.contentInsetsSourceChanged(source: self)
            self.delegate?.refreshControllerActivated(controller: self)
        }
    }
    
    public var affectsScrollIndicators : Bool {
        return false
    }
    
    public func endRefreshing() {
        refreshControl.endRefreshing()
        refreshing = false
        UIView.animate(withDuration: 0.3) {
            self.insetsDelegate?.contentInsetsSourceChanged(source: self)
        }
    }
    
    public var currentInsets : UIEdgeInsets {
        return .zero
    }
    
    public func scrollViewDidScroll(scrollView : UIScrollView) {
        let pct = max(0, min(1, -scrollView.bounds.minY / view.frame.height))
        if !refreshing && scrollView.isDragging {
            self.view.percentage = pct
        }
        else {
            self.view.percentage = 1
        }
        if pct >= 1 && scrollView.isDragging {
            shouldStartOnTouchRelease = true
        }
        if shouldStartOnTouchRelease && !scrollView.isDragging {
            triggered()
            shouldStartOnTouchRelease = false
        }
    }
    
}
