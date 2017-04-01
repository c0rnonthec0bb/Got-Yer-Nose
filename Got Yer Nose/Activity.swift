//
//  Activity.swift
//  Uplift
//
//  Created by Adam Cobb on 12/31/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class UIViewControllerX : UIViewController{
    
    private var constraintsToActivateX:[(isReady:()->Bool, constraint:()->NSLayoutConstraint)] = []
    
    var constraintsToActivate:[(isReady:()->Bool, constraint:()->NSLayoutConstraint)]{
        get{
            return constraintsToActivateX
        }
        set(value){
            constraintsToActivateX = value
            view.setNeedsUpdateConstraints()
        }
    }
    
    override func updateViewConstraints() {
        for i in stride(from: constraintsToActivateX.count - 1, through: 0, by: -1){
            let item = constraintsToActivateX[i];
            if item.isReady(){
                item.constraint().isActive = true
                self.constraintsToActivateX.remove(at: i)
            }
        }
        super.updateViewConstraints()
    }
    
    var views = NSHashTable<UIView>(options: [.weakMemory])
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        Async.run(SyncInterface(runTask: {
            self.stuffForEachView(self.view)
            for item in ViewHelper.onDidLayoutSubviews{
                if item.key.window != nil{
                    item.value()
                }
            }
            self.freeViews()
        }))
    }
    
    func stuffForEachView(_ view:UIView){
        if !views.contains(view){
            views.add(view)
        }
        view.layer.bounds = view.bounds
        for subview in view.subviews{
            stuffForEachView(subview)
        }
    }
    
    func onStart(){
    }
    
    func onResume() {}
    
    func onPause(){
    }
    
    func onStop(){
        freeViews()
    }
    
    func freeViews(){
        let views = self.views.allObjects
        for view in views{
            
            if view.window == nil{
                self.views.remove(view)
                ViewHelper.onDidLayoutSubviews.removeValue(forKey: view)
                objc_removeAssociatedObjects(view)
            }
        }
    }
    
}
