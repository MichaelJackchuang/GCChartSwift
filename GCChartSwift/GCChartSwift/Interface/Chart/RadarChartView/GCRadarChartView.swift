//
//  GCRadarChartView.swift
//  DemosInSwift
//
//  Created by 古创 on 2021/1/6.
//  Copyright © 2021 c. All rights reserved.
//

import UIKit

enum GCRadarChartViewAnimationStyle {
    case none
    case scale
    case circleStroke
}

class GCRadarChartView: UIView {

    // MARK: - member property
    
    /// 分组名称数组
    var radarNameArray = [String]()
    
    /// 数据数组（数据个数在3~8个时候为最佳超过8个不保证UI效果）
    var radarDataArray = [String]()
    
    /// 数据最大值（必填项，不设置的话无法计算，则无法绘图）
    var maxValue:String = ""
    
    /// 是否填充颜色（默认否）
    var isFilledColor:Bool = false
    
    /// 雷达填充颜色
    var radarFillColor:String = "f5447d"
    
    /// 填充颜色不透明度
    var radarFillColorOpacity:CGFloat = 1
    
    /// 雷达线条颜色
    var radarLineColor:String = "f5447d"
    
    /// 雷达线宽
    var radarLineWidth:CGFloat = 1
    
    /// 是否显示具体数值
    var showDataLabel:Bool = false
    
    /// 是否显示尖角圆点
    var showPoint:Bool = false
    
    /// 是否显示中心圆点
    var showCenter:Bool = false
    
    /// 是否显示背景线
    var showBgLine:Bool = false
    
    /// 背景线 颜色（默认为黑色)
    var bgLineColor:String = "000000"
    
    /// 是否显示背景色
    var showBgColor:Bool = false
    
    /// 雷达背景色（默认为白色)
    var radarBgColor:String = "ffffff"
    
    /// 动画风格（默认无动画）
    var animationStyle:GCRadarChartViewAnimationStyle = .none
    
    // MARK: private property
    private var bgWidth:CGFloat = 0
    private var bgHeight:CGFloat = 0
    
    // MARK: - init
    /// 初始化雷达图
    /// - Parameters:
    ///   - frame: frame
    ///   - nameArray: 名称数组（元素个数需和数据数组元素个数一致）
    ///   - dataArray: 数据数组
    ///   - maxValue: 标尺最大值
    init(frame:CGRect, nameArray:[String], dataArray:[String], maxValue:String) {
        super.init(frame: frame)
        
        radarNameArray = nameArray
        radarDataArray = dataArray
        self.maxValue = maxValue
        
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
    func resetData() {
        resetRadar()
    }
    
}

// MARK: - config
extension GCRadarChartView {
    func config() {
        
        if radarFillColorOpacity < 0 {
            radarFillColorOpacity = 0
        } else if radarFillColorOpacity > 1 {
            radarFillColorOpacity = 1
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
        bgHeight = bounds.size.height - 50
    }
}

// MARK: - reload
extension GCRadarChartView {
    func resetRadar() {
        // 先移除之前创建的子视图
        for subview in bgView.subviews {
            subview.removeFromSuperview()
        }
        bgView.layer.sublayers?.removeAll()
        bgView.layer.mask?.removeFromSuperlayer()
        
        // 必须设置最大值
        if maxValue.isEmpty {
            return
        }
        
        let radius:CGFloat = ([bgWidth - 20, bgHeight - 20].min() ?? 0) / 2
        
        // 背景（遮罩动画用到的背景）
        let bgPath = UIBezierPath(arcCenter: bgView.center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi / 2 * 3, clockwise: true)
        let bgLayer = CAShapeLayer()
        bgLayer.fillColor = UIColor.clear.cgColor
        bgLayer.strokeColor = UIColor.lightGray.cgColor
        bgLayer.strokeStart = 0
        bgLayer.strokeEnd = 1
        bgLayer.zPosition = 1
        bgLayer.lineWidth = radius * 2
        bgLayer.path = bgPath.cgPath
        
        let startAngle_p:CGFloat = 90
        let eachAngle:CGFloat = CGFloat(360 / radarDataArray.count)
        let bgLinePath = UIBezierPath()
        let dataPath = UIBezierPath()
        var dataStartPoint = bgView.center // 数据起始点
//        var dataStartRadius:CGFloat = 0 // 数据起始高度
        for (i, numStr) in radarDataArray.enumerated() {
            let num = CGFloat(Float(numStr) ?? 0)
            
            let angle = startAngle_p - eachAngle * CGFloat(i)
            let pointAtMax = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius)
            let valueRadius = num / CGFloat(Float(maxValue) ?? 0) * radius
            let valuePoint = caculatePointAtCircle(center: bgView.center, angle: angle, radius: valueRadius)
            if i == 0 {
                bgLinePath.move(to: pointAtMax)
                dataPath.move(to: valuePoint)
                dataStartPoint = valuePoint
//                dataStartRadius = valueRadius
            } else {
                bgLinePath.addLine(to: pointAtMax)
                dataPath.addLine(to: valuePoint)
            }
            
            // 组名
            let pointName = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius + 10)
            let lblName = UILabel()
            lblName.textColor = .black
            lblName.font = UIFont.systemFont(ofSize: 15)
            lblName.text = radarNameArray[i]
            lblName.sizeToFit()
            bgView.addSubview(lblName)
            if cos(angle * CGFloat.pi / 180) >= -0.01 { // 偏右侧
                if i == 0 || (radarDataArray.count % 2 == 0 && radarDataArray.count / 2 == i) { // 偶数 正下方或者 正上方
                    lblName.center = pointName
                } else {
                    lblName.center = CGPoint(x: pointName.x + lblName.bounds.size.width / 2, y: pointName.y)
                }
            } else { // 偏左侧
                lblName.center = CGPoint(x: pointName.x - lblName.bounds.size.width / 2, y: pointName.y)
            }
        }
        
