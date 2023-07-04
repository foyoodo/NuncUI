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

    public enum PresentationGestureType {
        case screenEdgePan
        case pan
    }

    public weak var delegate: SlidingTransitioningDelegate? {
        didSet {
            delegate?.slidingInteractiveTransition = self
            if let delegate = delegate, dismissalWiringEnabled {
                wire(to: delegate.slidingViewController, for: .dismiss)
            }
        }
    }

    public var presentationGestureType: PresentationGestureType
    public var dismissalWiringEnabled: Bool

    private weak var presentingViewController: UIViewController?
    private weak var presentedViewController: UIViewController?

    private var shouldCompleteTransition = false

    public weak var presentationPanGestureRecognizer: UIPanGestureRecognizer?

    public var presentationWillBegin: (() -> Void)?

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

    public init(
        delegate: SlidingTransitioningDelegate,
        presentationGestureType: PresentationGestureType = .screenEdgePan,
        defaultDismissalWiring dismissalWiringEnabled: Bool = true
    ) {
        self.delegate = delegate
        self.presentationGestureType = presentationGestureType
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
            if objc_getAssociatedObject(self, &kPresentationPanGestureRecognizer) is UIPanGestureRecognizer {
                return
            }
            let pan: UIPanGestureRecognizer
            switch presentationGestureType {
            case .screenEdgePan:
                let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(self.handlePresentationPanGesture(_:)))
                switch delegate?.slidingPosition {
                case .right:
                    edgePan.edges = .right
                default:
                    edgePan.edges = .left
                }
                pan = edgePan
            case .pan:
                pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePresentationPanGesture(_:)))
            }
            pan.delegate = self
            view.addGestureRecognizer(pan)
            objc_setAssociatedObject(self, &kPresentationPanGestureRecognizer, pan, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            presentationPanGestureRecognizer = pan
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
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIScreenEdgePanGestureRecognizer {
            return true
        }

        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }

        let vel = pan.velocity(in: pan.view)

        switch delegate?.slidingPosition {
        case .right:
            return -vel.x > abs(vel.y) * 2
        default:
            return vel.x > abs(vel.y) * 2
        }
    }

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
                presentationWillBegin?()
                presentingViewController?.present(slidingViewController, animated: true)
            }
        case .changed:
            let res = transitionFraction(of: recognizer, operation: .present)
            shouldCompleteTransition = res.shouldCompleteTransition
            update(res.fraction)
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
            let res = transitionFraction(of: recognizer, operation: .dismiss)
            shouldCompleteTransition = res.shouldCompleteTransition
            update(res.fraction)
        case .cancelled, .ended:
            completionSpeed = 0.8
            completionCurve = .easeInOut
            shouldCompleteTransition ? finish() : cancel()
            isInteractive = false
        default: ()
        }
    }

    private func transitionFraction(of recognizer: UIPanGestureRecognizer, operation: InteractiveOperation) -> (fraction: CGFloat, shouldCompleteTransition: Bool) {
        let translation = recognizer.translation(in: recognizer.view)
        let velocity = recognizer.velocity(in: recognizer.view)
        let translationValue: CGFloat
        let velocityValue: CGFloat
        let multiplier: CGFloat

        switch operation {
        case .present:
            multiplier =  1.0
        case .dismiss:
            multiplier = -1.0
        }

        switch delegate?.slidingPosition {
        case .top:
            translationValue = translation.y * multiplier
            velocityValue = velocity.y * multiplier
        case .left:
            translationValue = translation.x * multiplier
            velocityValue = velocity.x * multiplier
        case .right:
            translationValue = translation.x * -multiplier
            velocityValue = velocity.x * -multiplier
        case .bottom:
            translationValue = translation.y * -multiplier
            velocityValue = velocity.y * -multiplier
        default:
            // Assume position left
            translationValue = translation.x * multiplier
            velocityValue = velocity.x * multiplier
        }

        let fraction = min(1, max(0, translationValue / 300))
        let shouldCompleteTransition = velocityValue > 500 || (fraction > 0.5 && velocityValue > -100)

        return (fraction, shouldCompleteTransition)
    }
}
