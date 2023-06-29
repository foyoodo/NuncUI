//
//  BaseInteractiveTransition.swift
//  NuncUI
//
//  Created by foyoodo on 2023/6/21.
//  Copyright © 2023 foyoodo. All rights reserved.
//

import UIKit

public enum InteractiveOperation {
    case present
    case dismiss
}

open class BaseInteractiveTransition: UIPercentDrivenInteractiveTransition {

    open var viewController: UIViewController?

    open var isInteractive = false

    open func wire(to viewController: UIViewController, for operation: InteractiveOperation) {
        self.viewController = viewController
    }

}
