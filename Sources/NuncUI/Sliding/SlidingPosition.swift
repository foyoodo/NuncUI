//
//  SlidingPosition.swift
//  NuncUI
//
//  Created by foyoodo on 2023/6/21.
//  Copyright © 2023 foyoodo. All rights reserved.
//

import Foundation

public enum SlidingPosition {
    case top(CGFloat)
    case left(CGFloat)
    case right(CGFloat)
    case bottom(CGFloat)

    public static var `default`: Self { .left      }
    public static var  top     : Self { .top(0)    }
    public static var  left    : Self { .left(0)   }
    public static var  right   : Self { .right(0)  }
    public static var  bottom  : Self { .bottom(0) }
}
