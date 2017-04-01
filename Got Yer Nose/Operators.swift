//
//  Operators.swift
//  Uplift
//
//  Created by Adam Cobb on 1/2/17.
//  Copyright © 2017 Adam Cobb. All rights reserved.
//

import UIKit

//CGPoint

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func max(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
    return CGPoint(x: max(left.x, right.x), y: max(left.y, right.y))
}

public func min(_ left: CGPoint, _ right: CGPoint) -> CGPoint {
    return CGPoint(x: min(left.x, right.x), y: min(left.y, right.y))
}

public func / (left: CGPoint, right: CGFloat)->CGPoint{
    return CGPoint(x: left.x / right, y: left.y / right)
}

public func * (left: CGPoint, right: CGFloat)->CGPoint{
    return CGPoint(x: left.x * right, y: left.y * right)
}

public func hypot(_ point: CGPoint)->CGFloat{
    return hypot(point.x, point.y)
}

//CGSize

public func * (left: CGSize, right: CGFloat)->CGSize{
    return CGSize(width: left.width * right, height: left.height * right)
}

public func / (left: CGSize, right: CGFloat)->CGSize{
    return CGSize(width: left.width / right, height: left.height / right)
}

//CGRect

public func * (left: CGRect, right: CGFloat)->CGRect{
    return CGRect(origin: left.origin * right, size: left.size * right)
}
