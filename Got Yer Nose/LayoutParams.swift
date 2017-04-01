//
//  LayoutParams.swift
//  Uplift
//
//  Created by Adam Cobb on 9/26/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class LayoutParams {
    
    static func setWidth(view:UIView, width:CGFloat){
        
        if Async.isAsync(){
            
        }
        
        if view.translatesAutoresizingMaskIntoConstraints{
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        var widthConstraint:NSLayoutConstraint!
        for constraint in view.constraints{
            if constraint.firstAttribute == .width && constraint.secondItem == nil{
                widthConstraint = constraint
            }
        }
        if widthConstraint != nil{
            widthConstraint!.constant = width
        }else{
            widthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
        }
        
        
        widthConstraint.isActive = true
    }
    
    static func setHeight(view:UIView, height:CGFloat){
        if Async.isAsync(){
            
        }
        
        if view.translatesAutoresizingMaskIntoConstraints{
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        var heightConstraint:NSLayoutConstraint!
        for constraint in view.constraints{
            if constraint.firstAttribute == .height && constraint.secondItem == nil{
                heightConstraint = constraint
            }
        }
        if heightConstraint != nil{
            heightConstraint!.constant = height
        }else{
            heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        }
        
        heightConstraint.isActive = true
    }
    
    static func setWidthHeight(view:UIView, width:CGFloat, height:CGFloat){
        setWidth(view: view, width: width)
        setHeight(view: view, height: height)
    }
    
    static func superviewReady(for view: UIView)->Bool{
        if let superview = view.superview{
            if !superview.insetsSet(){
                superview.setInsets(.zero)
            }
            return true
        }
        return false
    }
    
    static func setEqualConstraint(view1:UIView, attribute1: NSLayoutAttribute, view2:@escaping ()->UIView?, attribute2: NSLayoutAttribute?, margin:CGFloat, isReady:@escaping ()->Bool){
        
        if Async.isAsync(){
            
        }
        
        if view1.translatesAutoresizingMaskIntoConstraints{
            view1.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if !view1.clipsToBounds{
            view1.clipsToBounds = true
        }
        
        if isReady(){
            let attribute2:NSLayoutAttribute = attribute2 != nil ? attribute2! : .notAnAttribute
            let constraint = NSLayoutConstraint(item: view1, attribute: attribute1, relatedBy: .equal, toItem: view2(), attribute: attribute2, multiplier: 1, constant: margin)
            constraint.isActive = true
        }else{
            ViewController.context.constraintsToActivate.append((isReady, {
                let attribute2:NSLayoutAttribute = attribute2 != nil ? attribute2! : .notAnAttribute
                return NSLayoutConstraint(item: view1, attribute: attribute1, relatedBy: .equal, toItem: view2(), attribute: attribute2, multiplier: 1, constant: margin)
            }))
        }
    }
    
    static func setEqualConstraint(view1:UIView, attribute1: NSLayoutAttribute, view2:@escaping ()->UIView?, attribute2: NSLayoutAttribute?, isReady:@escaping ()->Bool){
        setEqualConstraint(view1: view1, attribute1: attribute1, view2: view2, attribute2: attribute2, margin: 0, isReady: isReady)
    }
    
    static func setEqualConstraint(view1:UIView, attribute1: NSLayoutAttribute, view2:UIView?, attribute2:NSLayoutAttribute?, margin:CGFloat){
        setEqualConstraint(view1: view1, attribute1: attribute1, view2: {return view2}, attribute2: attribute2, margin: margin, isReady:{
            if let view2 = view2{
                return view1.window == view2.window && view1.window != nil
            }else{
                return true
            }})
    }
    
    static func setEqualConstraint(view1:UIView, attribute1: NSLayoutAttribute, view2:UIView?, attribute2:NSLayoutAttribute?){
        setEqualConstraint(view1: view1, attribute1: attribute1, view2: view2, attribute2: attribute2, margin: 0)
    }
    
    static func alignLeft(view1:UIView, view2:UIView){
        setEqualConstraint(view1: view1, attribute1: .left, view2: view2, attribute2: .left)
    }
    
    static func alignRight(view1:UIView, view2:UIView){
        setEqualConstraint(view1: view1, attribute1: .right, view2: view2, attribute2: .right)
    }
    
    static func alignLeftRight(view1:UIView, view2:UIView){
        alignLeft(view1: view1, view2: view2)
        alignRight(view1: view1, view2: view2)
    }
    
    static func alignTop(view1:UIView, view2:UIView){
        setEqualConstraint(view1: view1, attribute1: .top, view2: view2, attribute2: .top)
    }
    
    static func alignBottom(view1:UIView, view2:UIView){
        setEqualConstraint(view1: view1, attribute1: .bottom, view2: view2, attribute2: .bottom)
    }
    
    static func alignTopBottom(view1:UIView, view2:UIView){
        alignTop(view1: view1, view2: view2)
        alignBottom(view1: view1, view2: view2)
    }
    
    static func alignParentLeft(subview:UIView, margin:CGFloat){
        setEqualConstraint(view1: subview, attribute1: .left, view2: {return subview.superview}, attribute2: .leftMargin, margin: margin, isReady:{return superviewReady(for: subview)})
    }
    
    static func alignParentRight(subview:UIView, margin:CGFloat){
        setEqualConstraint(view1: subview, attribute1: .right, view2: {return subview.superview}, attribute2: .rightMargin, margin: -margin, isReady:{return superviewReady(for: subview)})
    }
    
    static func alignParentLeftRight(subview:UIView, marginLeft:CGFloat, marginRight:CGFloat){
        alignParentLeft(subview: subview, margin: marginLeft)
        alignParentRight(subview: subview, margin: marginRight)
    }
    
    static func alignParentTop(subview:UIView, margin:CGFloat){
        setEqualConstraint(view1: subview, attribute1: .top, view2: {return subview.superview}, attribute2: .topMargin, margin: margin, isReady:{return superviewReady(for: subview)})
    }
    
    static func alignParentBottom(subview:UIView, margin:CGFloat){
        setEqualConstraint(view1: subview, attribute1: .bottom, view2: {return subview.superview}, attribute2: .bottomMargin, margin: -margin, isReady:{return superviewReady(for: subview)})
    }
    
    static func alignParentTopBottom(subview:UIView, marginTop:CGFloat, marginBottom:CGFloat){
        alignParentTop(subview: subview, margin: marginTop)
        alignParentBottom(subview: subview, margin: marginBottom)
    }
    
    static func alignParentLeft(subview:UIView){
        alignParentLeft(subview: subview, margin: 0)
    }
    
    static func alignParentRight(subview:UIView){
        alignParentRight(subview: subview, margin: 0)
    }
    
    static func alignParentLeftRight(subview:UIView){
        alignParentLeft(subview: subview)
        alignParentRight(subview: subview)
    }
    
    static func alignParentTop(subview:UIView){
        alignParentTop(subview: subview, margin: 0)
    }
    
    static func alignParentBottom(subview:UIView){
        alignParentBottom(subview: subview, margin: 0)
    }
    
    static func alignParentTopBottom(subview:UIView){
        alignParentTop(subview: subview)
        alignParentBottom(subview: subview)
    }
    
    static func alignParentScrollVertical(subview:UIView){
        alignParentLeftRight(subview: subview)
        alignParentTopBottom(subview: subview)
        setEqualConstraint(view1: subview, attribute1: .width, view2: {return subview.superview}, attribute2: .width, isReady:{return superviewReady(for: subview)})
    }
    
    static func alignParentScrollHorizontal(subview:UIView){
        alignParentLeftRight(subview: subview)
        alignParentTopBottom(subview: subview)
        setEqualConstraint(view1: subview, attribute1: .height, view2: {return subview.superview}, attribute2: .height, isReady:{return superviewReady(for: subview)})
    }
    
    static func centerParentHorizontal(subview:UIView){
        setEqualConstraint(view1: subview, attribute1: .centerX, view2: {return subview.superview}, attribute2: .centerX, isReady:{return superviewReady(for: subview)})
    }
    
    static func centerParentVertical(subview:UIView){
        setEqualConstraint(view1: subview, attribute1: .centerY, view2: {return subview.superview}, attribute2: .centerY, isReady:{return superviewReady(for: subview)})
    }
    
    static func stackVertical(topView:UIView, bottomView:UIView){
        setEqualConstraint(view1: bottomView, attribute1: .top, view2: topView, attribute2: .bottom)
    }
    
    static func stackHorizontal(leftView:UIView, rightView:UIView){
        setEqualConstraint(view1: rightView, attribute1: .left, view2: leftView, attribute2: .right)
    }
    
    static func stackVertical(topView:UIView, bottomView:UIView, margin:CGFloat){
        setEqualConstraint(view1: bottomView, attribute1: .top, view2: topView, attribute2: .bottom, margin: margin)
    }
    
    static func stackHorizontal(leftView:UIView, rightView:UIView, margin:CGFloat){
        setEqualConstraint(view1: rightView, attribute1: .left, view2: leftView, attribute2: .right, margin: margin)
    }
}
