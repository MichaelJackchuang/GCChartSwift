//
//  GCCircleRingChartView.swift
//  DemosInSwift
//
//  Created by 古创 on 2021/1/7.
//  Copyright © 2021 c. All rights reserved.
//

import UIKit

class GCCircleRingChartView: UIView {

    // MARK: - member property
    /// 圆环半径 
    var radius:CGFloat = 60
    
    /// 圆环线宽
    var lineWidth:CGFloat = 10
    
    /// 是否显示百分比
    var showPercentage:Bool = false
    
    /// 扇形颜色数组
    var colorArray = [String]()
    
    /// 数据数组
    var pieDataArray = [String]()
    
    /// 数据标签数组
    var pieDataNameArray = [String]()
    
    /// 数据标注单位
    var pieDataUnit:String = ""
    
    /// 是否允许点击
    var touchEnable:Bool = false
    
    /// 是否显示中心标题
    var showCenterTitle:Bool = false
    
    /// 中心标题
    var centerTitle:String = ""
    
    /// 是否显示标注
    var showMark:Bool = true
    
    /// 标注连接线颜色
    var markLineColor:UIColor = UIColor.colorWithHexString(color: "dcdcdc")
    
    /// 标注连接线线宽
    var markLineWidth:CGFloat = 0.5
    
    // MARK: private property
    private var bgWidth:CGFloat = 0
    private var bgHeight:CGFloat = 0
    private let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
    
    // MARK: - init
    init(frame:CGRect, nameArray:[String], dataArray:[String], radius:CGFloat = 60, lineWidth:CGFloat = 10) {
        super.init(frame: frame)
        
        self.pieDataNameArray = nameArray
        self.pieDataArray = dataArray
        self.radius = radius
        self.lineWidth = lineWidth
        
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
        resetCircleRing()
    }
}

// MARK: - config
extension GCCircleRingChartView {
    func config() {
        // 如果颜色未设置或者数量少于数据数量则设置一个默认的
        if colorArray.isEmpty || colorArray.count < pieDataArray.count {
            colorArray = ["#308ff7","#fbca58","#f5447d","#a020f0","#00ffff","#00ff00"]
        }
        
        let minWorH:CGFloat = [bounds.size.width, bounds.size.height].min() ?? 0 // 获取长宽高最小值
        // 半径范围限制，可以根据实际情况改动
        if radius == 0 {
            radius = 60
        } else if radius < 40 {
            radius = 40
        } else if radius * 2 > minWorH - 20 - 20 * 2 { // 极端情况 半径接近宽高较小值-20的时候 需要特殊处理 此时标注有可能超出范围而不显示或显示异常
            radius = (minWorH - 20 - 20 * 2) / 2
        }
        
        if lineWidth == 0 {
            lineWidth = 10
        } else if lineWidth < 5 {
            lineWidth = 5
        } else if lineWidth >= radius / 2 {
            lineWidth = radius / 2
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
extension GCCircleRingChartView {
    func resetCircleRing() {
        
        // 先移除之前创建的子视图
        for subview in bgView.subviews {
            subview.removeFromSuperview()
        }
        bgView.removeGestureRecognizer(tap)
        bgView.layer.sublayers?.removeAll()
        bgView.layer.mask?.removeFromSuperlayer()
        
        if touchEnable {
            bgView.addGestureRecognizer(tap)
        }
        
        // 计算总值
        var total:CGFloat = 0
        for str in pieDataArray {
            let value = CGFloat(Float(str) ?? 0)
            total += value
        }
        
        if showCenterTitle {
            if !centerTitle.isEmpty {
                let lblCenterTitle = UILabel()
                lblCenterTitle.font = UIFont.systemFont(ofSize: 14)
                lblCenterTitle.textColor = UIColor.colorWithHexString(color: "404040")
                lblCenterTitle.text = centerTitle
                lblCenterTitle.textAlignment = .center
                lblCenterTitle.sizeToFit()
                bgView.addSubview(lblCenterTitle)
                lblCenterTitle.center = CGPoint(x: bgView.center.x, y: bgView.center.y - 20)
            
                let lblCenterTotal = UILabel()
                lblCenterTotal.font = UIFont.systemFont(ofSize: 16)
                lblCenterTotal.textColor = UIColor.black
                lblCenterTotal.text = String(format: "%.f", total)
                lblCenterTotal.textAlignment = .center
                lblCenterTotal.sizeToFit()
                bgView.addSubview(lblCenterTotal)
                lblCenterTotal.center = bgView.center
            }
        }
        
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
        
        // 具体数据
        var startAngle:CGFloat = -CGFloat.pi / 2 // 起始角度
        for (i,numStr) in pieDataArray.enumerated() {
            let num = CGFloat(Float(numStr) ?? 0)

            let path = UIBezierPath()
            let valueAngle:CGFloat = num / total * CGFloat.pi * 2 // 扇区角度
            path.addArc(withCenter: bgView.center, radius: radius, startAngle: startAngle, endAngle: startAngle + valueAngle, clockwise: true)
//            path.addLine(to: bgView.center) // 圆心
            let dataColor = UIColor.colorWithHexString(color: colorArray[i])
            dataColor.setStroke()
            dataColor.setFill()
            path.stroke()
            path.fill()

            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.lineWidth = lineWidth
            layer.strokeColor = dataColor.cgColor
            layer.fillColor = UIColor.clear.cgColor
            bgView.layer.addSublayer(layer)

            startAngle = startAngle + valueAngle
        }
        
        // 标注
        if showMark {
            var startAngle_p:CGFloat = 90
            for (i,numStr) in pieDataArray.enumerated() {
                let num = CGFloat(Float(numStr) ?? 0)
                if num == 0 || num / total * CGFloat.pi < 0.03 { // 数据为0或者小于10度(0.175) 则不显示   20度0.35
                    startAngle_p = startAngle_p - num / total * 360
                    continue
                }
                
                // 找点 每个扇区弧度中点
                let angle:CGFloat = startAngle_p - num / 2 / total * 360
                let lineMargin:CGFloat = 0// 标注线距离圆的距离
                let pointInCenter = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius + lineWidth / 2 + lineMargin)
                let pointInCenter_2 = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius + lineWidth / 2 + lineMargin + radius / 6)
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
                        lblMark.text = pieDataNameArray[i] + ":" + pieDataArray[i] + pieDataUnit
                    }
                }
                lblMark.sizeToFit()
//                lblMark.shadowColor = .white // 需要高亮标注时 打开注释看效果
//                lblMark.shadowOffset = CGSize(width: 0.5, height: 0.5)
                bgView.addSubview(lblMark)
                if cos(angle * CGFloat.pi / 180) >= -0.01 { // 偏右侧
                    lblMark.center = CGPoint(x: pointAtLabel.x + lblMark.bounds.size.width / 2 + 2, y: pointAtLabel.y)
                } else { // 偏左侧
                    lblMark.center = CGPoint(x: pointAtLabel.x - lblMark.bounds.size.width / 2 - 2, y: pointAtLabel.y)
                }
                
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
    
    // MARK: - tapAction
    @objc func tapAction(_ tap:UITapGestureRecognizer) {
        
    }
    
    // MARK: - other
    func caculatePointAtCircle(center:CGPoint, angle:CGFloat, radius:CGFloat) -> CGPoint {
        let angle_p = angle * CGFloat.pi / 180
        let x:CGFloat = radius * cos(angle_p)
        let y:CGFloat = radius * sin(angle_p)
        
        return CGPoint(x: center.x + x, y: center.y - y)
    }
}
