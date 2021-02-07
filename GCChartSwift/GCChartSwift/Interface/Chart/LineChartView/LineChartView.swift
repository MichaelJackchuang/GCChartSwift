//
//  LineChartView.swift
//  DemosInSwift
//
//  Created by 古创 on 2020/8/27.
//  Copyright © 2020 c. All rights reserved.
//

import UIKit

class LineChartView: UIView {

    // MARK: -  parameter
    
    /// 数据标签数组（x轴分组标题）
    var dataNameArray = [String]()
    
    /// 数据数组，当不是单条折线时为二维数组，其中每个元素数组为一条折线的数据
    var dataArray = [String]()
    
    /// y轴最大值，不设置这个值则自动查找数组中最大值
    var maxNumber = ""
    
    /// y轴刻度值，设置此数组则不自动计算y轴刻度值
    var yAxisNums = [String]()
    
    /// 是否显示数据水平线
    var showDataHorizontalLine = false
    
    /// 是否可以滚动 一般来说可以不用设置这个属性 当数据超过5组时可以滚动
    var scrollEnabled = true
    
    /// 顶点是否显示具体数据
    var showDataLabel = false
    
    /// 数据点是否加粗
    var showBlodPoint = false
    
    /// 折线线宽
    var lineWidth:CGFloat = 0
    
    /// 是否为平滑曲线
    var isSmooth = false
    
    /// 是否为密集数据
    var isDense = false
    
    /// 是否为单条线
    var isSingleLine = true
    
    /// 线条颜色
    var lineColor = [String]()
    
    /// 折线下部是否用颜色填充（仅单线条时此属性生效，且此属性设置为yes时线条颜色设置失效）
    var isFillWithColor = false
    
    /// 线条下部填充颜色
    var fillColor = ""
    
    /// 线条下部填充颜色透明度
    var fillAlpha:CGFloat = 0
    
    /// 折线是否用颜色描线（在填充线条下部区域时，是否用加深的颜色描线）
    var isDrawLineWhenFillColor = false
    
    /// 是否允许点击事件
    var touchEnable = false
    
    /// 点击事件回调（字典中传递数据，索引等信息）
    var tapBlock:(([String : Any]) -> Void)?
    
