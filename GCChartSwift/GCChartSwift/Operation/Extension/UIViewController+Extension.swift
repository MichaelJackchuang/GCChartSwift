//
//  UIViewController+Extension.swift
//  DemosInSwift
//
//  Created by 古创 on 2020/11/24.
//  Copyright © 2020 c. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // 替换方法
    static func swizzleBegin() {
        swizzleViewWillAppear()
    }
    
    // 替换viewWillAppear方法
    static func swizzleViewWillAppear() {
        // 要替换的方法
        let originalSelector = #selector(viewWillAppear(_:))
        let swizzledSelector = #selector(swizzleViewWillAppear(_:))
        
        // 获取实例方法
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {return}
        
        // 添加方法 如果本类包含同名的方法实现，则返回NO
        let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            // 则修改已存在的实现
            class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            // 交换方法实现
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    @objc func swizzleViewWillAppear(_ animated: Bool) {
        swizzleViewWillAppear(animated)
        
        debugPrint("siwzzledViewWillAppear")
    }
    
    func setDeviceOrientation(orientation: UIInterfaceOrientation){
        let num = NSNumber(value: orientation.rawValue)
        UIDevice.current.setValue(num, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func isPop() -> Bool{
        if let viewControllers = navigationController?.viewControllers {

            if viewControllers.count > 1 && viewControllers[viewControllers.count - 2] == self {
                print("New view controller was pushed")
                return false
            } else if viewControllers.firstIndex(of: self) == nil {
                print("View controller was popped")
                return true
            }
        }
        return false
    }
}
