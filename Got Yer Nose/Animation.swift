//
//  ViewAnimations.swift
//  Uplift
//
//  Created by Adam Cobb on 9/25/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

extension UIView{
    func animate()->UIViewAnimationHelper{
        return UIViewAnimationHelper(view: self)
    }
}

class UIViewAnimationHelper{
    var view:UIView!
    var animations:[()->Void] = []
    var keyframeAnimations:[()->Void] = []
    var delay:Int64 = 0
    var duration:Int64 = 1
    var interpolator = Interpolator.linear
    var listener:AnimatorListener? = nil
    
    init(view:UIView) {
        self.view = view
        
        Async.run(SyncInterface(runTask: {
            
            let completionInKeyframeBlock = self.animations.isEmpty
            
            if let timingFunction = self.interpolator.definingFactior as? UIViewAnimationOptions{
                
                UIView.animate(withDuration: TimeInterval(self.duration) / 1000, delay: TimeInterval(self.delay) / 1000, options: [.beginFromCurrentState, .allowUserInteraction, timingFunction], animations: {
                    for animation in self.animations{
                        animation()
                    }
                    self.animations = []
                }, completion: {finished in
                    if finished && !completionInKeyframeBlock{
                        if let listener = self.listener{
                            listener.onAnimationEnd()
                        }
                    }
                })
                
            }else if let springDamping = self.interpolator.definingFactior as? CGFloat{
                UIView.animate(withDuration: TimeInterval(self.duration) / 1000, delay: TimeInterval(self.delay) / 1000, usingSpringWithDamping: springDamping, initialSpringVelocity: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                    for animation in self.animations{
                        animation()
                    }
                    self.animations = []
                }, completion: {finished in
                    if finished{
                        if let listener = self.listener{
                            listener.onAnimationEnd()
                        }
                    }
                })
            }
            
            UIView.animateKeyframes(withDuration: TimeInterval(self.duration) / 1000, delay: TimeInterval(self.delay) / 1000, options: [.beginFromCurrentState, .allowUserInteraction, .calculationModeLinear], animations: {
                for animation in self.keyframeAnimations{
                    animation()
                }
                self.keyframeAnimations = []
            }, completion: {finished in
                if finished && completionInKeyframeBlock{
                    if let listener = self.listener{
                        listener.onAnimationEnd()
                    }
                }
            })
        }))
    }
    
    func cancel(){
        self.view.layer.removeAllAnimations()
        Async.run(SyncInterface(runTask: {
            self.view.layer.removeAllAnimations()
        }))
    }
    
    func setStartDelay(_ delay:Int64)->UIViewAnimationHelper{
        self.delay = delay
        return self
    }
    
    func setDuration(_ duration:Int64)->UIViewAnimationHelper{
        self.duration = duration
        return self
    }
    
    func setInterpolator(_ interpolator:Interpolator)->UIViewAnimationHelper{
        self.interpolator = interpolator
        return self
    }
    
    func setListener(_ listener:AnimatorListener?)->UIViewAnimationHelper{
        self.listener = listener
        return self
    }
    
    func translationX(_ value:CGFloat)->UIViewAnimationHelper{
        animations.append({self.view.translationX = value})
        return self
    }
    
    func translationY(_ value:CGFloat)->UIViewAnimationHelper{
        animations.append({self.view.translationY = value})
        return self
    }
    
    func translationXBy(_ value:CGFloat)->UIViewAnimationHelper{
        return translationX(view.translationX + value)
    }
    
    func translationYBy(_ value:CGFloat)->UIViewAnimationHelper{
        return translationY(view.translationY + value)
    }
    
    func scaleX(_ value:CGFloat)->UIViewAnimationHelper{
        animations.append({
            self.view.scaleX = value
        })
        return self
    }
    
    func scaleY(_ value:CGFloat)->UIViewAnimationHelper{
        animations.append({
            self.view.scaleY = value
        })
        return self
    }
    
    func scaleXBy(_ value:CGFloat)->UIViewAnimationHelper{
        return scaleX(view.scaleX * value)
    }
    
    func scaleYBy(_ value:CGFloat)->UIViewAnimationHelper{
        return scaleY(view.scaleY * value)
    }
    
    func rotation(_ value:CGFloat)->UIViewAnimationHelper{
        let valueToGo = value - view.rotation
        if abs(valueToGo) < 180{
            animations.append({
                self.view.rotation = value
            })
        }else{
            keyframeAnimations.append({
                let iterations = ceil(abs(valueToGo) / 170) //170 is a number slightly less than 180
                for i in stride(from: 1, through: iterations, by: 1){
                    UIView.addKeyframe(withRelativeStartTime: Double((i - 1) / iterations), relativeDuration: 1 / Double(iterations), animations: {
                        self.view.rotation = value + (i / iterations - 1) * valueToGo
                    })
                }
            })
        }
        return self
    }
    
    func rotationBy(_ value:CGFloat)->UIViewAnimationHelper{
        return rotation(view.rotation + value)
    }
    
    func alpha(_ value:CGFloat)->UIViewAnimationHelper{
        animations.append({
            self.view.alpha = value
        })
        return self
    }
    
    func alphaBy(_ value:CGFloat)->UIViewAnimationHelper{
        return alpha(view.alpha + value)
    }
}

