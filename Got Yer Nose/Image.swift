//
//  Image.swift
//  Uplift
//
//  Created by Adam Cobb on 11/9/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

extension UIImage{
    func scaleImage(toSize newSize: CGSize) -> (UIImage) {
        let newSize = newSize / UIScreen.main.scale
        let newRect = CGRect(x: 0,y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = .high
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        context.concatenate(flipVertical)
        context.draw(self.cgImage!, in: newRect)
        let newImage = UIImage(cgImage: context.makeImage()!)
        UIGraphicsEndImageContext()
        return newImage
    }
    
        convenience init(view: UIView) {
            UIGraphicsBeginImageContext(view.frame.size)
            view.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.init(cgImage: (image?.cgImage)!)
        }
}

class UIImageViewX : UIView{
    let imageView = UIImageView()
    
    var image:UIImage?{
        get{
            return imageView.image
        }
        
        set(value){
            imageView.image = value
        }
    }
    
    override var contentMode:UIViewContentMode{
        get{
            return imageView.contentMode
        }
        
        set(value){
            imageView.contentMode = value
        }
    }
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero)
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init(){
        self.init(coder: nil)
        self.setInsets(.zero)
        self.addSubview(imageView)
        contentMode = .scaleAspectFit
        LayoutParams.alignParentLeftRight(subview: imageView)
        LayoutParams.alignParentTopBottom(subview: imageView)
    }
}
