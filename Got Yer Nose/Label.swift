//
//  super.swift
//  Uplift
//
//  Created by Adam Cobb on 11/7/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

class UILabelX:UIView{
    
    let label = UILabel()
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero)
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init(){
        self.init(coder: nil)
        addSubview(label)
        LayoutParams.alignParentLeftRight(subview: label)
        LayoutParams.alignParentTopBottom(subview: label)
        numberOfLines = 0
    }
    
    var text:String?{
        get{
            return label.text
        }
        
        set(value){
            if Async.isAsync(){
                Async.run(SyncInterface(runTask: {
                    self.text = value
                }))
                return
            }
            label.text = value
        }
    }
    
    var textColor:UIColor!{
        get{
            return label.textColor
        }
        
        set(value){
            if Async.isAsync(){
                Async.run(SyncInterface(runTask: {
                    self.textColor = value
                }))
                return
            }
            label.textColor = value
        }
    }
    
    var font:UIFont!{
        get{
            return label.font
        }
        
        set(value){
            if Async.isAsync(){
                Async.run(SyncInterface(runTask: {
                    self.font = value
                }))
                return
            }
            label.font = value
        }
    }
    
    var textAlignment:NSTextAlignment{
        get{
            return label.textAlignment
        }
        
        set(value){
            if Async.isAsync(){
                Async.run(SyncInterface(runTask: {
                    self.textAlignment = value
                }))
                return
            }
            label.textAlignment = value
        }
    }
    
    var numberOfLines:Int{
        get{
            return label.numberOfLines
        }
        
        set(value){
            if Async.isAsync(){
                Async.run(SyncInterface(runTask: {
                    self.numberOfLines = value
                }))
                return
            }
            label.numberOfLines = value
        }
    }
    
    var lineBreakMode:NSLineBreakMode{
        get{
            return label.lineBreakMode
        }
        
        set(value){
            if Async.isAsync(){
                Async.run(SyncInterface(runTask: {
                    self.lineBreakMode = value
                }))
                return
            }
            label.lineBreakMode = value
        }
    }
    
    override var intrinsicContentSize: CGSize{
        get{
            var result = label.intrinsicContentSize
            
            if result.height <= 0{
                result.height = "A".boundingRect(with: CGSize(width: .max, height: .max), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).height
            }
            
            result.width += getInsets().left + getInsets().right
            result.height += getInsets().top + getInsets().bottom
            
            return result
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = size
        size.width -= getInsets().left + getInsets().right
        size.height -= getInsets().top + getInsets().bottom
        
        var result = label.sizeThatFits(size)
        
        if result.height <= 0{
            result.height = "A".boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil).height
            print("new height: " + result.height.description)
        }
        result.width += getInsets().left + getInsets().right
        result.height += getInsets().top + getInsets().bottom
        print("label size that fits: " + size.debugDescription + " " + result.debugDescription)
        return result
    }
    
    func setTextFromHtml(_ text: String){
        
        if Async.isAsync(){
            Async.run(SyncInterface(runTask: {
                self.setTextFromHtml(text)
            }))
            return
        }
        
        do{
            
            var textPlus = "<div style=\"text-align:center; margin: 0 !important; padding: 0 !important; "
            textPlus += "font-family: " + font.familyName + "; "
            textPlus += "font-size: " + font.pointSize.description + "px; "
            textPlus += "color: " + textColor.toHexString()
            textPlus += "\">" + text + "</div>"
        let attributedText = try NSAttributedString(data: textPlus.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            label.attributedText = attributedText
        }catch{
            self.text = text
        }
    }
}

class UIEditLabelX: UITextView, UITextViewDelegate{
    
    private var _underLineColor:UIColor = Color.halfBlack
    var underlineColor:UIColor{
        get{
            return _underLineColor
        }
        set(value){
            _underLineColor = value
            setNeedsDisplay()
        }
    }
    
    private var _underlineHeight:CGFloat = 1
    var underlineHeight:CGFloat{
        get{
            return _underlineHeight
        }
        set(value){
            _underlineHeight = value
            setNeedsDisplay()
        }
    }
    