    // MARK: - private member property
    private lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var yAxisView:UIView = { // y轴view
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var xAxisView:UIView = { // x轴view
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var dataView:UIView = { // 数据view
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var yAxisViewWidth:CGFloat = 20 // y轴view宽度
    var yAxisViewTopMargin:CGFloat = 20 // y轴顶部预留高度
    var yAxisTitleFont:CGFloat = 8 // y轴刻度字体大小
    var xAxisViewHeight:CGFloat = 20 // x轴view高度
    var groupWidth:CGFloat = 0
    var pointArray = [CGPoint]() // 平滑曲线用的点坐标数组
    var xAxisTitleFont:CGFloat = 8 // x轴标题字体大小
    var dataLabelFont:CGFloat = 8 // 具体数据文字大小
    var dataNumberArray = [Float]() // 数据数组

    // MARK: - init
    /// 初始化一个折线图表
    /// - Parameter frame: frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        config()
    }
    
    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
    }
    
    // MARK: - config
    private func config() {
        lineWidth = 2
        if lineColor.isEmpty {
            lineColor.append("404040")
        }
        if fillAlpha == 0 {
            fillAlpha = 1.0
        }
        
        // scrollView
        scrollView.delegate = self
        addSubview(scrollView)
        
        addSubview(yAxisView)
        scrollView.addSubview(xAxisView)
        
    }
    
    // MARK: - resetLine
    private func resetSingleLine() {
        dataNumberArray.removeAll()
        for num in dataArray {
            dataNumberArray.append(Float(num) ?? 0.0)
        }
        
        yAxisView.frame = CGRect(x: 0, y: yAxisViewTopMargin, width: yAxisViewWidth, height: bounds.size.height - yAxisViewTopMargin)
        scrollView.frame = CGRect(x: yAxisViewWidth, y: 0, width: bounds.size.width - yAxisViewWidth, height: bounds.size.height)
        yAxisView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        let lineView = UIView(frame: CGRect(x: yAxisViewWidth - 1, y: 0, width: 1, height: yAxisView.bounds.size.height - xAxisViewHeight))
        lineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
        yAxisView.addSubview(lineView)
        
        var maxValue:Float = 0
        var maxNum:Float = 0
        var str = ""
        if yAxisNums.isEmpty { // 未传入刻度值，则自动计算
            maxValue = Float(dataNumberArray.max()!) // 寻找数组中最大值
            if self.maxNumber.isEmpty { // 未传入刻度最大值，则自动计算
                maxNum = approximateRoundNumber(String(format: "%f", maxValue))
            } else {
                maxNum = Float(self.maxNumber) ?? 1
            }
            
            str = String(String(format: "%f", maxNum).prefix(1))
            let level = (Int(maxNum) ) / (Int(str) ?? 1) // 数量级 整十或整百或整千等
            for i in 0..<(Int(str) ?? 0) { // y轴刻度
                let labelHeight:CGFloat = 16
                let labelY = CGFloat(i) * (lineView.bounds.size.height / CGFloat(Int(str)!))
                let lblY = yAxisView.bounds.size.height - xAxisViewHeight - labelHeight / 2 - labelY
                let lblYAxisNum = UILabel(frame: CGRect(x: 0, y: lblY, width: yAxisViewWidth - 1, height: labelHeight))
                lblYAxisNum.font = UIFont.systemFont(ofSize: yAxisTitleFont)
                lblYAxisNum.textColor = UIColor.colorWithHexString(color: "898989")
                lblYAxisNum.textAlignment = .center
                lblYAxisNum.text = String(format: "%d", i * level)
                yAxisView.addSubview(lblYAxisNum)
            }
            if !dataArray.isEmpty || !maxNumber.isEmpty {
                let labelHeight:CGFloat = 16
                let lblMax = UILabel(frame: CGRect(x: 0, y: -labelHeight / 2, width: yAxisViewWidth - 1, height: labelHeight))
                lblMax.font = UIFont.systemFont(ofSize: yAxisTitleFont)
                lblMax.textColor = UIColor.colorWithHexString(color: "898989")
                lblMax.textAlignment = .center
                lblMax.text = String(format: "%.f", maxNum)
                yAxisView.addSubview(lblMax)
            }
        } else {
            maxNum = Float(yAxisNums.last!) ?? 1
            for i in 0..<yAxisNums.count {
                let labelHeight:CGFloat = 16
                let lblY = yAxisView.bounds.size.height - xAxisViewHeight - labelHeight / 2 - CGFloat(yAxisNums.count - 1)
                let lblYAxisNum = UILabel(frame: CGRect(x: 0, y: lblY, width: yAxisViewWidth - 1, height: labelHeight))
                lblYAxisNum.font = UIFont.systemFont(ofSize: yAxisTitleFont)
                lblYAxisNum.textColor = UIColor.colorWithHexString(color: "898989")
                lblYAxisNum.textAlignment = .center
                lblYAxisNum.text = yAxisNums[i]
                yAxisView.addSubview(lblYAxisNum)
            }
        }
        
        groupWidth = scrollView.bounds.size.width / CGFloat(dataArray.count)
        if isDense {
            groupWidth = scrollView.bounds.size.width / 10
        }
        if dataArray.count <= 5 {
            scrollView.contentSize = CGSize(width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
            xAxisView.frame = CGRect(x: 0, y: scrollView.bounds.size.height - xAxisViewHeight, width: scrollView.bounds.size.width, height: xAxisViewHeight)
        } else {
            scrollView.contentSize = CGSize(width: groupWidth * CGFloat(dataArray.count), height: scrollView.bounds.size.height)
            xAxisView.frame = CGRect(x: 0, y: scrollView.bounds.size.height - xAxisViewHeight, width: groupWidth * CGFloat(dataArray.count), height: xAxisViewHeight)
        }
        
        // x轴
        for view in xAxisView.subviews { // 先移除再创建
            view.removeFromSuperview()
        }
        let xLineView = UIView(frame: CGRect(x: 0, y: 0, width: xAxisView.bounds.size.width, height: 1))
        xLineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
        xAxisView.addSubview(xLineView)
        
        // scrollView上的
        for view in scrollView.subviews {
            if view != xAxisView {
                view.removeFromSuperview()
            }
        }
        
        // 水平虚线
        if showDataHorizontalLine {
            if yAxisNums.isEmpty {
                for i in 0..<(Int(str) ?? 0) {
                    let dashH = CGFloat(i + 1) * (yAxisView.bounds.size.height - xAxisViewHeight) / CGFloat(Int(str)!)
                    let dashY = scrollView.bounds.size.height - xAxisViewHeight - dashH
                    let dashLineView = UIView(frame: CGRect(x: 0, y: dashY, width: scrollView.contentSize.width, height: 1))
                    scrollView.addSubview(dashLineView)
                    let lineLayer = CAShapeLayer()
                    lineLayer.bounds = dashLineView.bounds
                    lineLayer.position = CGPoint(x: dashLineView.bounds.size.width / 2, y: dashLineView.bounds.size.height / 2)
                    lineLayer.lineWidth = 0.5
                    lineLayer.lineDashPattern = [2,1]
                    lineLayer.strokeColor = UIColor.colorWithHexString(color: "dcdcdc").cgColor
                    // 设置路径
                    let path = CGMutablePath()
                    path.move(to: CGPoint(x: 0, y: dashLineView.bounds.size.height / 2))
                    path.addLine(to: CGPoint(x: dashLineView.bounds.size.width, y: dashLineView.bounds.size.height / 2))
                    lineLayer.path = path
                    dashLineView.layer.addSublayer(lineLayer)
                }
            } else {
                for i in 1..<yAxisNums.count {
                    let dashH = CGFloat(i) * (yAxisView.bounds.size.height - xAxisViewHeight) / CGFloat(yAxisNums.count - 1)
                    let dashY = scrollView.bounds.size.height - xAxisViewHeight - dashH
                    let dashLineView = UIView(frame: CGRect(x: 0, y: dashY, width: scrollView.contentSize.width, height: 1))
                    scrollView.addSubview(dashLineView)
                    let lineLayer = CAShapeLayer()
                    lineLayer.bounds = dashLineView.bounds
                    lineLayer.position = CGPoint(x: dashLineView.bounds.size.width / 2, y: dashLineView.bounds.size.height / 2)
                    lineLayer.lineWidth = 0.5
                    lineLayer.lineDashPattern = [2,1]
                    lineLayer.strokeColor = UIColor.colorWithHexString(color: "dcdcdc").cgColor
                    // 设置路径
                    let path = CGMutablePath()
                    path.move(to: CGPoint(x: 0, y: dashLineView.bounds.size.height / 2))
                    path.addLine(to: CGPoint(x: dashLineView.bounds.size.width, y: dashLineView.bounds.size.height / 2))
                    lineLayer.path = path
                    dashLineView.layer.addSublayer(lineLayer)
                }
            }
        }
        
        // dataView
        dataView.removeFromSuperview()
        dataView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        dataView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.bounds.size.height - xAxisViewHeight)
        dataView.backgroundColor = .clear
        scrollView.addSubview(dataView)
        if touchEnable && !dataArray.isEmpty {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            dataView.isUserInteractionEnabled = true
            dataView.addGestureRecognizer(tap)
        }
        
        if dataArray.isEmpty {
            return
        }
        
        // 背景layer(动画)
        let bgPath = UIBezierPath()
        bgPath.move(to: CGPoint(x: 0, y: dataView.bounds.size.height / 2))
        bgPath.addLine(to: CGPoint(x: dataView.bounds.size.width, y: dataView.bounds.size.height / 2))
        bgPath.lineWidth = dataView.bounds.size.height
        let bgLayer = CAShapeLayer()
        bgLayer.fillColor = UIColor.clear.cgColor
        bgLayer.strokeColor = UIColor.lightGray.cgColor
        bgLayer.strokeStart = 0
        bgLayer.strokeEnd = 1
        bgLayer.zPosition = 1
        bgLayer.lineWidth = dataView.bounds.size.height
        bgLayer.path = bgPath.cgPath
        dataView.layer.mask = bgLayer
        
        let dataPath = UIBezierPath()
        dataPath.lineWidth = lineWidth
        UIColor.colorWithHexString(color: lineColor.first!).setStroke()
        UIColor.colorWithHexString(color: lineColor.first!).setFill()
        dataPath.stroke()
        dataPath.fill()
        
        let linePath = UIBezierPath()
        linePath.lineWidth = lineWidth
        linePath.stroke()
        linePath.fill()
        
        pointArray.removeAll()
        // 起始点
        pointArray.append(CGPoint(x: 0, y: dataView.bounds.size.height))
        
        var groupTitle = ""
        for i in 0..<dataArray.count {
            if groupTitle == dataNameArray[i] { // x轴标题去重（相邻重复的不显示）
                continue
            }
            let groupCenterLineView = UIView(frame: CGRect(x: groupWidth * CGFloat(i) + groupWidth / 2 - 0.5, y: 1, width: 1, height: 5))
            groupCenterLineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
            xAxisView.addSubview(groupCenterLineView)
            
            // 分组标题
            let groupTitleLabel = UILabel()
            groupTitleLabel.font = UIFont.systemFont(ofSize: xAxisTitleFont)
            groupTitleLabel.textColor = UIColor.colorWithHexString(color: "898989")
            groupTitleLabel.textAlignment = .center
            groupTitleLabel.text = dataNameArray[i]
            groupTitleLabel.sizeToFit()
            groupTitleLabel.center = CGPoint(x: groupWidth * CGFloat(i) + groupWidth / 2, y: xAxisViewHeight - groupTitleLabel.bounds.size.height / 2)
            xAxisView.addSubview(groupTitleLabel)
            groupTitle = dataNameArray[i]
        }
        
        // 具体数据
        for i in 0..<dataArray.count {
            let num = dataArray[i]
            let heigh = (dataView.bounds.size.height - yAxisViewTopMargin) * CGFloat(Float(num)!)
            let pointHeight = dataView.bounds.size.height - heigh / CGFloat(maxNum)
            if isSmooth { // 是否为平滑曲线
                pointArray.append(CGPoint(x: groupWidth / 2 + groupWidth * CGFloat(i), y: pointHeight))
            } else {
                if i == 0 {
                    if isFillWithColor {
                        dataPath.move(to: CGPoint(x: groupWidth / 2, y: dataView.bounds.size.height))
                        dataPath.addLine(to: CGPoint(x: groupWidth / 2, y: pointHeight))
                        if isDrawLineWhenFillColor {
                            linePath.move(to: CGPoint(x: groupWidth / 2, y: pointHeight))
                        }
                    } else {
                        dataPath.move(to: CGPoint(x: groupWidth / 2, y: pointHeight))
                    }
                } else if i == dataArray.count - 1 {
                    dataPath.addLine(to: CGPoint(x: groupWidth / 2 + groupWidth * CGFloat(i), y: pointHeight))
                    if isFillWithColor {
                        dataPath.addLine(to: CGPoint(x: groupWidth / 2 + groupWidth * CGFloat(i), y: dataView.bounds.size.height))
                        if isDrawLineWhenFillColor {
                            linePath.addLine(to: CGPoint(x: groupWidth / 2 + groupWidth * CGFloat(i), y: pointHeight))
                        }
                    }
                } else {
                    dataPath.addLine(to: CGPoint(x: groupWidth / 2 + groupWidth * CGFloat(i), y: pointHeight))
                    if isDrawLineWhenFillColor {
                        linePath.addLine(to: CGPoint(x: groupWidth / 2, y: pointHeight))
                    }
                }
            }
        }
        
        // 平滑曲线轨迹
        if isSmooth {
            pointArray.append(CGPoint(x: dataView.bounds.size.width, y: dataView.bounds.size.height))
            for i in 0..<dataArray.count - 1 {
                let p1 = pointArray[i]
                let p2 = pointArray[i+1]
                let p3 = pointArray[i+2]
                let p4 = pointArray[i+3]
                if i == 0 {
                    if isFillWithColor {
                        dataPath.move(to: CGPoint(x: groupWidth / 2, y: dataView.bounds.size.height))
                        dataPath.addLine(to: p2)
                        if isDrawLineWhenFillColor {
                            linePath.move(to: p2)
                        }
                    } else {
                        dataPath.move(to: p2)
                    }
                }
                getControlPoint(dataPath, point: p1.x, y0: p1.y, x1: p2.x, y1: p2.y, x2: p3.x, y2: p3.y, x3: p4.x, y3: p4.y)
                if isDrawLineWhenFillColor {
                    getControlPoint(linePath, point: p1.x, y0: p1.y, x1: p2.x, y1: p2.y, x2: p3.x, y2: p3.y, x3: p4.x, y3: p4.y)
                }
            }
            if isFillWithColor {
                dataPath.addLine(to: CGPoint(x: groupWidth / 2 + groupWidth * CGFloat(dataArray.count - 1), y: dataView.bounds.size.height))
            }
        }
        
        let dataLayer = CAShapeLayer()
        dataLayer.path = dataPath.cgPath
        if isFillWithColor {
            dataLayer.strokeColor = nil
            dataLayer.fillColor = UIColor.colorWithHexString(color: fillColor).cgColor
        } else {
            dataLayer.strokeColor = UIColor.colorWithHexString(color: lineColor.first!).cgColor
            dataLayer.fillColor = nil
        }
        dataLayer.lineWidth = lineWidth
        dataView.layer.addSublayer(dataLayer)
        
        if isDrawLineWhenFillColor { // 底部填充颜色时数据画线
            let lineDataLayer = CAShapeLayer()
            lineDataLayer.path = linePath.cgPath
            lineDataLayer.strokeColor = UIColor.colorWithHexString(color: lineColor.first!).cgColor
            lineDataLayer.fillColor = nil
            lineDataLayer.lineWidth = lineWidth
            dataView.layer .addSublayer(lineDataLayer)
        }
        
        if showDataLabel { // 显示具体数值
            for (i, num) in dataArray.enumerated() {
                let heigh = (dataView.bounds.size.height - yAxisViewTopMargin) * CGFloat(Float(num)!)
                let pointHeight = dataView.bounds.size.height - heigh / CGFloat(maxNum)
                let dataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: groupWidth, height: 16))
                dataLabel.center = CGPoint(x: groupWidth / 2 + groupWidth * CGFloat(i), y: pointHeight - 8)
                dataLabel.font = UIFont.systemFont(ofSize: dataLabelFont)
                dataLabel.textColor = UIColor.colorWithHexString(color: "404040")
                dataLabel.textAlignment = .center
                dataLabel.text = num
                dataView.addSubview(dataLabel)
            }
        }
        
