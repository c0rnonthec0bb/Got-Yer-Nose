//
//  Color.swift
//  Uplift
//
//  Created by Adam Cobb on 9/6/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit

extension Color{ //Uplift specific colors
    @nonobjc static let theme_light0_25 = Color("#c0e0d0") //<!-- 192 224 208 -->  <!-- 256 - (256 - n) * 0.25 -->
    @nonobjc static let theme_light0_5 = Color("#80c0a0") //<!-- 128 192 160 -->  <!-- 256 - (256 - n) * 0.5-->
    @nonobjc static let theme_light0_625 = Color("#60b088") //<!-- 96 176 136 --> <!-- 256 - (256 - n) * 0.625-->
    @nonobjc static let theme_light0_75 = Color("#40a070") //<!-- 64 160 112 -->  <!-- 256 - (256 - n) * 0.75-->
    @nonobjc static let theme = Color("#008040") //<!-- 0 128 64 -->  <!-- n -->
    @nonobjc static let theme_0_875 = Color("#007038") //<!-- 0 112 56 -->  <!-- n * 0.875 -->
    @nonobjc static let theme_0_75 = Color("#006030") //<!-- 0 96 48 -->  <!-- n * 0.75 -->
    @nonobjc static let theme_0_625 = Color("#005025") //<!-- 0 80 40-->  <!-- n * 0.625 -->
    @nonobjc static let theme_0_5 = Color("#004020") //<!-- 0 64 32 -->  <!-- n * 0.5 -->
    @nonobjc static let theme_0_25 = Color("#002010") //<!-- 0 64 32 -->  <!-- n * 0.25 -->
    @nonobjc static let theme_bold = Color("#00c060")
    @nonobjc static let main_background = Color("#ccc")
    @nonobjc static let title_background = Color("#ddd")
    @nonobjc static let title_extension = Color("#ccc")
    @nonobjc static let title_touch = Color("#ccc")
    @nonobjc static let title_touch_extra = Color("#bbb")
    @nonobjc static let title_highlight = Color("#aaa")
    @nonobjc static let title_textColor = Color("#000")
    @nonobjc static let view_touch = Color("#12000000")
    @nonobjc static let view_touchOpaque = Color("#ededed")
    @nonobjc static let side_color = Color("#ddd")
    @nonobjc static let content_back = Color("#f6f6f6")
    @nonobjc static let textColor = Color("#000")
    @nonobjc static let linkColor = Color("#07d")
    @nonobjc static let youtubeColor = Color("#cd201f")
    @nonobjc static let nameColor = Color.textColor
    @nonobjc static let locationColor = Color("#808080")
    @nonobjc static let timeColor = Color("#808080")
    @nonobjc static let commentsColor = Color("#808080")
    @nonobjc static let flagColor = Color("#808080")
    @nonobjc static let flaggedColor = Color("#f08000")
    @nonobjc static let dialog_back = Color("#e0e0e0")
    @nonobjc static let halfBlack = Color("#888")
}

class Color:UIColor{
    
    @nonobjc static let WHITE = Color("#FFF")
    @nonobjc static let BLACK = Color("#000")
    
    convenience init(alpha: Int, red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }
    
    static fileprivate func charToInt(_ char:String)->Int{
        if let digit = Int(char){
            return digit
        }else{
            let a = "a"
            return Int(char.unicodeScalars.first!.value) - Int(a.unicodeScalars.first!.value) + 10
        }
    }
    
    convenience init(_ colorHex: String){
        var colorHex = colorHex
        
        var alpha:Int = 0, red:Int = 0, green:Int = 0, blue:Int = 0;
        if colorHex.charAt(0) == "#"{
            colorHex = colorHex.substring(1)
        }
        colorHex = colorHex.toLowerCase()
        switch(colorHex.length()){
        case 3:
            alpha = 255;
            red = Color.charToInt(colorHex.charAt(0)) * 17
            green = Color.charToInt(colorHex.charAt(1)) * 17
            blue = Color.charToInt(colorHex.charAt(2)) * 17
        case 4:
            alpha = Color.charToInt(colorHex.charAt(0)) * 17
            red = Color.charToInt(colorHex.charAt(1)) * 17
            green = Color.charToInt(colorHex.charAt(2)) * 17
            blue = Color.charToInt(colorHex.charAt(3)) * 17
            break;
        case 6:
            alpha = 255;
            red = Color.charToInt(colorHex.charAt(0)) * 16 + Color.charToInt(colorHex.charAt(1))
            green = Color.charToInt(colorHex.charAt(2)) * 16 + Color.charToInt(colorHex.charAt(3))
            blue = Color.charToInt(colorHex.charAt(4)) * 16 + Color.charToInt(colorHex.charAt(5))
            break;
        case 8:
            alpha = Color.charToInt(colorHex.charAt(0)) * 16 + Color.charToInt(colorHex.charAt(1))
            red = Color.charToInt(colorHex.charAt(2)) * 16 + Color.charToInt(colorHex.charAt(3))
            green = Color.charToInt(colorHex.charAt(4)) * 16 + Color.charToInt(colorHex.charAt(5))
            blue = Color.charToInt(colorHex.charAt(6)) * 16 + Color.charToInt(colorHex.charAt(7))
            break;
        default:
            break;
        }
        
        self.init(alpha: alpha, red: red, green: green, blue: blue)
    }
    
    convenience init(x8 netHex:Int) {
        
        self.init(alpha: (netHex >> 24) & 0xff, red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    convenience init(x6 netHex:Int) {
        
        self.init(alpha: 0xff, red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    convenience init(x4 netHex:Int) {
        
        self.init(alpha: ((netHex >> 12) & 0xf) * 0x11, red:((netHex >> 8) & 0xf) * 0x11, green:((netHex >> 4) & 0xf) * 0x11, blue: (netHex & 0xf) * 0x11)
    }
    
    convenience init(x3 netHex:Int) {
        
        self.init(alpha: 0xff, red:((netHex >> 8) & 0xf) * 0x11, green:((netHex >> 4) & 0xf) * 0x11, blue: (netHex & 0xf) * 0x11)
    }
}

extension UIColor{
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
}
