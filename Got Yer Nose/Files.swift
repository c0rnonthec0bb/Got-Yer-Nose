//
//  Files.swift
//  Uplift
//
//  Created by Adam Cobb on 9/6/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import UIKit
import Foundation

open class Files {
    
    static func deleteFile(_ name:String){
        UserDefaults.standard.removeObject(forKey: name)
    }
    
    static func writeObject<T:Any>(_ name:String, _ value:T){
        UserDefaults.standard.set(value, forKey: name)
    }
    
    static func readObject<T:Any>(_ name:String, _ def:T)->T{
        if let result = UserDefaults.standard.object(forKey: name) as? T{
            return result
        }
        return def
    }
    
    static func writeString(_ name:String, _ value:String){
        writeObject(name, value)
    }
    
    static func readString(_ name:String, _ def:String)->String{
        return readObject(name, def)
    }
    
    static func writeStringList(_ name:String, _ value:[String]){
        writeObject(name, value)
    }
    
    static func readStringList(_ name:String, _ def:[String])->[String]{
        return readObject(name, def)
    }
    
    static func writeBoolean(_ name:String, _ value:Bool){
        writeObject(name, value)
    }
    
    static func readBoolean(_ name:String, _ def:Bool)->Bool{
        return readObject(name, def)
    }
    
    static func writeInteger(_ name:String, _ value:Int){
        writeObject(name, value)
    }
    
    static func readInteger(_ name:String, _ def:Int)->Int{
        return readObject(name, def)
    }
    
    static func writeDouble(_ name:String, _ value:Double){
        writeObject(name, value)
    }
    
    static func readDouble(_ name:String, _ def:Double)->Double{
        return readObject(name, def)
    }
    
    static func writeImage(_ name:String, _ value:UIImage){
        writeObject(name, value)
    }
    
    static func readImage(_ name:String, _ def:UIImage)->UIImage{
        return readObject(name, def)
    }
    
    static func writeData(_ name:String, _ value:Data){
        writeObject(name, value)
    }
    
    static func readData(_ name:String, _ def:Data)->Data{
        return readObject(name, def)
    }
    
}
