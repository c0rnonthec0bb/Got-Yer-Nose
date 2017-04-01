//
//  String.swift
//  Uplift
//
//  Created by Adam Cobb on 9/5/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
extension String{
    func length()->Int{
        return self.characters.count
    }
    
    func contains(_ s: String) -> Bool
    {
        return self.range(of: s) != nil
    }
    
    func replace(_ target: String, _ replacement: String) -> String
    {
        return self.replacingOccurrences(of: target, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func toString()->String{
        return self
    }
    
    func toUpperCase()->String{
        return self.uppercased()
    }
    
    func toLowerCase()->String{
        return self.lowercased()
    }
    
    func contentEquals(_ s:String)->Bool{
        return self == s
    }
    
    func substring(_ start:Int)->String{
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: start))
    }
    
    func substring(_ start:Int, _ end:Int)->String{
        return self.substring(with: self.characters.index(self.startIndex, offsetBy: start) ..< self.characters.index(self.startIndex, offsetBy: end))
    }
    
    func charAt(_ index:Int)->String{
        return self.substring(index, index + 1)
    }
    
    func indexOf(_ string: String) -> Int
    {
        if let range = self.range(of: string) {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    func indexOf(_ string: String, _ start: Int) -> Int
    {
        let indexInSub = self.substring(start).indexOf(string)
        if indexInSub != -1{
            return indexInSub + start
        }else{
            return -1
        }
    }
    
    func lastIndexOf(_ string: String) -> Int
    {
        if let range = self.range(of: string, options: .backwards) {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(_ string: String, _ start:Int) -> Int
    {
        return self.substring(0, start).lastIndexOf(string)
    }
    
    func replaceAll(_ regularExpression:String, _ replacement:String)->String{
        return self.replace(regularExpression, replacement)
    }
    
    func startsWith(_ prefix:String)->Bool{
        return self.hasPrefix(prefix)
    }
    
    func endsWith(_ suffix:String)->Bool{
        return self.hasSuffix(suffix)
    }
}