/*class UIViewAnimationHelper{
 var view:UIView!
 var animations:[(animation: CAAnimation, key: String, completion: ()->Void)] = []
 var delay:Int64 = 0
 var duration:Int64 = 1
 var timingFunction = Interpolator.linear.timingFunction
 var listener:AnimatorListener? = nil
 
 init(view:UIView) {
 self.view = view
 
 Async.run(SyncInterface(runTask: {
 
 CATransaction.begin()
 
 CATransaction.setCompletionBlock({
 for animation in self.animations{
 animation.completion()
 self.view.layer.removeAnimation(forKey: animation.key)
 }
 if let listener = self.listener{
 listener.onAnimationEnd()
 }
 })
 
 for animation in self.animations{
 animation.animation.fillMode = kCAFillModeForwards;
 animation.animation.isRemovedOnCompletion = false
 animation.animation.duration = CFTimeInterval(self.duration) / 1000
 animation.animation.timingFunction = self.timingFunction
 animation.animation.beginTime = CACurrentMediaTime() + CFTimeInterval(self.delay) / 1000
 self.view.layer.add(animation.animation, forKey: animation.key)
 }
 
 CATransaction.commit()
 }))
 }
 
 func cancel(){
 self.view.layer.removeAllAnimations()
 Async.run(SyncInterface(runTask: {
 self.view.layer.removeAllAnimations()
 }))
 }
 
 func setStartDelay(_ delay:Int64)->UIViewAnimationHelper{
 self.delay = delay
 return self
 }
 
 func setDuration(_ duration:Int64)->UIViewAnimationHelper{
 self.duration = duration
 return self
 }
 
 func setInterpolator(_ interpolator:Interpolator)->UIViewAnimationHelper{
 self.timingFunction = interpolator.timingFunction
 return self
 }
 
 func setListener(_ listener:AnimatorListener?)->UIViewAnimationHelper{
 self.listener = listener
 return self
 }
 
 private func addAnimation(_ key: String, toValue: Any, completion:@escaping ()->Void){
 self.view.layer.removeAnimation(forKey: key)
 let animation = CABasicAnimation(keyPath: key)
 animation.toValue = toValue
 animations.append((animation: animation, key: key, completion: completion))
 }
 
 func translationX(_ value:CGFloat)->UIViewAnimationHelper{
 addAnimation("transform.translation.x", toValue: value, completion: {
 self.view.translationX = value
 })
 return self
 }
 
 func translationY(_ value:CGFloat)->UIViewAnimationHelper{
 addAnimation("transform.translation.y", toValue: value, completion: {
 self.view.translationY = value
 })
 return self
 }
 
 func translationXBy(_ value:CGFloat)->UIViewAnimationHelper{
 return translationX(view.translationX + value)
 }
 
 func translationYBy(_ value:CGFloat)->UIViewAnimationHelper{
 return translationY(view.translationY + value)
 }
 
 func scaleX(_ value:CGFloat)->UIViewAnimationHelper{
 addAnimation("transform.scale.x", toValue: value, completion: {
 self.view.scaleX = value
 })
 return self
 }
 
 func scaleY(_ value:CGFloat)->UIViewAnimationHelper{
 addAnimation("transform.scale.y", toValue: value, completion: {
 self.view.scaleY = value
 })
 return self
 }
 
 func scaleXBy(_ value:CGFloat)->UIViewAnimationHelper{
 return scaleX(view.scaleX * value)
 }
 
 func scaleYBy(_ value:CGFloat)->UIViewAnimationHelper{
 return scaleY(view.scaleY * value)
 }
 
 func rotation(_ value:CGFloat)->UIViewAnimationHelper{
 addAnimation("transform.rotation", toValue: value * CGFloat(M_PI) / 180, completion: {
 self.view.rotation = value
 })
 return self
 }
 
 func rotationBy(_ value:CGFloat)->UIViewAnimationHelper{
 return rotation(view.rotation + value)
 }
 
 func alpha(_ value:CGFloat)->UIViewAnimationHelper{
 addAnimation("opacity", toValue: value, completion: {
 self.view.alpha = value
 })
 return self
 }
 
 func alphaBy(_ value:CGFloat)->UIViewAnimationHelper{
 return alpha(view.alpha + value)
 }
 }*/

class Interpolator{
    var type:Int!
    var definingFactior:Any!
    
    init(timingFunction:UIViewAnimationOptions){
        self.type = 1
        self.definingFactior = timingFunction
    }
    init(springDamping:CGFloat){
        self.type = 2
        self.definingFactior = springDamping
    }
    static let linear = Interpolator(timingFunction: .curveLinear)
    static let accelerate = Interpolator(timingFunction: .curveEaseIn)
    static let decelerate = Interpolator(timingFunction: .curveEaseOut)
    static let accelerateDecelerate = Interpolator(timingFunction: .curveEaseInOut)
    static let overshoot = Interpolator(springDamping:0.6)
    static let anticipate = Interpolator(springDamping:-0.8)
    static let bounce = decelerate
}

class AnimatorListener{
    var onAnimationEnd:()->Void
 
    init(onAnimationEnd:@escaping ()->Void){
        self.onAnimationEnd = onAnimationEnd
    }
}
