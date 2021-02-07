//
//  CircleRingChartViewController.swift
//  DemosInSwift
//
//  Created by 古创 on 2020/8/25.
//  Copyright © 2020 c. All rights reserved.
//

import UIKit

class CircleRingChartViewController: BaseViewController {

    
    @IBOutlet weak var ring1: GCCircleRingChartView!
    @IBOutlet weak var ring2: GCCircleRingChartView!
    
    var isBtnClicked:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "圆环图"
        
        setUI()
    }
    
    // MARK: - setUI
    func setUI() {
        let btn = UIButton(type: .system)
        btn.setTitle("重设", for: .normal)
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        ring1.pieDataNameArray = ["一工区","二工区","三工区"]
        ring1.pieDataArray = ["100","100","100"]
        ring1.lineWidth = 20
        ring1.showPercentage = false
        ring1.showCenterTitle = true
        ring1.centerTitle = "产值"
        ring1.resetData()
        
        ring2.pieDataNameArray = ["一工区","二工区","三工区"]
        ring2.pieDataArray = ["100","100","100"]
        ring2.radius = 80
        ring2.lineWidth = 30
        ring2.showPercentage = false
        ring2.showCenterTitle = true
        ring2.centerTitle = "产值"
        ring2.resetData()
    }
    
    @objc func btnAction() {
        if isBtnClicked {
            ring1.pieDataArray = ["100","100","100"]
            ring1.showPercentage = false
            
            ring2.pieDataNameArray = ["一工区","二工区","三工区"]
            ring2.pieDataArray = ["100","100","100"]
        } else {
            ring1.pieDataArray = ["100","200","300"]
            ring1.showPercentage = true
            
            ring2.pieDataNameArray = ["一工区","二工区","三工区","四工区","五工区"]
            ring2.pieDataArray = ["100","200","300","200","400"]
        }
        
        ring1.resetData()
        ring2.resetData()
        
        isBtnClicked = !isBtnClicked
    }

}
