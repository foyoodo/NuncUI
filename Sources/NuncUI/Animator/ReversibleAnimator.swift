//
//  ReversibleAnimator.swift
//  NuncUI
//
//  Created by foyoodo on 2023/6/17.
//  Copyright © 2023 foyoodo. All rights reserved.
//

import UIKit

open class ReversibleAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    public var isReverse = false

    open var duration: TimeInterval { 0.3 }

    public func reverse(_ isReverse: Bool) -> Self {
        self.isReverse = isReverse
        return self
    }

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to)
        else {
            return
        }
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        animateTransition(using: transitionContext, containerView: containerView, fromVC: fromVC, toVC: toVC, fromView: fromView ?? fromVC.view, toView: toView ?? toVC.view)
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning, containerView: UIView, fromVC: UIViewController, toVC: UIViewController, fromView: UIView, toView: UIView) {

    }

}
