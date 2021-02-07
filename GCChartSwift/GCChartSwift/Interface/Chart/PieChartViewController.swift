//
//  PieChartViewController.swift
//  DemosInSwift
//
//  Created by 古创 on 2020/8/25.
//  Copyright © 2020 c. All rights reserved.
//

import UIKit

class PieChartViewController: BaseViewController {
    
    
    @IBOutlet weak var pie1: GCPieChartView!
    @IBOutlet weak var pie2: GCPieChartView!
    @IBOutlet weak var pie3: GCPieChartView!
    @IBOutlet weak var pie4: GCPieChartView!
    
    var isBtnClicked:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "扇形图（饼图）"
        
        setUI()
    }
    
    // MARK: - setUI
    func setUI() {
        let btn = UIButton(type: .system)
        btn.setTitle("重设", for: .normal)
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        pie1.pieDataNameArray = ["一工区","二工区","三工区"]
        pie1.pieDataArray = ["100","100","100"]
        pie1.resetData()
        
        pie2.showMark = true
        pie2.markLineColor = UIColor.white
        pie2.pieDataNameArray = ["一工区","二工区","三工区"]
        pie2.pieDataArray = ["100","100","100"]
        pie2.resetData()
        
        pie3.showMark = true
        pie3.showPercentage = true
        pie3.markLineWidth = 1
        pie3.showPercentageInPie = true
        pie3.pieDataNameArray = ["一工区","二工区","三工区"]
        pie3.pieDataArray = ["100","100","100"]
        pie3.differentRadiusArc = true
        pie3.resetData()
        
        pie4.showMark = true
//        pie4.showPercentage = true
        pie4.markLineWidth = 1
        pie4.showPercentageInPie = true
        pie4.isDoubleCircle = true
        pie4.radius = 100
        pie4.pieDataNameArray = ["一工区","二工区","三工区"]
        pie4.pieInsideDataArray = ["100","100","100"]
        pie4.pieOutsideDataArray = [["100"],["100"],["100"]]
        pie4.resetData()
    }
    
    @objc func btnAction() {
        
        if isBtnClicked {
            pie1.pieDataNameArray = ["一工区","二工区","三工区"]
            pie1.pieDataArray = ["100","100","100"]
            pie2.pieDataNameArray = ["一工区","二工区","三工区"]
            pie2.pieDataArray = ["100","100","100"]
            pie3.pieDataNameArray = ["一工区","二工区","三工区"]
            pie3.pieDataArray = ["100","100","100"]
            pie4.pieDataNameArray = ["一工区","二工区","三工区"]
            pie4.pieInsideDataArray = ["100","100","100"]
            pie4.pieOutsideDataArray = [["100"],["100"],["100"]]
        } else {
            pie1.pieDataNameArray = ["一工区","二工区","三工区"]
            pie1.pieDataArray = ["100","100","100"]
            pie2.pieDataNameArray = ["一工区","二工区","三工区","四工区","五工区"]
            pie2.pieDataArray = ["100","100","100","100","100"]
            pie3.pieDataNameArray = ["一工区","二工区","三工区","四工区","五工区","六工区"]
            pie3.pieDataArray = ["100","150","100","200","100","200"]
            pie4.pieDataNameArray = ["一工区","二工区","三工区","四工区","五工区","六工区"]
            pie4.pieInsideDataArray = ["290","350","290","450","530","530"]
            pie4.pieOutsideDataArray = [["20","30","50","100","90"],
                                        ["50","100","100","50","50"],
                                        ["80","20","40","100","50"],
                                        ["100","100","50","100","100"],
                                        ["100","200","100","80","50"],
                                        ["200","100","50","80","100"]]
            pie4.pieOutsideNameArray = [["一队","二队","三队","四队","五队"],
                                        ["一队","二队","三队","四队","五队"],
                                        ["一队","二队","三队","四队","五队"],
                                        ["一队","二队","三队","四队","五队"],
                                        ["一队","二队","三队","四队","五队"],
                                        ["一队","二队","三队","四队","五队"]]
        }
        
        
        pie1.resetData()
        pie2.resetData()
        pie3.resetData()
        pie4.resetData()
        
        isBtnClicked = !isBtnClicked
    }

}
