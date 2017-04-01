//
//  Date.swift
//  Uplift
//
//  Created by Adam Cobb on 1/3/17.
//  Copyright © 2017 Adam Cobb. All rights reserved.
//

import Foundation

extension Date{
    var timeInMillis:Int64{
        return Int64(timeIntervalSince1970 * 1000)
    }
}
