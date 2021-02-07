//
//  UIColor+Extension.swift
//  DemosInSwift
//
//  Created by gc on 2020/3/19.
//  Copyright © 2020 c. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func colorWithHexString(color:String, alpha:CGFloat = 1.0) -> UIColor {
        
        // 删除字符串中的空格
        var cString = color.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()// 转大写
        
        // 少于6个字符则是透明色
        if cString.count < 6 {
            return UIColor.clear
        }
        
        // 0x开头则截取字符串
        if cString.hasPrefix("0x") {
            cString = String(cString.suffix(6))
        }
        
        // #开头则截取字符串
        if cString.hasPrefix("#") {
            cString = String(cString.suffix(6))
        }
        
        if cString.count != 6 {
            return UIColor.clear
        }
        
        var range = NSRange()
        range.location = 0
        range.length = 2
        
        // red
        let rString = cString.prefix(2)
        
        // green
        let gString = cString.prefix(4).suffix(2)
        
        // blue
        let bString = cString.suffix(2)
        
        var r:UInt32 = 0
        var g:UInt32 = 0
        var b:UInt32 = 0
        Scanner.init(string: String(rString)).scanHexInt32(&r)
        Scanner.init(string: String(gString)).scanHexInt32(&g)
        Scanner.init(string: String(bString)).scanHexInt32(&b)
        
        return UIColor.init(red: CGFloat(Double(r) / 255.0), green: CGFloat(Double(g) / 255.0), blue: CGFloat(Double(b) / 255.0), alpha: alpha)
    }
    
//    class func colorWithHexString(color:String) -> UIColor{
//        return colorWithHexString(color: color, alpha: 1.0)
//    }
}
