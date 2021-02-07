//
//  GCPieChartView.swift
//  DemosInSwift
//
//  Created by 古创 on 2021/1/5.
//  Copyright © 2021 c. All rights reserved.
//

import UIKit

class GCPieChartView: UIView {
    
    // MARK: - member property
    /// 是否为双层饼图
    var isDoubleCircle:Bool = false
    
    /// 是否显示标注
    var showMark:Bool = false
    
    /// 是否显示百分比（前提是showMark为true）
    var showPercentage:Bool = false
    
    /// 是否在饼状图扇区中间显示百分比
    var showPercentageInPie:Bool = false
    
    /// 是否为不同半径弧形（顺时针半径递增）
    var differentRadiusArc:Bool = false
    
    /// 是否显示扇区阴影
    var showArcShadow:Bool = false
    
    /// 扇形颜色数组
    var colorArray = [String]()
    
    /// 外环数据颜色（二维数组）
    var outsideColorArray = [[String]]()
    
    /// 数据数组，单层饼图的时候使用这个数组
    var pieDataArray = [String]()
    
    /// 内层数据数组，双层饼图的时候使用这个数组（非必须，可根据外层数据数组计算得出）
    var pieInsideDataArray = [String]()
    
    /// 外层数据数组，双层饼图的时候使用这个数组（二维数组，与内层数组属于对应关系，即对应项的和相等）
    var pieOutsideDataArray = [[String]]()
    
    /// 单层圆环半径 或双层圆环外层半径
    var radius:CGFloat = 60
    
    /// 数据标签数组
    var pieDataNameArray = [String]()
    
    /// 外层数据标签数组（双层饼图）
    var pieOutsideNameArray = [[String]]()
    
    /// 数据标注单位
    var pieDataUnit:String = ""
    
    /// 标注连接线颜色
    var markLineColor:UIColor = UIColor.colorWithHexString(color: "dcdcdc")
    
    /// 标注连接线线宽
    var markLineWidth:CGFloat = 0.5
    
    // MARK: private property
    private var bgWidth:CGFloat = 0
    private var bgHeight:CGFloat = 0
    
    // MARK: - init
    /// 初始化单层饼图
    /// - Parameters:
    ///   - frame: frame
    ///   - nameArray: 名称数组
    ///   - dataArray: 数据数组
    init(frame:CGRect, nameArray:[String], dataArray:[String]) {
        super.init(frame: frame)
        
        pieDataNameArray = nameArray
        pieDataArray = nameArray
        config()
    }
    
    /// 初始化内外圈两层饼图
    /// - Parameters:
    ///   - frame: frame
    ///   - nameArray: 名称数组
    ///   - insideDataArray: 内圈数据数组
    ///   - outsideDataArray: 外圈数据数组
    init(frame:CGRect, nameArray:[String], insideDataArray:[String] = [], outsideDataArray:[[String]]) {
        super.init(frame: frame)
        
        pieDataNameArray = nameArray
        pieInsideDataArray = insideDataArray
        pieOutsideDataArray = outsideDataArray
        config()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        config()
    }
    
    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        config()
    }
    
    // MARK: - UI property
    let bgView = UIView()
    
    // MARK: - reset
    /// 重设数据（更新数据后重新设置饼图）
    func resetData() {
        if isDoubleCircle {
            resetDoubleCircle()
        } else {
            resetSingleCircle()
        }
    }
}