        // 连接起止点
        bgLinePath.addLine(to: caculatePointAtCircle(center: bgView.center, angle: 90, radius: radius))
        dataPath.addLine(to: dataStartPoint)
        
        // 背景线（外框）
        let bgLineLayer = CAShapeLayer()
        bgLineLayer.lineWidth = 1
        if showBgLine {
            bgLineLayer.strokeColor = UIColor.colorWithHexString(color: bgLineColor).cgColor
        } else {
            bgLineLayer.strokeColor = nil
        }
        if showBgColor {
            bgLineLayer.fillColor = UIColor.colorWithHexString(color: radarBgColor).cgColor
        } else {
            bgLineLayer.fillColor = nil
        }
        bgLineLayer.path = bgLinePath.cgPath
//        bgView.layer.addSublayer(bgLineLayer)
        bgView.layer.insertSublayer(bgLineLayer, at: 0)// 如果直接addSublayer则背景色会遮挡内部框线
        
        // 数据
        let dataLayer = CAShapeLayer()
        dataLayer.lineWidth = radarLineWidth
        dataLayer.strokeColor = UIColor.colorWithHexString(color: radarLineColor).cgColor
        if isFilledColor {
            dataLayer.fillColor = UIColor.colorWithHexString(color: radarFillColor, alpha: radarFillColorOpacity).cgColor
        } else {
            dataLayer.fillColor = nil
        }
        dataLayer.path = dataPath.cgPath
        bgView.layer.addSublayer(dataLayer)
        
        // 内部连接线
        if showBgLine {
            for i in 0..<radarDataArray.count {
                let angle = startAngle_p - eachAngle * CGFloat(i)
                let pointAtMax = caculatePointAtCircle(center: bgView.center, angle: angle, radius: radius)
                
                let linePath = UIBezierPath()
                linePath.move(to: bgView.center)
                linePath.addLine(to: pointAtMax)
                let lineLayer = CAShapeLayer()
                lineLayer.lineWidth = 1
                lineLayer.strokeColor = UIColor.colorWithHexString(color: bgLineColor).cgColor
                lineLayer.fillColor = nil
                lineLayer.path = linePath.cgPath
                bgView.layer.addSublayer(lineLayer)
            }
        }
        
