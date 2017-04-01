//
//  Array.swift
//  Uplift
//
//  Created by Adam Cobb on 12/23/16.
//  Copyright © 2016 Adam Cobb. All rights reserved.
//

import Foundation

extension Array where Element : AnyObject{
    func index(of:Element)->Int?{
        for i in 0 ..< count{
            if self[i] === of{
                return i;
            }
        }
        return nil;
    }
    
    mutating func remove(element:Element){
        while let index = index(of: element){
            let _ = self.remove(at: index)
        }
    }
}