// MARK: - config
extension GCPieChartView {
    func config() {
        // 如果颜色未设置或者数量少于数据数量则设置一个默认的
        if colorArray.isEmpty || colorArray.count < pieDataArray.count {
            colorArray = ["#308ff7","#fbca58","#f5447d","#a020f0","#00ffff","#00ff00"]
        }
        if outsideColorArray.isEmpty {
            outsideColorArray = [["#308ff7","#1e90ff","#1caaff","#00bfff","#0000ff"],
                                 ["#fbca58","#ffd700","#ffc125","#eec900","#ffff00"],
                                 ["#f5447d","#ff4500","#ff6a6a","#cd2626","#ff0000"],
                                 ["#a020f0","#8470ff","#da70a6","#ff83fa","#ff00ff"],
                                 ["#00ffff","#22ccff","#8ee5ee","#aaeeff","#aaccff"],
                                 ["#00ff00","#00ff7f","#c0ff3e","#2fcc00","#008b00"]]
        }
        
        let minWorH:CGFloat = [bounds.size.width, bounds.size.height].min() ?? 0 // 获取长宽高最小值
        // 半径范围限制，可以根据实际情况改动
        if radius < 40 {
            radius = 40
        } else if radius * 2 > minWorH - 20 - 20 * 2 { // 极端情况 半径接近宽高较小值-20的时候 需要特殊处理 此时标注有可能超出范围而不显示或显示异常
            radius = (minWorH - 20 - 20 * 2) / 2
        }
        
        setUI()
    }
    
    func setUI() {
        addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        bgView.backgroundColor = .clear
//        bgView.layer.masksToBounds = true
        
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgWidth = bounds.size.width
        bgHeight = bounds.size.height
    }
}

