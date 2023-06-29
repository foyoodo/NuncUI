//
//  SlidingTransitioningDelegate.swift
//  NuncUI
//
//  Created by foyoodo on 2023/6/21.
//  Copyright © 2023 foyoodo. All rights reserved.
//

import UIKit

public protocol SlidingTransitioningDelegate: UIViewControllerTransitioningDelegate {
    var slidingTransitionAnimator: SlidingTransitionAnimator { get }
    var slidingInteractiveTransition: SlidingInteractiveTransition? { get set }
    var slidingViewController: UIViewController { get }
    var slidingPosition: SlidingPosition { get }
}

extension SlidingTransitioningDelegate where Self: UIViewController {
    public var slidingViewController: UIViewController {
        self
    }
}

public extension SlidingTransitioningDelegate {
    var slidingTransitionAnimator: SlidingTransitionAnimator {
        SlidingTransitionAnimator()
    }

    var slidingPosition: SlidingPosition {
        .default
    }
}

public extension SlidingTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slidingTransitionAnimator.reverse(false)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slidingTransitionAnimator.reverse(true)
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        slidingInteractiveTransition?.isInteractive == true ? slidingInteractiveTransition : nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        slidingInteractiveTransition?.isInteractive == true ? slidingInteractiveTransition : nil
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SlidingPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.slidingPosition = slidingPosition
        return presentationController
    }
}
