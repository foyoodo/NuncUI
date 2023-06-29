//
//  SlidingTransitionAnimator.swift
//  NuncUI
//
//  Created by foyoodo on 2023/6/21.
//  Copyright © 2023 foyoodo. All rights reserved.
//

import UIKit

public final class SlidingTransitionAnimator: ReversibleAnimator {

    public var slidingPosition: SlidingPosition = .default
    public var isOriginalTranslationEnabled = false

    public var transitionCompletion: ((_ isReverse: Bool, _ didComplete: Bool) -> Void)?

    public override func animateTransition(using transitionContext: UIViewControllerContextTransitioning, containerView: UIView, fromVC: UIViewController, toVC: UIViewController, fromView: UIView, toView: UIView) {
        if isReverse {
            var fromViewEndFrame = transitionContext.initialFrame(for: fromVC)
            switch slidingPosition {
            case let .top(offset):
                fromViewEndFrame.origin.y -= fromViewEndFrame.height + offset
            case let .left(offset):
                fromViewEndFrame.origin.x -= fromViewEndFrame.width + offset
            case let .right(offset):
                fromViewEndFrame.origin.x += fromViewEndFrame.width + offset
            case let .bottom(offset):
                fromViewEndFrame.origin.y += fromViewEndFrame.height + offset
            }
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: transitionContext.isInteractive ? .curveLinear : .curveEaseInOut) {
                fromView.frame = fromViewEndFrame
                if self.isOriginalTranslationEnabled {
                    toView.transform = .identity
                }
            } completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                self.transitionCompletion?(self.isReverse, !transitionContext.transitionWasCancelled)
            }
        } else {
            containerView.addSubview(toView)
            let toViewEndFrame = transitionContext.finalFrame(for: toVC)
            var toViewStartFrame = toViewEndFrame
            let fromViewTransform: CGAffineTransform
            switch slidingPosition {
            case let .top(offset):
                toViewStartFrame.origin.y -= toViewStartFrame.height + offset
                fromViewTransform = CGAffineTransform(translationX: 0, y: toViewEndFrame.height + offset)
            case let .left(offset):
                toViewStartFrame.origin.x -= toViewStartFrame.width + offset
                fromViewTransform = CGAffineTransform(translationX: toViewEndFrame.width + offset, y: 0)
            case let .right(offset):
                toViewStartFrame.origin.x += toViewStartFrame.width + offset
                fromViewTransform = CGAffineTransform(translationX: -(toViewEndFrame.width + offset), y: 0)
            case let .bottom(offset):
                toViewStartFrame.origin.y += toViewStartFrame.height + offset
                fromViewTransform = CGAffineTransform(translationX: 0, y: -(toViewEndFrame.height + offset))
            }
            toView.frame = toViewStartFrame
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: transitionContext.isInteractive ? .curveLinear : .curveEaseInOut) {
                toView.frame = toViewEndFrame
                if self.isOriginalTranslationEnabled {
                    fromView.transform = fromViewTransform
                }
            } completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                self.transitionCompletion?(self.isReverse, !transitionContext.transitionWasCancelled)
            }
        }
    }

}
