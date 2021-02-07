//
//  LineViewController.swift
//  DemosInSwift
//
//  Created by 古创 on 2020/8/25.
//  Copyright © 2020 c. All rights reserved.
//

import UIKit

class LineViewController: BaseViewController {
    
    var line1:LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "折线图&曲线图"
        
        setUI()
    }
    
    // MARK: - setUI
    func setUI() {
        line1 = LineChartView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 200))
        view.addSubview(line1)
        line1.backgroundColor = .white
        line1.showDataHorizontalLine = true
        line1.lineWidth = 1
        line1.isSmooth = false
        line1.isFillWithColor = false
        line1.showDataLabel = true
        line1.lineColor = ["404040"]
        line1.dataNameArray = ["一工区","二工区","三工区","项目部","一大队","二中队","三小队"]
        line1.dataArray = ["121","137","215","258","65","78","47"]
        line1.resetData()
    }

}
