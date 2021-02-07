//
//  ColumnChartViewController.swift
//  DemosInSwift
//
//  Created by 古创 on 2020/8/25.
//  Copyright © 2020 c. All rights reserved.
//

import UIKit

class ColumnChartViewController: BaseViewController {
    
    @IBOutlet weak var column1: GCColumnChartView!
    @IBOutlet weak var column2: GCColumnChartView!
    @IBOutlet weak var column3: GCColumnChartView!
    
    var isBtnClicked:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "柱状图"
        
        setUI()
    }
    
    // MARK: - setUI
    func setUI() {
        let btn = UIButton(type: .system)
        btn.setTitle("重设", for: .normal)
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        column1.singleDataArray = ["100","100","100"]
        column1.dataNameArray = ["一工区","二工区","三工区"]
//        column1.yAxisNums = ["-200","-100","0","100","200"]
        column1.showDataLabel = true
        column1.resetData()
        
        column2.singleDataArray = ["0.1","0.3","0.2","0.24","0.7","0.6","0.14","0.4","0.3","0.9"]
        column2.dataNameArray = ["一工区","二工区","三工区","四工区","五工区","六工区","七工区","八工区","九工区","十工区"]
        column2.isColumnGradientColor = true
        column2.singleGradientColorArray = ["#2c8efa","#42cbfe"]
        column2.showDataLabel = true
        column2.resetData()
        
        column3.isSingleColumn = false
        column3.multiDataArray = [["100","200"],["100","50"],["10","300"]]
//        column3.yAxisNums = ["-200","-100","0","100","200","300","400"]
        column3.dataNameArray = ["一工区","二工区","三工区"]
        column3.columnWidth = 10
        column3.showDataLabel = true
        column3.resetData()
    }
    
    @objc func btnAction() {
        if isBtnClicked {
            column1.singleDataArray = ["100","100","100"]
            column1.dataNameArray = ["一工区","二工区","三工区"]
            column1.yAxisNums = []
            column1.isColumnGradientColor = false
            
            column2.singleDataArray = ["-0.1","-0.3","-0.2","-0.24","-0.7","-0.6","-0.14","-0.4","-0.3","-0.9"]
            column2.dataNameArray = ["一工区","二工区","三工区","四工区","五工区","六工区","七工区","八工区","九工区","十工区"]
            
            column3.multiDataArray = [["-100","100","50"],["150","-100","150"],["100","200","250"],["-100","100","100"],["150","-100","270"],["100","200","300"],["-100","100","260"],["150","-100","50"],["-10","370","100"],["150","-150","100"]]
            column3.yAxisNums = ["-200","-100","0","100","200","300","400"]
            column3.dataNameArray = ["一工区","二工区","三工区","四工区","五工区","六工区","七工区","八工区","九工区","十工区"]
            column3.isColumnGradientColor = false
        } else {
            column1.dataNameArray = ["一工区","二工区","三工区","四工区","五工区","六工区"]
            column1.singleDataArray = ["-100","-350","100","50","-50","150"]
            column1.isColumnGradientColor = true
            column1.singleGradientColorArray = ["#f6457d","#f88d5c"]
            column1.yAxisNums = ["-400","-300","-200","-100","0","100","200"]
            
            column2.singleDataArray = ["-0.1","-0.3","0.2","-0.24","-0.7","0.6","-0.14","0.4"]
            column2.dataNameArray = ["一工区","二工区","三工区","四工区","五工区","六工区","七工区","八工区"]
            
            column3.multiDataArray = [["100","270","150","70"],["100","-150","150","300"],["300","20","150","150"],["-100","-270","-150","70"],["-100","270","150","-70"]]
            column3.dataNameArray = ["一工区","二工区","三工区","四工区","五工区"]
            column3.yAxisNums = []
            column3.isColumnGradientColor = true
        }
        column1.resetData()
        column2.resetData()
        column3.resetData()
        
        isBtnClicked = !isBtnClicked
    }

}