    var numberOfLines:Int{
        get{
            return textContainer.maximumNumberOfLines
        }
        set(value){
            textContainer.maximumNumberOfLines = value
        }
    }
    
    required init(coder:NSCoder?){
        
        if coder == nil{
            super.init(frame: .zero, textContainer: nil)
        }else{
            super.init(coder: coder!)!
        }
    }
    
    convenience init(){
        self.init(coder: nil)
        numberOfLines = 0
        backgroundColor = .clear
        textContainer.lineFragmentPadding = 0
        setInsets(UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 4))
        isScrollEnabled = false
        
        ViewHelper.onDidLayoutSubviews[self] = {
            self.setNeedsDisplay()
        }
        
        self.delegate = self
    }
    
    override func setInsets(_ insets: UIEdgeInsets) {
        super.setInsets(insets)
        textContainerInset = insets
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()!
        let underline = CGRect(x: rect.origin.x + getInsets().left,y: rect.origin.y + rect.height - getInsets().bottom + 2, width: rect.width - getInsets().left - getInsets().right, height: underlineHeight)
        context.setFillColorSpace(CGColorSpaceCreateDeviceRGB())
        context.setFillColor(underlineColor.cgColor)
        context.fill(underline)
    }
    
    var onTextChanged:[((String)->Void)] = []
    
    override var text: String!{
        get{
            return super.text
        }
        set(value){
            
            super.text = value
            
            for function in self.onTextChanged{
                function(value)
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        text = super.text
    }
    
    var onFocusChanged:((Bool)->Void)!
    
    override func becomeFirstResponder()->Bool{
        if let onFocusChanged = self.onFocusChanged{
            onFocusChanged(true)
        }
        underlineHeight = 2
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder()->Bool{
        if let onFocusChanged = self.onFocusChanged{
            onFocusChanged(false)
        }
        underlineHeight = 1
        return super.resignFirstResponder()
    }
}

class UIEditFieldX: UITextField{
    
    private var _underLineColor:UIColor = Color.halfBlack
    var underlineColor:UIColor{
        get{
            return _underLineColor
        }
        set(value){
            _underLineColor = value
            setNeedsDisplay()
        }
    }
    
    private var _underlineHeight:CGFloat = 1
    var underlineHeight:CGFloat{
        get{
            return _underlineHeight
        }
        set(value){
            _underlineHeight = value
            setNeedsDisplay()
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
        backgroundColor = .clear
        setInsets(UIEdgeInsets(top: 12, left: 4, bottom: 12, right: 4))
        
        ViewHelper.onDidLayoutSubviews[self] = {
            self.setNeedsDisplay()
        }
        
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, getInsets())
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, getInsets())
    }
    
    override var intrinsicContentSize: CGSize{
        get{
            var result = text.boundingRect(with: CGSize(width: .max, height: .max), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font!], context: nil).size
            
            if result.height <= 0{
                result.height = "A".boundingRect(with: CGSize(width: .max, height: .max), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font!], context: nil).height
            }
            
            result.width += getInsets().left + getInsets().right
            result.height += getInsets().top + getInsets().bottom
            
            return result
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()!
        let underline = CGRect(x: rect.origin.x + getInsets().left,y: rect.origin.y + rect.height - getInsets().bottom + 2, width: rect.width - getInsets().left - getInsets().right, height: underlineHeight)
        context.setFillColorSpace(CGColorSpaceCreateDeviceRGB())
        context.setFillColor(underlineColor.cgColor)
        context.fill(underline)
    }
    
    var onTextChanged:[((String)->Void)] = []
    
    override var text: String!{
        get{
            return super.text
        }
        set(value){
            
            super.text = value
            
            for function in self.onTextChanged{
                function(value)
            }
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        text = super.text
    }
    
    var onFocusChanged:((Bool)->Void)!
    
    override func becomeFirstResponder()->Bool{
        if let onFocusChanged = self.onFocusChanged{
            onFocusChanged(true)
        }
        underlineHeight = 2
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder()->Bool{
        if let onFocusChanged = self.onFocusChanged{
            onFocusChanged(false)
        }
        underlineHeight = 1
        return super.resignFirstResponder()
    }
}