        // 数据顶点
        if showPoint {
            for (i,numStr) in radarDataArray.enumerated() {
                let num = CGFloat(Float(numStr) ?? 0)
                let angle = startAngle_p - eachAngle * CGFloat(i)
                let valueRadius = num / CGFloat(Float(maxValue) ?? 0) * radius
                let valuePoint = caculatePointAtCircle(center: bgView.center, angle: angle, radius: valueRadius)
                let pointLayer = CAShapeLayer()
                pointLayer.bounds = CGRect(x: 0, y: 0, width: 6, height: 6)
                pointLayer.backgroundColor = UIColor.white.cgColor
                pointLayer.cornerRadius = 3
                pointLayer.masksToBounds = true
                pointLayer.position = valuePoint
                bgView.layer.addSublayer(pointLayer)
                
                // 动画
                if animationStyle == .scale {
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.duration = 0.8 // 持续时间
                    animation.repeatCount = 1 // 重复次数
                    animation.autoreverses = false // 不执行逆动画
                    animation.fromValue = NSValue(cgPoint: bgView.center)
                    animation.toValue = NSValue(cgPoint: valuePoint)
                    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // 先快后慢
                    pointLayer.add(animation, forKey: "pointAnimation")
                }
            }
        }
        
        // 显示具体数据
        if showDataLabel {
            for (i,numStr) in radarDataArray.enumerated() {
                let num = CGFloat(Float(numStr) ?? 0)
                let angle = startAngle_p - eachAngle * CGFloat(i)
                let valueRadius = num / CGFloat(Float(maxValue) ?? 0) * radius
                let pointValue = caculatePointAtCircle(center: bgView.center, angle: angle, radius: valueRadius + 10)
                let lblValue = UILabel()
                lblValue.textColor = .black
                lblValue.font = UIFont.systemFont(ofSize: 12)
                lblValue.text = numStr
                lblValue.sizeToFit()
                lblValue.shadowColor = .lightGray
                lblValue.shadowOffset = CGSize(width: 0.5, height: 0.5)
                bgView.addSubview(lblValue)
                // 动画
                if animationStyle == .scale {
                    lblValue.center = bgView.center
                    UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseInOut, animations: {
                        lblValue.transform = CGAffineTransform(translationX: pointValue.x - lblValue.center.x, y: pointValue.y - lblValue.center.y)
                    }, completion: nil)
                } else {
                    lblValue.center = pointValue
                }
            }
        }
        
        // 中心店
        if showCenter {
            let centerLayer = CAShapeLayer()
            centerLayer.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            centerLayer.backgroundColor = UIColor.white.cgColor
            centerLayer.cornerRadius = 5
            centerLayer.masksToBounds = true
            centerLayer.position = bgView.center
            bgView.layer.addSublayer(centerLayer)
        }
        
        
        // 动画
        if animationStyle == .scale {
            let dataStartPath = UIBezierPath()
            for i in 0..<radarDataArray.count {
                if i == 0 {
                    dataStartPath.move(to: bgView.center)
                } else {
                    dataStartPath.addLine(to: bgView.center)
                }
            }
            dataStartPath.addLine(to: bgView.center)
            
            let scaleAnimation = CABasicAnimation(keyPath: "path")
            scaleAnimation.duration = 0.8
            scaleAnimation.repeatCount = 1
            scaleAnimation.autoreverses = false
            scaleAnimation.fromValue = dataStartPath.cgPath
            scaleAnimation.toValue = dataPath.cgPath
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut) // 先快后慢
            dataLayer.add(scaleAnimation, forKey: "scaleAnimation")
        }
        
        if animationStyle == .circleStroke {
            bgView.layer.mask = bgLayer // 设置遮罩
            // 遮罩动画
            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnimation.fromValue = 0 // 起始值
            strokeAnimation.toValue = 1 // 结束值
            strokeAnimation.duration = 1 // 动画持续时间
            strokeAnimation.repeatCount = 1 // 重复次数
            strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            strokeAnimation.isRemovedOnCompletion = true
            bgLayer.add(strokeAnimation, forKey: "radarAnimation")
        }
    }
    
    // MARK: - other
    func caculatePointAtCircle(center:CGPoint, angle:CGFloat, radius:CGFloat) -> CGPoint {
        let angle_p = angle * CGFloat.pi / 180
        let x:CGFloat = radius * cos(angle_p)
        let y:CGFloat = radius * sin(angle_p)
        
        return CGPoint(x: center.x + x, y: center.y - y)
    }
}