        // 动画
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0
        strokeAnimation.toValue = 1
        strokeAnimation.duration = 1.0
        strokeAnimation.repeatCount = 1
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeAnimation.isRemovedOnCompletion = true
        bgLayer.add(strokeAnimation, forKey: "lineAnimation")
    }
    
    private func resetMultiLine() {
        
    }
    
    // MARK: - resetData
    func resetData() {
        if isSingleLine {
            resetSingleLine()
        } else {
            resetMultiLine()
        }
    }
    
    // MARK: - tapAction
    @objc func tapAction(_ tap:UITapGestureRecognizer) {
        
    }
    
    // MARK: - other
    // 向上取整十、整百、整千等值
    func approximateRoundNumber(_ numString:String) -> Float {
        var length = numString.count
        if numString.contains(".") {
            length = numString.components(separatedBy: ".").first!.count
        }
        var numberGrade = "1" // 数字量级
        for _ in 0..<length - 1 {
            numberGrade = numberGrade + "0"
        }
        var  level = ceil(Double((Int(numString) ?? 1) / Int(numberGrade)!))
        if numString.contains(".") {
            if Int(numString.components(separatedBy: ".").first!)! >= 1 {
                level = ceil(Double((Int(numString.components(separatedBy: ".").first!) ?? 1) / Int(numberGrade)!)) + 1 // 向上取整
            }
        }
        return  Float(level * Double(numberGrade)!)
    }
    
    // 传入四个点求两个控制点 （画2，3之间的曲线，需要传入1，2，3，4的坐标）
