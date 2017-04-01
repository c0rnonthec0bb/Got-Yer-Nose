//
//  Transform.swift
//  Uplift
//
//  Created by Adam Cobb on 12/26/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

extension CGAffineTransform{
    var scaleX:CGFloat{
        get{
            return sqrt(a*a+c*c)
        }
        set(value){
            let r = rotation
            a = value * cos(r)
            c = value * -sin(r)
        }
    }
    
    var scaleY:CGFloat{
        get{
            return sqrt(b*b+d*d)
        }
        set(value){
            let r = rotation
            b = value * sin(r)
            d = value * cos(r)
        }
    }
    
    var rotation:CGFloat{
        get{
            return atan2(b, a)
        }
        
        set(value){
            let sx = scaleX
            let sy = scaleY
            a = sx * cos(value)
            c = sx * -sin(value)
            b = sy * sin(value)
            d = sy * cos(value)
        }
    }
}

extension UIView{
    
    var scaleX:CGFloat{
        get{
            return transform.scaleX
        }
        set(value){
            transform.scaleX = value
        }
    }
    
    var scaleY:CGFloat{
        get{
            return transform.scaleY
        }
        set(value){
            transform.scaleY = value
        }
    }
    
    //this is in degrees!
    var rotation:CGFloat{
        get{
            return transform.rotation * 180 / CGFloat(M_PI)
        }
        
        set(value){
            transform.rotation = value * CGFloat(M_PI) / 180
        }
    }
    
    var translationX:CGFloat{
        get{
            return transform.tx
        }
        set(value){
            transform.tx = value
        }
    }
    
    var translationY:CGFloat{
        get{
            return transform.ty
        }
        set(value){
            transform.ty = value
        }
    }
    
    var width:CGFloat{
        get{
            let t = transform
            transform = .identity
            let value = frame.size.width
            transform = t
            return value
        }
        set(value){
            let t = transform
            transform = .identity
            frame.size.width = value
            transform = t
        }
    }
    
    var height:CGFloat{
        get{
            let t = transform
            transform = .identity
            let value = frame.size.height
            transform = t
            return value
        }
        set(value){
            let t = transform
            transform = .identity
            frame.size.height = value
            transform = t
        }
    }
    
    var x:CGFloat{
        get{
            let t = transform
            transform = .identity
            let value = frame.origin.x
            transform = t
            return value
        }
        set(value){
            let t = transform
            transform = .identity
            frame.origin.x = value
            transform = t
        }
    }
    
    var y:CGFloat{
        get{
            let t = transform
            transform = .identity
            let value = frame.origin.y
            transform = t
            return value
        }
        set(value){
            let t = transform
            transform = .identity
            frame.origin.y = value
            transform = t
        }
    }
    
    var originalOrigin:CGPoint{
        get{
            return CGPoint(x: x, y: y)
        }
        
        set(value){
            x = value.x
            y = value.y
        }
    }
    
    var originalSize:CGSize{
        get{
            return CGSize(width: width, height: height)
        }
        
        set(value){
            width = value.width
            height = value.height
        }
    }
    
    var originalFrame:CGRect{
        get{
            return CGRect(origin: originalOrigin, size: originalSize)
        }
        
        set(value){
            originalOrigin = value.origin
            originalSize = value.size
        }
    }
    
    var left:CGFloat{
        get{
            return measuredOrigin.x
        }
    }
    
    var top:CGFloat{
        get{
            return measuredOrigin.y
        }
    }
    
    var right:CGFloat{
        get{
            return left + measuredSize.width
        }
    }
    
    var bottom:CGFloat{
        get{
            return top + measuredSize.height
        }
    }
}
