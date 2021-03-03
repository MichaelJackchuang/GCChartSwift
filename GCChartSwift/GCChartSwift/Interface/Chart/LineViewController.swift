//
//  LineViewController.swift
//  DemosInSwift
//
//  Created by 古创 on 2020/8/25.
//  Copyright © 2020 c. All rights reserved.
//

import UIKit

class LineViewController: BaseViewController {
    
//    var line1:GCLineChartView!
    @IBOutlet weak var line1: GCLineChartView!
    @IBOutlet weak var line2: GCLineChartView!
    @IBOutlet weak var line3: GCLineChartView!
    @IBOutlet weak var line4: GCLineChartView!
    
    var isBtnClicked:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "折线图&曲线图"
        
        setUI()
    }
    
    // MARK: - setUI
    func setUI() {
        let btn = UIButton(type: .system)
        btn.setTitle("重设", for: .normal)
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        line1.showDataHorizontalLine = true
        line1.lineWidth = 1
        line1.isFillWithColor = false
        line1.showDataLabel = true
//        line1.isSmooth = true
        line1.lineColor = ["404040"]
        line1.dataNameArray = ["一工区","二工区","三工区","项目部","一大队","二中队","三小队"]
        line1.singleDataArray = ["100","137","215","258","65","78","47"]
        line1.resetData()
        
        line2.showDataHorizontalLine = true
        line2.lineWidth = 1
        line2.isFillWithColor = false
        line2.showDataLabel = true
        line2.isSmooth = true
        line2.lineColor = ["f5447d"]
        line2.fillColor = "f9856c"
        line2.fillAlpha = 0.5
        line2.isFillWithColor = true
        line2.isDrawLineWhenFillColor = true
        line2.showBlodPoint = true
        line2.dataNameArray = ["一工区","二工区","三工区","项目部","一大队","二中队","三小队"]
        line2.singleDataArray = ["100","137","215","258","65","78","47"]
        line2.resetData()
        
        line3.isSingleLine = false
        line3.showDataHorizontalLine = true
        line3.lineWidth = 1
        line3.showDataLabel = true
        line3.isSmooth = true
        line3.showBlodPoint = true
        line3.lineColor = ["308ff7","fbca58"]//,"f5447d","a020f0","00ffff","00ff00"]
        line3.dataNameArray = ["一工区","二工区","三工区","项目部","一大队","二中队","三小队"]
        line3.multiDataArray = [["-100","-137","-215","-258","-65","-78","-47"],
                                ["150","187","115","78","165","108","17"]]
        line3.resetData()
        
        line4.isSingleLine = true
        line4.showDataHorizontalLine = true
        line4.lineWidth = 1
        line4.showDataLabel = true
        line4.showBlodPoint = true
        line4.lineColor = ["00cd00"]
        line4.fillColor = "00cd00"
        line4.isGradientFillColor = true
        line4.isDrawLineWhenFillColor = true
        line4.dataNameArray = ["一工区","二工区","三工区","项目部","一大队","二中队","三小队"]
        line4.singleDataArray = ["100","137","215","258","65","78","47"]
        line4.resetData()
    }
    
    @objc func btnAction() {
        if isBtnClicked {
            line1.isSmooth = false
            line1.lineColor = ["404040"]
            line1.isFillWithColor = false
            line1.isDrawLineWhenFillColor = false
            line1.singleDataArray = ["100","137","215","258","65","78","47"]
            
            line2.dataNameArray = ["一工区","二工区","三工区","项目部","一大队","二中队","三小队"]
            line2.singleDataArray = ["121","-137","215","-258","65","78","47"]
            line2.yAxisNums = []
            
            line3.multiDataArray = [["-100","-137","-215","-258","-65","-78","-47"],
                                    ["150","187","115","78","165","108","17"]]
            
            line4.isSmooth = true
            line4.singleDataArray = ["100","137","215","258","-65","-78","47"]
            line4.yAxisNums = []
        } else {
            line1.isSmooth = true
            line1.lineColor = ["308ff7"]
            line1.fillColor = "308ff7"
            line1.fillAlpha = 0.5
            line1.isFillWithColor = true
            line1.isDrawLineWhenFillColor = true
            line1.singleDataArray = ["-100","-137","-215","-258","-65","-78","-47"]
            
            line2.dataNameArray = ["一工区","二工区","三工区","项目部","一大队","二中队","三小队"]
            line2.singleDataArray = ["-100","-137","215","258","65","-78","47"]
            line2.yAxisNums = ["-300","-200","-100","0","100","200","300","400"]
            
            line3.multiDataArray = [["0.1","0.13","0.6","0.36","0.5","0.2","0.8"],
                                    ["-0.1","-0.13","0.6","0.36","-0.5","-0.2","0.8"]]
            
            line4.isSmooth = true
            line4.singleDataArray = ["-100","137","-215","-258","65","78","47"]
            line4.yAxisNums = ["-300","-200","-100","0","100","200"]
        }
        line1.resetData()
        line2.resetData()
        line3.resetData()
        line4.resetData()
        
        isBtnClicked = !isBtnClicked
    }
}
