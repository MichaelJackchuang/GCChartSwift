//
//  BaseViewController.swift
//  GCChartSwift
//
//  Created by 古创 on 2021/2/7.
//

import UIKit

class BaseViewController: UIViewController {
    
    // 设备支持方向
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.colorWithHexString(color: "f4f6fb")
    }

}
