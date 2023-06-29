//
//  SlidingInteractiveTransition.swift
//  NuncUI
//
//  Created by foyoodo on 2023/6/21.
//  Copyright © 2023 foyoodo. All rights reserved.
//

import UIKit

private var kPresentationPanGestureRecognizer: UInt8 = 0
private var kDismissalPanGestureRecognizer: UInt8 = 0

public final class SlidingInteractiveTransition: BaseInteractiveTransition {

    public weak var delegate: SlidingTransitioningDelegate? {
        didSet {
            delegate?.slidingInteractiveTransition = self
            if let delegate = delegate, dismissalWiringEnabled {
                wire(to: delegate.slidingViewController, for: .dismiss)
            }
        }
    }

    public var dismissalWiringEnabled: Bool

    private weak var presentingViewController: UIViewController?
    private weak var presentedViewController: UIViewController?

    private var shouldCompleteTransition = false

    public weak var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer?

    public override func wire(to viewController: UIViewController, for operation: InteractiveOperation) {
        super.wire(to: viewController, for: operation)

        switch operation {
        case .present:
            presentingViewController = viewController
            prepareGestureRecognizer(for: viewController.view, operation: operation)
        case .dismiss:
            presentedViewController = viewController
        }
    }

    public init(delegate: SlidingTransitioningDelegate, defaultDismissalWiring dismissalWiringEnabled: Bool = true) {
        self.delegate = delegate
        self.dismissalWiringEnabled = dismissalWiringEnabled

        super.init()

        delegate.slidingInteractiveTransition = self

        if dismissalWiringEnabled {
            wire(to: delegate.slidingViewController, for: .dismiss)
        }
    }

    public func prepareGestureRecognizer(for view: UIView, operation: InteractiveOperation) {
        switch operation {
        case .present:
            if let _ = objc_getAssociatedObject(self, &kPresentationPanGestureRecognizer) as? UIScreenEdgePanGestureRecognizer {
                return
            }
            let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePresentationPanGesture(_:)))
            edgePan.delegate = self
            objc_setAssociatedObject(self, &kPresentationPanGestureRecognizer, edgePan, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            switch delegate?.slidingPosition {
            case .right:
                edgePan.edges = .right
            default:
                edgePan.edges = .left
            }
            view.addGestureRecognizer(edgePan)
            screenEdgePanGestureRecognizer = edgePan
        case .dismiss:
            if let _ = objc_getAssociatedObject(self, &kDismissalPanGestureRecognizer) as? UIScreenEdgePanGestureRecognizer {
                return
            }
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPanGesture(_:)))
            objc_setAssociatedObject(self, &kDismissalPanGestureRecognizer, pan, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            view.addGestureRecognizer(pan)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SlidingInteractiveTransition: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

// MARK: - Actions
extension SlidingInteractiveTransition {
    @objc private func handlePresentationPanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            isInteractive = true
            if presentingViewController?.presentedViewController != nil {
                presentingViewController?.dismiss(animated: false)
            }
            if let slidingViewController = delegate?.slidingViewController {
                presentingViewController?.present(slidingViewController, animated: true)
            }
        case .changed:
            let translation = recognizer.translation(in: recognizer.view)
            let fraction = min(1, abs(translation.x / 380))
            let vel = recognizer.velocity(in: recognizer.view)
            shouldCompleteTransition = fraction > 0.2 || abs(vel.x) > 500
            update(fraction)
        case .cancelled, .ended:
            completionSpeed = 0.8
            completionCurve = .easeInOut
            shouldCompleteTransition ? finish() : cancel()
            isInteractive = false
        default: ()
        }
    }

    @objc private func handleDismissalPanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            isInteractive = true
            presentedViewController?.presentingViewController?.dismiss(animated: true)
        case .changed:
            let translation = recognizer.translation(in: recognizer.view)
            let velocity = recognizer.velocity(in: recognizer.view)
            let translationValue: CGFloat
            let velocityValue: CGFloat

            switch delegate?.slidingPosition {
            case .top:
                translationValue = -translation.y
                velocityValue = -velocity.y
            case .left:
                translationValue = -translation.x
                velocityValue = -velocity.x
            case .right:
                translationValue = translation.x
                velocityValue = velocity.x
            case .bottom:
                translationValue = translation.y
                velocityValue = velocity.y
            default:
                // Assume position left
                translationValue = -translation.x
                velocityValue = -velocity.x
            }

            let fraction = min(1, max(0, translationValue / 300))

            shouldCompleteTransition = velocityValue > 500 || (fraction > 0.5 && velocityValue > -100)

            update(fraction)
        case .cancelled, .ended:
            completionSpeed = 0.8
            completionCurve = .easeInOut
            shouldCompleteTransition ? finish() : cancel()
            isInteractive = false
        default: ()
        }
    }
}
