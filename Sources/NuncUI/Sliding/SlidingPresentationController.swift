//
//  SlidingPresentationController.swift
//  NuncUI
//
//  Created by foyoodo on 2023/6/21.
//  Copyright © 2023 foyoodo. All rights reserved.
//

import UIKit

public final class SlidingPresentationController: UIPresentationController {

    public var slidingPosition: SlidingPosition = .default
    public var slidingInteractiveTransition: SlidingInteractiveTransition?

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOverlay(_:))))
        return view
    }()

    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }

        var frame = containerView.bounds
        let preferredContentSize = presentedViewController.preferredContentSize

        switch slidingPosition {
        case let .top(offset):
            frame.origin.y += offset
            frame.size.height = preferredContentSize.height
        case let .left(offset):
            frame.origin.x += offset
            frame.size.width = preferredContentSize.width
        case let .right(offset):
            frame.origin.x += frame.width - (preferredContentSize.width + offset)
            frame.size.width = preferredContentSize.width
        case let .bottom(offset):
            frame.origin.y += frame.height - (preferredContentSize.height + offset)
            frame.size.height = preferredContentSize.height
        }

        return frame
    }

    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        guard let containerView = containerView else {
            return
        }

        slidingInteractiveTransition?.prepareGestureRecognizer(for: containerView, operation: .dismiss)

        let frame = frameOfPresentedViewInContainerView
        if frame != .zero {
            presentedView?.frame = frame
        }
        overlayView.frame = containerView.bounds
    }

    public override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        containerView?.insertSubview(overlayView, at: 0)

        guard let transitionCoordinator = presentedViewController.transitionCoordinator, transitionCoordinator.isAnimated else {
            return
        }

        overlayView.alpha = 0
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.overlayView.alpha = 1
        })
    }

    public override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()

        guard let transitionCoordinator = presentedViewController.transitionCoordinator, transitionCoordinator.isAnimated else {
            return
        }

        transitionCoordinator.animate(alongsideTransition: { _ in
            self.overlayView.alpha = 0
        })
    }

}

extension SlidingPresentationController {
    @objc private func onOverlay(_: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
}
