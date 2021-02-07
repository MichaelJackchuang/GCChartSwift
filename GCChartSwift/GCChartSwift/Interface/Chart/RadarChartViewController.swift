//
//  RadarChartViewController.swift
//  DemosInSwift
//
//  Created by 古创 on 2020/8/25.
//  Copyright © 2020 c. All rights reserved.
//

import UIKit

class RadarChartViewController: BaseViewController {
    
    var isBtnClicked:Bool = false
    
    @IBOutlet weak var radar1: GCRadarChartView!
    
    @IBOutlet weak var radar2: GCRadarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "雷达图"
        
        setUI()
    }
    
    // MARK: - setUI
    func setUI() {
        let btn = UIButton(type: .system)
        btn.setTitle("重设", for: .normal)
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        radar1.radarNameArray = ["一一","二二","三三","四四","五五"]
        radar1.radarDataArray = ["100","120","160","180","50"]
        radar1.maxValue = "200"
//        radar1.backgroundColor = .white
        radar1.showBgLine = true
        radar1.radarLineColor = "ff0000"
        radar1.showDataLabel = false
        radar1.animationStyle = .circleStroke
        radar1.resetData()
        
        radar2.radarNameArray = ["一一","二二","三三","四四","五五","六六","七七"]
        radar2.radarDataArray = ["100","100","100","100","100","100","100"]
        radar2.maxValue = "200"
        radar2.radarBgColor = "ffffff"
        radar2.showBgLine = true
        radar2.radarLineColor = "ff0000"
        radar2.showDataLabel = false
        radar2.animationStyle = .scale
        radar2.resetData()
        
    }
    
    @objc func btnAction() {
        if isBtnClicked {
            radar1.radarNameArray = ["一一","二二","三三","四四","五五"]
            radar1.radarDataArray = ["100","120","160","180","50"]
            radar1.bgLineColor = "000000"
            radar1.showBgColor = false
            radar1.isFilledColor = false
            radar1.showPoint = false
            radar1.showCenter = false
            radar1.showDataLabel = false
            
            radar2.radarNameArray = ["一一","二二","三三"]
            radar2.radarDataArray = ["100","100","100"]
            radar2.bgLineColor = "000000" // 黑色框线
            radar2.showBgColor = false // 不显示背景色
            radar2.isFilledColor = true // 雷达填充
            radar2.radarLineColor = "ff0000" // 雷达边线颜色
            radar2.radarLineWidth = 2 // 雷达边线线宽
            radar2.radarFillColor = "f5447d" // 雷达填充色
            radar2.radarFillColorOpacity = 0.5 // 雷达填充色不透明度
            radar2.showPoint = false
            radar2.showCenter = false
            radar2.showDataLabel = false
            
        } else {
            radar1.radarNameArray = ["一一","二二","三三","四四","五五","六六"]
            radar1.radarDataArray = ["100","120","160","180","20","110"]
            radar1.bgLineColor = "ffffff"
            radar1.showBgColor = true
            radar1.radarBgColor = "00ffff"
            radar1.isFilledColor = true
            radar1.radarFillColor = "ff0000"
//            radar1.showPoint = true
//            radar1.showCenter = true
            radar1.showDataLabel = true
            
            radar2.radarNameArray = ["一一","二二","三三","四四","五五","六六","七七","八八"]
            radar2.radarDataArray = ["100","100","100","100","100","100","100","100"]
            radar2.bgLineColor = "ffffff"
            radar2.showBgColor = true
            radar2.radarBgColor = "00ffff"
            radar2.isFilledColor = true
            radar2.radarFillColor = "ff0000"
            radar2.radarFillColorOpacity = 1.0
            radar2.showPoint = true
            radar2.showCenter = true
            radar2.showDataLabel = true
            
        }
        radar1.resetData()
        radar2.resetData()
        
        
        isBtnClicked = !isBtnClicked
    }

}