// MARK: - reload
extension GCPieChartView {
    func resetSingleCircle() {
        
        // 先移除之前创建的子视图
        for subview in bgView.subviews {
            subview.removeFromSuperview()
        }
        bgView.layer.sublayers?.removeAll()
        bgView.layer.mask?.removeFromSuperlayer()
        
        let bgRadius:CGFloat = ([bgWidth, bgHeight].max() ?? 0) / 2
        
        // 背景
        let bgPath = UIBezierPath(arcCenter: bgView.center, radius: bgRadius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2 * 3, clockwise: true)
        let bgLayer = CAShapeLayer()
        bgLayer.fillColor = UIColor.clear.cgColor
        bgLayer.strokeColor = UIColor.lightGray.cgColor
        bgLayer.strokeStart = 0
        bgLayer.strokeEnd = 1
        bgLayer.zPosition = 1
        bgLayer.lineWidth = bgRadius * 2
        bgLayer.path = bgPath.cgPath
        
        // 计算总值
        var total:CGFloat = 0
        for str in pieDataArray {
            let value = CGFloat(Float(str) ?? 0)
            total += value
        }
        
        // 标注
        if showMark {
            var startAngle_p:CGFloat = 90
            var plusRadius:CGFloat = 0 // 半径增量
            for (i,numStr) in pieDataArray.enumerated() {
                let num = CGFloat(Float(numStr) ?? 0)
                if num == 0 || num / total * CGFloat.pi < 0.3 { // 数据为0或者小于10度(0.175) 则不显示   20度0.35
                    startAngle_p = startAngle_p - num / total * 360
                    continue
                }
                
                // 找点 每个扇区弧度中点
                let angle:CGFloat = startAngle_p - num / 2 / total * 360
                let lineMargin:CGFloat = 0// 标注线距离圆的距离
                let pointInCenter = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius + lineMargin + plusRadius)
                let pointInCenter_2 = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius + lineMargin + radius / 6 + plusRadius)
                var pointAtLabel = CGPoint.zero
                if cos(angle * CGFloat.pi / 180) >= -0.01 {
                    pointAtLabel = CGPoint(x: pointInCenter_2.x + radius / 3, y: pointInCenter_2.y)
                } else {
                    pointAtLabel = CGPoint(x: pointInCenter_2.x - radius / 3, y: pointInCenter_2.y)
                }
                
                let linePath = UIBezierPath()
                linePath.move(to: pointInCenter)
                linePath.addLine(to: pointInCenter_2)
                linePath.addLine(to: pointAtLabel)
                
                let layer = CAShapeLayer()
                layer.lineWidth = markLineWidth
                layer.strokeColor = markLineColor.cgColor
                layer.fillColor = nil
                layer.path = linePath.cgPath
                bgView.layer.addSublayer(layer)
                
                let lblMark = UILabel()
                if cos(angle * CGFloat.pi / 180) >= -0.01 { // 偏右侧
                    lblMark.bounds = CGRect(x: 0, y: 0, width: bgWidth - pointAtLabel.x - 2, height: 12)
                } else { // 偏左侧
                    lblMark.bounds = CGRect(x: 0, y: 0, width: pointAtLabel.x - 2, height: 12)
                }
                lblMark.textColor = UIColor.colorWithHexString(color: "404040")
                lblMark.font = UIFont.systemFont(ofSize: 10)
                lblMark.numberOfLines = 2
                if showPercentage {
                    if pieDataNameArray.isEmpty || pieDataNameArray.count != pieDataArray.count { // 数据标签数组数量为0或与数据数量不相等
                        lblMark.text = String(format: "%.2f%%", num / total * 100)
                    } else {
                        lblMark.text = "\(pieDataNameArray[i]):" + String(format: "%.2f%%", num / total * 100)
                    }
                } else {
                    if pieDataNameArray.isEmpty || pieDataNameArray.count != pieDataArray.count {
                        lblMark.text = pieDataArray[i] + pieDataUnit
                    } else {
                        lblMark.text = pieDataNameArray[i]// + ":" + pieDataArray[i] + pieDataUnit
                    }
                }
                lblMark.sizeToFit()
//                lblMark.shadowColor = .white // 需要高亮标注时 打开注释看效果
//                lblMark.shadowOffset = CGSize(width: 0.5, height: 0.5)
                bgView.addSubview(lblMark)
                if cos(angle * CGFloat.pi / 180) >= -0.01 { // 偏右侧
                    lblMark.center = CGPoint(x: pointAtLabel.x + lblMark.bounds.size.width / 2 + 2, y: pointAtLabel.y)
//                    if sin(angle * CGFloat.pi / 180) >= 0.01 { // 偏上
//                        lblMark.center = CGPoint(x: pointInCenter_2.x + lblMark.bounds.size.width / 2 + 2, y: pointAtLabel.y - lblMark.bounds.size.height / 2 - 2)
//                    } else { // 偏下
//                        lblMark.center = CGPoint(x: pointInCenter_2.x + lblMark.bounds.size.width / 2 + 2, y: pointAtLabel.y + lblMark.bounds.size.height / 2 + 2)
//                    }
                } else { // 偏左侧
                    lblMark.center = CGPoint(x: pointAtLabel.x - lblMark.bounds.size.width / 2 - 2, y: pointAtLabel.y)
//                    if sin(angle * CGFloat.pi / 180) >= 0.01 { // 偏上
//                        lblMark.center = CGPoint(x: pointInCenter_2.x - lblMark.bounds.size.width / 2 + 2, y: pointAtLabel.y - lblMark.bounds.size.height / 2 - 2)
//                    } else { // 偏下
//                        lblMark.center = CGPoint(x: pointInCenter_2.x - lblMark.bounds.size.width / 2 + 2, y: pointAtLabel.y + lblMark.bounds.size.height / 2 + 2)
//                    }
                }
                
                startAngle_p = startAngle_p - num / total * 360
                
                if differentRadiusArc {
                    plusRadius += 5
                }
            }
        }
        
        // 子扇区
        var startAngle:CGFloat = -CGFloat.pi / 2 // 起始角度
        var plusRadius:CGFloat = 0 // 半径增量
        for (i,numStr) in pieDataArray.enumerated() {
            let num = CGFloat(Float(numStr) ?? 0)
            
            let path = UIBezierPath()
            let valueAngle:CGFloat = num / total * CGFloat.pi * 2 // 扇区角度
            path.addArc(withCenter: bgView.center, radius: radius + plusRadius, startAngle: startAngle, endAngle: startAngle + valueAngle, clockwise: true)
            path.addLine(to: bgView.center) // 圆心
            let dataColor = UIColor.colorWithHexString(color: colorArray[i])
            dataColor.setStroke()
            dataColor.setFill()
            path.stroke()
            path.fill()
            
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            if differentRadiusArc { // 如果是不同大小半径 则不设置扇区白边
                layer.strokeColor = nil
            } else {
                layer.strokeColor = UIColor.white.cgColor // 每个扇区边的白线 不需要的话就设置为nil
            }
            layer.fillColor = dataColor.cgColor // 背景填充色
            if showArcShadow {
                layer.shadowColor = dataColor.cgColor // 阴影
                layer.shadowOffset = CGSize(width: 3, height: 3)
                layer.shadowRadius = 3
                layer.shadowOpacity = 0.3
            }
            bgView.layer.addSublayer(layer)
//            bgView.layer.insertSublayer(layer, at: 0) // 顺序问题 如果扇区中间的label写在数据layer之前 就用这句
            
            startAngle = startAngle + valueAngle
            if differentRadiusArc {
                plusRadius += 5
            }
        }
        
        // 扇区中间的百分比标注
        if showPercentageInPie {
            var startAngle_p:CGFloat = 90
            for numStr in pieDataArray {
                let num = CGFloat(Float(numStr) ?? 0)
                if num == 0 || num / total * CGFloat.pi < 0.3 { // 数据为0或者小于10度(0.175) 则不显示   20度0.35
                    startAngle_p = startAngle_p - num / total * 360
                    continue
                }
                // 找点 每个扇区弧度中点
                let angle:CGFloat = startAngle_p - num / 2 / total * 360
                let pointInCenter = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius / 5 * 3)
                
                let lblMark = UILabel()
                lblMark.textColor = UIColor.white//colorWithHexString(color: "404040")
                lblMark.font = UIFont.systemFont(ofSize: 12)
                lblMark.text = String(format: "%.2f%%", num / total * 100)
                lblMark.sizeToFit()
                lblMark.center = pointInCenter
//                lblMark.shadowColor = .white // 需要高亮标注时 打开注释看效果
//                lblMark.shadowOffset = CGSize(width: 0.5, height: 0.5)
                bgView.addSubview(lblMark)
                
                startAngle_p = startAngle_p - num / total * 360
            }
        }
        
        bgView.layer.mask = bgLayer // 设置遮罩
        
        // 动画
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0 // 起始值
        strokeAnimation.toValue = 1 // 结束值
        strokeAnimation.duration = 1 // 动画持续时间
        strokeAnimation.repeatCount = 1 // 重复次数
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeAnimation.isRemovedOnCompletion = true
        bgLayer.add(strokeAnimation, forKey: "pieAnimation")
    }
    
    func resetDoubleCircle() {
        // 先移除之前创建的子视图
        for subview in bgView.subviews {
            subview.removeFromSuperview()
        }
        bgView.layer.sublayers?.removeAll()
        bgView.layer.mask?.removeFromSuperlayer()
        
        let bgRadius:CGFloat = ([bgWidth, bgHeight].max() ?? 0) / 2
        
        // 背景
        let bgPath = UIBezierPath(arcCenter: bgView.center, radius: bgRadius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2 * 3, clockwise: true)
        let bgLayer = CAShapeLayer()
        bgLayer.fillColor = UIColor.clear.cgColor
        bgLayer.strokeColor = UIColor.lightGray.cgColor
        bgLayer.strokeStart = 0
        bgLayer.strokeEnd = 1
        bgLayer.zPosition = 1
        bgLayer.lineWidth = bgRadius * 2
        bgLayer.path = bgPath.cgPath
        
        // 内圈
        var insideTotal:CGFloat = 0
        for str in pieInsideDataArray {
            let value = CGFloat(Float(str) ?? 0)
            insideTotal += value
        }
        
        var startAngle:CGFloat = -CGFloat.pi / 2 // 起始角度
        for (i,numStr) in pieInsideDataArray.enumerated() {
            let num = CGFloat(Float(numStr) ?? 0)
            
            let path = UIBezierPath()
            let valueAngle:CGFloat = num / insideTotal * CGFloat.pi * 2 // 扇区角度
            path.addArc(withCenter: bgView.center, radius: radius / 4 * 3, startAngle: startAngle, endAngle: startAngle + valueAngle, clockwise: true)
            path.addLine(to: bgView.center) // 圆心
            let dataColor = UIColor.colorWithHexString(color: colorArray[i])
            dataColor.setStroke()
            dataColor.setFill()
            path.stroke()
            path.fill()
            
            let layer = CAShapeLayer()
            layer.path = path.cgPath
//            layer.lineWidth = radius / 4 * 3
            layer.strokeColor = nil//UIColor.white.cgColor // 每个扇区边的白线 不需要的话就设置为nil
            layer.fillColor = dataColor.cgColor // 背景填充色
            bgView.layer.addSublayer(layer)
//            bgView.layer.insertSublayer(layer, at: 0) // 顺序问题 如果扇区中间的label写在数据layer之前 就用这句
            
            startAngle = startAngle + valueAngle
        }
        
        // 扇区中间的百分比标注
        if showPercentageInPie {
            var startAngle_p:CGFloat = 90
            for numStr in pieInsideDataArray {
                let num = CGFloat(Float(numStr) ?? 0)
                if num == 0 || num / insideTotal * CGFloat.pi < 0.3 { // 数据为0或者小于10度(0.175) 则不显示   20度0.35
                    startAngle_p = startAngle_p - num / insideTotal * 360
                    continue
                }
                // 找点 每个扇区弧度中点
                let angle:CGFloat = startAngle_p - num / 2 / insideTotal * 360
                let pointInCenter = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius / 4 * 3 / 2)
                
                let lblMark = UILabel()
                lblMark.textColor = UIColor.white//colorWithHexString(color: "404040")
                lblMark.font = UIFont.systemFont(ofSize: 12)
                lblMark.text = String(format: "%.2f%%", num / insideTotal * 100)
                lblMark.sizeToFit()
                lblMark.center = pointInCenter
//                lblMark.shadowColor = .white // 需要高亮标注时 打开注释看效果
//                lblMark.shadowOffset = CGSize(width: 0.5, height: 0.5)
                bgView.addSubview(lblMark)
                
                startAngle_p = startAngle_p - num / insideTotal * 360
            }
        }
        
        // 外环
        var outsideTotal:CGFloat = 0
        for arr in pieOutsideDataArray {
            for str in arr {
                let value = CGFloat(Float(str) ?? 0)
                outsideTotal += value
            }
        }
        
        startAngle = -CGFloat.pi / 2 // 起始角度
        for (i,arr) in pieOutsideDataArray.enumerated() {
            for (j,numStr) in arr.enumerated() {
                let num = CGFloat(Float(numStr) ?? 0)
                
                let path = UIBezierPath()
                let valueAngle:CGFloat = num / insideTotal * CGFloat.pi * 2 // 扇区角度
                path.addArc(withCenter: bgView.center, radius: radius, startAngle: startAngle, endAngle: startAngle + valueAngle, clockwise: true)
                let dataColor = UIColor.colorWithHexString(color: outsideColorArray[i][j])
                dataColor.setStroke()
                dataColor.setFill()
                path.stroke()
                path.fill()
                
                let layer = CAShapeLayer()
                layer.path = path.cgPath
                layer.lineWidth = radius / 6
                layer.strokeColor = dataColor.cgColor // 每个扇区边的白线 不需要的话就设置为nil
                layer.fillColor = nil//dataColor.cgColor // 背景填充色
                bgView.layer.addSublayer(layer)
                
                startAngle = startAngle + valueAngle
            }
        }
        
        // 标注
        if showMark {
            var startAngle_p:CGFloat = 90
            for (i,arr) in pieOutsideDataArray.enumerated() {
                for (j,numStr) in arr.enumerated() {
                    let num = CGFloat(Float(numStr) ?? 0)
                    if num == 0 || num / outsideTotal * CGFloat.pi < 0.03 { // 数据为0或者小于10度(0.175) 则不显示   20度0.35
                        startAngle_p = startAngle_p - num / outsideTotal * 360
                        continue
                    }
                    
                    // 找点 每个扇区弧度中点
                    let angle:CGFloat = startAngle_p - num / 2 / outsideTotal * 360
                    let lineMargin:CGFloat = 0// 标注线距离圆的距离
                    let pointInCenter = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius + lineMargin)
                    let pointInCenter_2 = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius + lineMargin + radius / 6)
                    var pointAtLabel = CGPoint.zero
                    if cos(angle * CGFloat.pi / 180) >= -0.01 {
                        pointAtLabel = CGPoint(x: pointInCenter_2.x + radius / 3, y: pointInCenter_2.y)
                    } else {
                        pointAtLabel = CGPoint(x: pointInCenter_2.x - radius / 3, y: pointInCenter_2.y)
                    }
                    
                    let linePath = UIBezierPath()
                    linePath.move(to: pointInCenter)
                    linePath.addLine(to: pointInCenter_2)
                    linePath.addLine(to: pointAtLabel)
                    
                    let layer = CAShapeLayer()
                    layer.lineWidth = markLineWidth
                    layer.strokeColor = markLineColor.cgColor
                    layer.fillColor = nil
                    layer.path = linePath.cgPath
                    bgView.layer.addSublayer(layer)
                    
                    let lblMark = UILabel()
                    if cos(angle * CGFloat.pi / 180) >= -0.01 { // 偏右侧
                        lblMark.bounds = CGRect(x: 0, y: 0, width: bgWidth - pointAtLabel.x - 2, height: 12)
                    } else { // 偏左侧
                        lblMark.bounds = CGRect(x: 0, y: 0, width: pointAtLabel.x - 2, height: 12)
                    }
                    lblMark.textColor = UIColor.colorWithHexString(color: "404040")
                    lblMark.font = UIFont.systemFont(ofSize: 10)
                    lblMark.numberOfLines = 2
                    if showPercentage {
                        if pieDataNameArray.isEmpty || pieDataNameArray.count != pieOutsideDataArray.count || pieOutsideNameArray.isEmpty || pieOutsideNameArray.count != pieOutsideDataArray.count || pieOutsideNameArray[i].isEmpty || arr.count != pieOutsideNameArray[i].count { // 数据标签数组数量为0或与数据数量不相等
                            lblMark.text = String(format: "%.2f%%", num / outsideTotal * 100)
                        } else {
                            lblMark.text = "\(pieOutsideNameArray[i][j]):" + String(format: "%.2f%%", num / outsideTotal * 100)
                        }
                    } else {
                        if pieDataNameArray.isEmpty || pieDataNameArray.count != pieOutsideDataArray.count || pieOutsideNameArray.isEmpty || pieOutsideNameArray.count != pieOutsideDataArray.count || arr.isEmpty || arr.count != pieOutsideDataArray[i].count {
                            lblMark.text = numStr + pieDataUnit
                        } else {
                            lblMark.text = pieOutsideNameArray[i][j] + ":" + numStr + pieDataUnit
                        }
                    }
                    lblMark.sizeToFit()
                    lblMark.shadowColor = .white // 需要高亮标注时 打开注释看效果
                    lblMark.shadowOffset = CGSize(width: 0.5, height: 0.5)
                    bgView.addSubview(lblMark)
                    if cos(angle * CGFloat.pi / 180) >= -0.01 { // 偏右侧
                        lblMark.center = CGPoint(x: pointAtLabel.x + lblMark.bounds.size.width / 2 + 2, y: pointAtLabel.y)
                    } else { // 偏左侧
                        lblMark.center = CGPoint(x: pointAtLabel.x - lblMark.bounds.size.width / 2 - 2, y: pointAtLabel.y)
                    }
                    
                    startAngle_p = startAngle_p - num / outsideTotal * 360
                }
            }
        }
        
        
        
        
        bgView.layer.mask = bgLayer // 设置遮罩
        
        // 动画
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0 // 起始值
        strokeAnimation.toValue = 1 // 结束值
        strokeAnimation.duration = 1 // 动画持续时间
        strokeAnimation.repeatCount = 1 // 重复次数
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeAnimation.isRemovedOnCompletion = true
        bgLayer.add(strokeAnimation, forKey: "pieAnimation")
    }
    
    // MARK: - other
    func caculatePointAtCircle(center:CGPoint, angle:CGFloat, radius:CGFloat) -> CGPoint {
        let angle_p = angle * CGFloat.pi / 180
        let x:CGFloat = radius * cos(angle_p)
        let y:CGFloat = radius * sin(angle_p)
        
        return CGPoint(x: center.x + x, y: center.y - y)
    }
}