//    参考自：https://www.jianshu.com/p/c33081adce28
//    实在是看球不懂
    func getControlPoint(_ bezierPath:UIBezierPath,
                         point x0:CGFloat, y0:CGFloat,
                         x1:CGFloat, y1:CGFloat,
                         x2:CGFloat, y2:CGFloat,
                         x3:CGFloat, y3:CGFloat) {
        let smooth_value:CGFloat = 0.6
        let xc1 = (x0 + x1) / 2
        let yc1 = (y0 + y1) / 2
        let xc2 = (x1 + x2) / 2
        let yc2 = (y1 + y2) / 2
        let xc3 = (x2 + x3) / 2
        let yc3 = (y2 + y3) / 2
        let len1 = sqrtf(Float((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0)))
        let len2 = sqrtf(Float((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)))
        let len3 = sqrtf(Float((x3 - x2) * (x3 - x2) + (y3 - y2) * (y3 - y2)))
        let k1 = len1 / (len1 + len2)
        let k2 = len2 / (len2 + len3)
        let xm1 = xc1 + (xc2 - xc1) * CGFloat(k1)
        let ym1 = yc1 + (yc2 - yc1) * CGFloat(k1)
        let xm2 = xc2 + (xc3 - xc2) * CGFloat(k2)
        let ym2 = yc2 + (yc3 - yc2) * CGFloat(k2)
        let ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1
        let ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1
        let ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2
        let ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2
        bezierPath .addCurve(to: CGPoint(x: x2, y: y2), controlPoint1: CGPoint(x: ctrl1_x, y: ctrl1_y), controlPoint2: CGPoint(x: ctrl2_x, y: ctrl2_y))
    }
}

// MARK: - UIScrollViewDelegate
extension LineChartView: UIScrollViewDelegate {
    
}
