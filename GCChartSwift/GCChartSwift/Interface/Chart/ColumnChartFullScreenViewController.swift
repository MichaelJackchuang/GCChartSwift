//
//  ColumnChartFullScreenViewController.swift
//  DemosInSwift
//
//  Created by 古创 on 2021/1/13.
//  Copyright © 2021 c. All rights reserved.
//

import UIKit

class ColumnChartFullScreenViewController: BaseViewController {
    
    // MARK: - rotate
    override var shouldAutorotate: Bool{
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .landscapeRight
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return .landscapeRight
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isPop() {
            setDeviceOrientation(orientation: .portrait)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "柱状图(横屏)"
        
        setDeviceOrientation(orientation: .landscapeRight)
        
        setUI()
    }
    
    func setUI() {
        
    }

}
