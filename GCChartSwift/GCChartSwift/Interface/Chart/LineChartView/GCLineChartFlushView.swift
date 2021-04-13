//
//  GCLineChartFlushView.swift
//  DemosInSwift
//
//  Created by 古创 on 2020/8/27.
//  Copyright © 2020 c. All rights reserved.
//

import UIKit

// 起点从0点开始的折线图
class GCLineChartFlushView: UIView {

    // MARK: -  parameter
    
    /// 数据标签数组（x轴分组标题）
    var dataNameArray = [String]()
    
    /// 单线条数据数组
    var singleDataArray = [String]()
    
    /// 多线条数据数组（二维数组）(每个元素表示一条线)
    var multiDataArray = [[String]]()
    
    /// y轴刻度值，递增，设置此数组则不自动计算y轴刻度值，传入刻度时必须包含0
    var yAxisNums = [String]()
    
    /// 是否显示数据水平线
    var showDataHorizontalLine:Bool = false
    
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
    
    /// 是否为单条线
    var isSingleLine = true
    
    /// 线条颜色
    var lineColor = [String]()
    
    /// 折线下部是否用颜色填充（仅单线条时此属性生效，且此属性设置为yes时线条颜色设置失效）
    var isFillWithColor = false
    
    /// 线条下部填充颜色
    var fillColor = "f9856c"
    
    /// 线条下部填充颜色透明度
    var fillAlpha:CGFloat = 0
    
    /// 折线是否用颜色描线（在填充线条下部区域时，是否用加深的颜色描线）
    var isDrawLineWhenFillColor = false
    
    /// 单线条下部填充颜色是否渐变
    var isGradientFillColor:Bool = false
    
    /// 是否允许点击事件
    var touchEnable = false
    
    /// 点击事件回调（字典中传递数据，索引等信息）
    var tapBlock:(([String : Any]) -> Void)?
    
    
    
    // MARK: private property
    private var bgWidth:CGFloat = 0
    private var bgHeight:CGFloat = 0
    private var yAxisHeight:CGFloat = 0
    private var yAxisWidth:CGFloat = 20 // y轴view宽度
    private var yAxisTopMagin:CGFloat = 20 // y轴顶部预留高度
    private var yAxisTitleFont:CGFloat = 8 // y轴刻度字体大小
    private var xAxisHeight:CGFloat = 20 // x轴view高度
    private var xAxisWidth:CGFloat = 0
    private var groupWidth:CGFloat = 0 // 每组数据背景宽度
    private var pointArray = [CGPoint]() // 平滑曲线用的点坐标数组
    private var xAxisTitleFont:CGFloat = 8 // x轴标题字体大小
    private var dataLabelFont:CGFloat = 8 // 具体数据文字大小
    private var singleDataNumberArray = [Float]() // 单线数据数组
    private var multiDataNumberArray = [[Float]]() // 多线数据数组

    // MARK: - init
    init(frame: CGRect, nameArray:[String], dataArray:[String]) {
        super.init(frame: frame)
        
        dataNameArray = nameArray
        singleDataArray = dataArray
        config()
    }
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        config()
    }
    
    // MARK: - UI property
    let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    // y轴view
    let yAxisView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // x轴view
    let xAxisView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let dataView:UIView = { // 数据view
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - resetData
    func resetData() {
        if isSingleLine {
            resetSingleLine()
        } else {
            resetMultiLine()
        }
    }
}

// MARK: - config
extension GCLineChartFlushView {
    func config() {
        lineWidth = 2
        if lineColor.isEmpty {
//            lineColor.append("404040")
            lineColor = ["308ff7","fbca58","f5447d","a020f0","00ffff","00ff00"]
        }
        if fillAlpha == 0 {
            fillAlpha = 1.0
        }
        
        setUI()
    }
    
    func setUI() {
        addSubview(yAxisView)
//        scrollView.addSubview(xAxisView)
        addSubview(yAxisView)
        yAxisView.snp.makeConstraints { (make) in
            make.top.equalTo(yAxisTopMagin) // yAxisTopMagin
            make.left.bottom.equalTo(0)
            make.width.equalTo(30)
        }
        
        // scrollView
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.equalTo(yAxisView.snp.right)
            make.top.bottom.right.equalTo(0)
        }
        scrollView.isScrollEnabled = scrollEnabled
        
        scrollView.addSubview(xAxisView)
        
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgWidth = scrollView.bounds.size.width
        bgHeight = scrollView.bounds.size.height - yAxisTopMagin
        
        yAxisWidth = yAxisView.bounds.size.width
        yAxisHeight = yAxisView.bounds.size.height
    }
}

// MARK: - resetLine
extension GCLineChartFlushView {
    // 单线
    private func resetSingleLine() {
        // y轴设置
        for subview in yAxisView.subviews {
            subview.removeFromSuperview()
        }
        let lineView = UIView(frame: CGRect(x: yAxisWidth - 1, y: 0, width: 1, height: yAxisHeight - xAxisHeight))
        lineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
        yAxisView.addSubview(lineView)
        
        singleDataNumberArray.removeAll()
        for num in singleDataArray {
            singleDataNumberArray.append(Float(num) ?? 0.0)
        }
        
        var maxValue:Float = 0 // 数组最大值
        var minValue:Float = 0 // 数组最小值
        var maxNum:Float = 0 // y刻度最大值
        var minNum:Float = 0 // y刻度最小值
        var str = ""
        var level:Int = 1
        var temp = 0
        var zeroY:CGFloat = 0 // 用于传入刻度值时，记录0的高度
        
        maxValue = singleDataNumberArray.max() ?? 0 // 寻找数组中最大值
        minValue = singleDataNumberArray.min() ?? 0 // 寻找数组中最小值
        
        if yAxisNums.isEmpty { // 未传入刻度值，则自动计算
            if minValue >= 0 { // 最小值大于0，则无负轴
                maxNum = approximateRoundNumber("\(maxValue)")
                minNum = 0
                str = String(String(format: "%f", maxNum).prefix(1)) // 获取最大刻度字符的第一位
                str = str == "0" ? "1" : str
                level = (Int(maxNum) ) / Int(str)! // 数量级 整十或整百或整千等
            } else if maxValue <= 0 { // 最大值小于0，则无正轴
                maxNum = 0
                minNum = -approximateRoundNumber("\(-minValue)")
                str = String(String(format: "%f", -minNum).prefix(1)) // 获取最大刻度字符的第一位
                str = str == "0" ? "1" : str
                level = (Int(minNum) ) / Int(str)! // 数量级 整十或整百或整千等
            } else { // 最大值大于0，最小值小于0，则正负轴都有
                maxNum = approximateRoundNumber("\(maxValue)")
                minNum = -approximateRoundNumber("\(-minValue)")
                let absMax = [maxNum, -minNum].max() ?? 0
                maxNum = absMax
                minNum = -absMax
                str = String(String(format: "%f", absMax).prefix(1)) // 获取最大刻度字符的第一位
                str = str == "0" ? "1" : str
                level = (Int(absMax) ) / Int(str)! // 数量级 整十或整百或整千等
            }
            
            if minValue >= 0 { // 最小值大于0，则无负轴
                for i in 0..<Int(str)! {
                    let lblY = yAxisHeight - xAxisHeight - 8 - CGFloat(i) * lineView.bounds.size.height / CGFloat(Int(str)!)
                    let lblYAxisNum = UILabel(frame: CGRect(x: 0, y: lblY, width: yAxisWidth - 1, height: 16))
                    lblYAxisNum.font = UIFont.systemFont(ofSize: 8)
                    lblYAxisNum.textColor = UIColor.colorWithHexString(color: "898989")
                    lblYAxisNum.textAlignment = .center
                    lblYAxisNum.text = "\(i * level)"
                    yAxisView.addSubview(lblYAxisNum)
                }
                if !singleDataArray.isEmpty {
                    let lblMax = UILabel(frame: CGRect(x: 0, y: -8, width: yAxisWidth - 1, height: 16))
                    lblMax.font = UIFont.systemFont(ofSize: 8)
                    lblMax.textColor = UIColor.colorWithHexString(color: "898989")
                    lblMax.textAlignment = .center
                    lblMax.text = String(format: "%.f", maxNum)
                    yAxisView.addSubview(lblMax)
                }
            } else if maxValue <= 0 { // 最大值小于0，则无正轴
                for i in 0 ..< Int(str)! {
                    let lblY = -8 + CGFloat(i) * lineView.bounds.size.height / CGFloat(Int(str)!)
                    let lblYAxisNum = UILabel(frame: CGRect(x: 0, y: lblY, width: yAxisWidth - 1, height: 16))
                    lblYAxisNum.font = UIFont.systemFont(ofSize: 8)
                    lblYAxisNum.textColor = UIColor.colorWithHexString(color: "898989")
                    lblYAxisNum.textAlignment = .center
                    lblYAxisNum.text = "\(i * level)"
                    yAxisView.addSubview(lblYAxisNum)
                }
                if !singleDataArray.isEmpty {
                    let lblMin = UILabel(frame: CGRect(x: 0, y: lineView.bounds.size.height - 8, width: yAxisWidth - 1, height: 16))
                    lblMin.font = UIFont.systemFont(ofSize: 8)
                    lblMin.textColor = UIColor.colorWithHexString(color: "898989")
                    lblMin.textAlignment = .center
                    lblMin.text = String(format: "%.f", minNum)
                    yAxisView.addSubview(lblMin)
                    
                }
            } else {
                temp = Int(str)!
                for i in 0 ..< Int(str)! * 2 {
                    let lblY = yAxisHeight - xAxisHeight - 8 - CGFloat(i) * lineView.bounds.size.height / CGFloat(Int(str)! * 2)
                    let lblYAxisNum = UILabel(frame: CGRect(x: 0, y: lblY, width: yAxisWidth - 1, height: 16))
                    lblYAxisNum.font = UIFont.systemFont(ofSize: 8)
                    lblYAxisNum.textColor = UIColor.colorWithHexString(color: "898989")
                    lblYAxisNum.textAlignment = .center
                    lblYAxisNum.text = "\((i - temp) * level)"
                    yAxisView.addSubview(lblYAxisNum)
                }
                if !singleDataArray.isEmpty {
                    let lblMax = UILabel(frame: CGRect(x: 0, y: -8, width: yAxisWidth - 1, height: 16))
                    lblMax.font = UIFont.systemFont(ofSize: 8)
                    lblMax.textColor = UIColor.colorWithHexString(color: "898989")
                    lblMax.textAlignment = .center
                    let absMax = [maxNum, -minNum].max() ?? 0
                    lblMax.text = String(format: "%.f", absMax)
                    yAxisView.addSubview(lblMax)
                }
            }
            
//            if minValue >= 0 { // 最小值大于0，则无负轴
//
//            } else if maxValue <= 0 { // 最大值小于0，则无正轴
//
//            } else {
//
//            }
        } else {
            var yAxisNumArray = [Float]()
            for num in yAxisNums {
                yAxisNumArray.append(Float(num) ?? 0.0)
            }
            maxNum = yAxisNumArray.max() ?? 0 // 寻找数组中最大值
            minNum = yAxisNumArray.min() ?? 0 // 寻找数组中最小值
            
//            maxNum = Float(yAxisNums.last!) ?? 1
            for i in 0..<yAxisNums.count {
                let labelHeight:CGFloat = 16
                let labelY = CGFloat(i) * (lineView.bounds.size.height / CGFloat(yAxisNums.count - 1))
                let lblY = yAxisView.bounds.size.height - xAxisHeight - labelHeight / 2 - labelY
                let lblYAxisNum = UILabel(frame: CGRect(x: 0, y: lblY, width: yAxisWidth - 1, height: labelHeight))
                lblYAxisNum.font = UIFont.systemFont(ofSize: yAxisTitleFont)
                lblYAxisNum.textColor = UIColor.colorWithHexString(color: "898989")
                lblYAxisNum.textAlignment = .center
                lblYAxisNum.text = yAxisNums[i]
                yAxisView.addSubview(lblYAxisNum)
                if Int(yAxisNums[yAxisNums.count - i - 1]) == 0 {
                    zeroY = yAxisTopMagin + CGFloat(i) * (lineView.bounds.size.height / CGFloat(yAxisNums.count - 1))
                }
            }
        }
        
        // 确定滚动内容大小和组宽度
        if scrollEnabled {
            if singleDataArray.count <= 5 {
                groupWidth = bgWidth / CGFloat(singleDataArray.count - 1)
                scrollView.contentSize = CGSize(width: bgWidth, height: 0)
                xAxisView.frame = CGRect(x: 0, y: bgHeight, width: bgWidth, height: xAxisHeight)
            } else {
                groupWidth = bgWidth / 4
                scrollView.contentSize = CGSize(width: groupWidth * CGFloat(singleDataArray.count - 1), height: 0)
                xAxisView.frame = CGRect(x: 0, y: bgHeight, width: groupWidth * CGFloat(singleDataArray.count - 1), height: xAxisHeight)
            }
        } else {
            groupWidth = bgWidth / CGFloat(singleDataArray.count - 1)
            scrollView.contentSize = CGSize(width: bgWidth, height: 0)
            xAxisView.frame = CGRect(x: 0, y: bgHeight, width: bgWidth, height: xAxisHeight)
        }
        
        xAxisWidth = xAxisView.bounds.size.width
        
        // x轴
        // 移除xAxisView子视图
        for subview in xAxisView.subviews {
            subview.removeFromSuperview()
        }
        
        let xLineView = UIView(frame: CGRect(x: 0, y: 0, width: xAxisWidth, height: 1))
        xLineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
        xAxisView.addSubview(xLineView)
        
        // 移除scrollView子视图
        for subview in scrollView.subviews {
            if subview != xAxisView {
                subview.removeFromSuperview()
            }
        }
        
        // 水平虚线
        if showDataHorizontalLine {
            if yAxisNums.isEmpty { // 未传入刻度值
                if minValue >= 0 { // 最小值大于0，则无负轴
                    for i in 0 ..< Int(str)! {
                        let lineY = yAxisTopMagin + CGFloat(i) * (lineView.bounds.size.height / CGFloat(Int(str)!))
                        let dashLineView = UIView(frame: CGRect(x: 0, y: lineY, width: xAxisWidth, height: 1))
                        scrollView.addSubview(dashLineView)
                        let path = UIBezierPath()
                        path.move(to: CGPoint(x: 0, y: dashLineView.bounds.size.height / 2))
                        path.addLine(to: CGPoint(x: dashLineView.bounds.size.width, y: dashLineView.bounds.size.height / 2))
                        let dashLineLayer = CAShapeLayer()
                        dashLineLayer.bounds = dashLineView.bounds
                        dashLineLayer.position = CGPoint(x: dashLineView.bounds.size.width / 2, y: dashLineView.bounds.size.height / 2)
                        dashLineLayer.lineWidth = 0.5
                        dashLineLayer.lineDashPattern = [2,1]
                        dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "dcdcdc").cgColor
                        dashLineLayer.path = path.cgPath
                        dashLineView.layer.addSublayer(dashLineLayer)
                    }
                } else if maxValue <= 0 { // 最大值小于0，则无正轴
                    for i in 0 ..< Int(str)! {
                        let lineY = yAxisTopMagin + CGFloat(i) * (lineView.bounds.size.height / CGFloat(Int(str)!))
                        let dashLineView = UIView(frame: CGRect(x: 0, y: lineY, width: xAxisWidth, height: 1))
                        scrollView.addSubview(dashLineView)
                        let path = UIBezierPath()
                        path.move(to: CGPoint(x: 0, y: dashLineView.bounds.size.height / 2))
                        path.addLine(to: CGPoint(x: dashLineView.bounds.size.width, y: dashLineView.bounds.size.height / 2))
                        let dashLineLayer = CAShapeLayer()
                        dashLineLayer.bounds = dashLineView.bounds
                        dashLineLayer.position = CGPoint(x: dashLineView.bounds.size.width / 2, y: dashLineView.bounds.size.height / 2)
                        if i == 0 {
                            dashLineLayer.lineWidth = 1
                            dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "898989").cgColor
                        } else {
                            dashLineLayer.lineWidth = 0.5
                            dashLineLayer.lineDashPattern = [2,1]
                            dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "dcdcdc").cgColor
                        }
                        dashLineLayer.path = path.cgPath
                        dashLineView.layer.addSublayer(dashLineLayer)
                    }
                } else {
                    for i in 0 ..< Int(str)! * 2 {
                        let lineY = yAxisTopMagin + CGFloat(i) * (lineView.bounds.size.height / CGFloat(Int(str)! * 2))
                        let dashLineView = UIView(frame: CGRect(x: 0, y: lineY, width: xAxisWidth, height: 1))
                        scrollView.addSubview(dashLineView)
                        let path = UIBezierPath()
                        path.move(to: CGPoint(x: 0, y: dashLineView.bounds.size.height / 2))
                        path.addLine(to: CGPoint(x: dashLineView.bounds.size.width, y: dashLineView.bounds.size.height / 2))
                        let dashLineLayer = CAShapeLayer()
                        dashLineLayer.bounds = dashLineView.bounds
                        dashLineLayer.position = CGPoint(x: dashLineView.bounds.size.width / 2, y: dashLineView.bounds.size.height / 2)
                        if i == temp {
                            dashLineLayer.lineWidth = 1
                            dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "898989").cgColor
                        } else {
                            dashLineLayer.lineWidth = 0.5
                            dashLineLayer.lineDashPattern = [2,1]
                            dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "dcdcdc").cgColor
                        }
                        dashLineLayer.path = path.cgPath
                        dashLineView.layer.addSublayer(dashLineLayer)
                    }
                }
            } else { // 传入刻度值
                for i in 0..<yAxisNums.count - 1 {
                    let lineY = yAxisTopMagin + CGFloat(i) * (lineView.bounds.size.height / CGFloat(yAxisNums.count - 1))
                    let dashLineView = UIView(frame: CGRect(x: 0, y: lineY, width: xAxisWidth, height: 1))
                    scrollView.addSubview(dashLineView)
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: 0, y: dashLineView.bounds.size.height / 2))
                    path.addLine(to: CGPoint(x: dashLineView.bounds.size.width, y: dashLineView.bounds.size.height / 2))
                    let dashLineLayer = CAShapeLayer()
                    dashLineLayer.bounds = dashLineView.bounds
                    dashLineLayer.position = CGPoint(x: dashLineView.bounds.size.width / 2, y: dashLineView.bounds.size.height / 2)
                    if Int(yAxisNums[yAxisNums.count - i - 1]) == 0 {
                        dashLineLayer.lineWidth = 1
                        dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "898989").cgColor
                    } else {
                        dashLineLayer.lineWidth = 0.5
                        dashLineLayer.lineDashPattern = [2,1]
                        dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "dcdcdc").cgColor
                    }
                    dashLineLayer.path = path.cgPath
                    dashLineView.layer.addSublayer(dashLineLayer)
                }
            }
        }
        
        // dataView
        dataView.removeFromSuperview()
        dataView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        dataView.layer.sublayers?.removeAll()
        dataView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: bgHeight)// scrollView.bounds.size.height - xAxisHeight)
        dataView.backgroundColor = .clear
        scrollView.addSubview(dataView)
        if touchEnable && !singleDataArray.isEmpty {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            dataView.isUserInteractionEnabled = true
            dataView.addGestureRecognizer(tap)
        }
        
        if singleDataArray.isEmpty {
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
        var fromZeroY:CGFloat = 0 // 找0刻度线高度
        if yAxisNums.isEmpty { // 未传入刻度值
            if minValue >= 0 { // 最小值大于0，则无负轴
                fromZeroY = bgHeight
            } else if maxValue <= 0 { // 最大值小于0，则无正轴
                fromZeroY = yAxisTopMagin
            } else {
                fromZeroY = (bgHeight - xAxisHeight) / 2 + yAxisTopMagin
            }
        } else { // 传入刻度值
            fromZeroY = zeroY
        }
        pointArray.append(CGPoint(x: 0, y: fromZeroY))
        
        var groupTitle = ""
        for (i, _) in singleDataNumberArray.enumerated() {
            if groupTitle == dataNameArray[i] { // x轴标题去重（相邻重复的不显示）
                continue
            }
            let groupCenterLineView = UIView(frame: CGRect(x: groupWidth * CGFloat(i) - 0.5, y: 1, width: 1, height: 5))
            groupCenterLineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
            xAxisView.addSubview(groupCenterLineView)
            
            // 分组标题
            let groupTitleLabel = UILabel()
            groupTitleLabel.font = UIFont.systemFont(ofSize: xAxisTitleFont)
            groupTitleLabel.textColor = UIColor.colorWithHexString(color: "898989")
            groupTitleLabel.textAlignment = .center
            groupTitleLabel.text = dataNameArray[i]
            groupTitleLabel.sizeToFit()
            groupTitleLabel.center = CGPoint(x: groupWidth * CGFloat(i), y: xAxisHeight - groupTitleLabel.bounds.size.height / 2)
            if i == 0 {
                groupTitleLabel.frame.origin = CGPoint(x: 0, y: xAxisHeight - groupTitleLabel.bounds.size.height)
            }
            if i == singleDataNumberArray.count - 1 {
                groupTitleLabel.center = CGPoint(x: groupWidth * CGFloat(i) - groupTitleLabel.bounds.size.width / 2, y: xAxisHeight - groupTitleLabel.bounds.size.height / 2)
            }
            xAxisView.addSubview(groupTitleLabel)
            groupTitle = dataNameArray[i]
        }
        
        // 具体数据
        for (i,num) in singleDataNumberArray.enumerated() {
//            let heigh = (dataView.bounds.size.height - yAxisViewTopMargin) * CGFloat(Float(num)!)
            var pointHeight:CGFloat = 0
            var dataPoint = CGPoint(x: 0, y: 0)
            if yAxisNums.isEmpty { // 未传入刻度值
                if minValue >= 0 { // 最小值大于0，则无负轴
                    pointHeight = (bgHeight - xAxisHeight) * CGFloat(num / maxNum)
                    dataPoint = CGPoint(x: groupWidth * CGFloat(i), y: bgHeight - pointHeight)
                } else if maxValue <= 0 { // 最大值小于0，则无正轴
                    pointHeight = (bgHeight - xAxisHeight) * CGFloat(num / minNum)
                    dataPoint = CGPoint(x: groupWidth * CGFloat(i), y: pointHeight + xAxisHeight)
                } else {
                    if num > 0 { // 正
                        pointHeight = (bgHeight - xAxisHeight) / 2 * CGFloat(num / maxNum)
                        dataPoint = CGPoint(x: groupWidth * CGFloat(i), y: (bgHeight - xAxisHeight) / 2 + yAxisTopMagin - pointHeight)
                    } else { // 负
                        pointHeight = (bgHeight - xAxisHeight) / 2 * CGFloat(num / minNum)
                        dataPoint = CGPoint(x: groupWidth * CGFloat(i), y: (bgHeight - xAxisHeight) / 2 + yAxisTopMagin + pointHeight)
                    }
                }
            } else { // 传入刻度值
                if num > 0 { // 正
                    pointHeight = (zeroY - xAxisHeight) * CGFloat(num / maxNum)
                    dataPoint = CGPoint(x: groupWidth * CGFloat(i), y: zeroY - pointHeight)
                } else {
                    pointHeight = (bgHeight - zeroY) * CGFloat(num / minNum)
                    dataPoint = CGPoint(x: groupWidth * CGFloat(i), y: zeroY + pointHeight)
                }
            }
            
            // 是否加粗数据点
            if showBlodPoint {
                let pointLayer = CALayer()
                pointLayer.frame = CGRect(x: dataPoint.x - (lineWidth + 2) / 2, y: dataPoint.y - (lineWidth + 2) / 2, width: lineWidth + 2, height: lineWidth + 2)
                pointLayer.backgroundColor = UIColor.colorWithHexString(color: lineColor.first!).cgColor
                pointLayer.cornerRadius = (lineWidth + 2) / 2
                dataView.layer.addSublayer(pointLayer)
            }
            
            // 是否为平滑曲线
            if isSmooth {
                pointArray.append(dataPoint)
            } else {
                var fromZeroY:CGFloat = 0 // 找0刻度线高度
                if yAxisNums.isEmpty { // 未传入刻度值
                    if minValue >= 0 { // 最小值大于0，则无负轴
                        fromZeroY = bgHeight
                    } else if maxValue <= 0 { // 最大值小于0，则无正轴
                        fromZeroY = yAxisTopMagin
                    } else {
                        fromZeroY = (bgHeight - xAxisHeight) / 2 + yAxisTopMagin
                    }
                } else { // 传入刻度值
                    fromZeroY = zeroY
                }
                if i == 0 {
                    if isFillWithColor {
                        dataPath.move(to: CGPoint(x: 0, y: fromZeroY))
                        dataPath.addLine(to: dataPoint)
                        if isDrawLineWhenFillColor {
                            linePath.move(to: dataPoint)
                        }
                    } else {
                        if isGradientFillColor {
                            dataPath.move(to: CGPoint(x: 0, y: fromZeroY))
                            dataPath.addLine(to: dataPoint)
                            if isDrawLineWhenFillColor {
                                linePath.move(to: dataPoint)
                            }
                        } else {
                            dataPath.move(to: dataPoint)
                        }
                    }
                } else if i == singleDataArray.count - 1 {
                    dataPath.addLine(to: dataPoint)
                    if isFillWithColor {
                        dataPath.addLine(to: CGPoint(x: groupWidth * CGFloat(i), y: fromZeroY))
                        if isDrawLineWhenFillColor {
                            linePath.addLine(to: dataPoint)
                        }
                    }
                    if isGradientFillColor {
                        dataPath.addLine(to: CGPoint(x: groupWidth * CGFloat(i), y: fromZeroY))
                        if isDrawLineWhenFillColor {
                            linePath.addLine(to: dataPoint)
                        }
                    }
                } else {
                    dataPath.addLine(to: dataPoint)
                    if isDrawLineWhenFillColor {
                        linePath.addLine(to: dataPoint)
                    }
                }
            }
        }
        
        // 平滑曲线轨迹
        if isSmooth {
            var fromZeroY:CGFloat = 0 // 找0刻度线高度
            if yAxisNums.isEmpty { // 未传入刻度值
                if minValue >= 0 { // 最小值大于0，则无负轴
                    fromZeroY = bgHeight
                } else if maxValue <= 0 { // 最大值小于0，则无正轴
                    fromZeroY = yAxisTopMagin
                } else {
                    fromZeroY = (bgHeight - xAxisHeight) / 2 + yAxisTopMagin
                }
            } else { // 传入刻度值
                fromZeroY = zeroY
            }
            pointArray.append(CGPoint(x: dataView.bounds.size.width, y: fromZeroY))
            for i in 0..<singleDataArray.count - 1 {
                let p1 = pointArray[i]
                let p2 = pointArray[i+1]
                let p3 = pointArray[i+2]
                let p4 = pointArray[i+3]
                if i == 0 {
                    if isFillWithColor {
                        dataPath.move(to: CGPoint(x: 0, y: fromZeroY))
                        dataPath.addLine(to: p2)
                        if isDrawLineWhenFillColor {
                            linePath.move(to: p2)
                        }
                    } else {
                        if isGradientFillColor {
                            dataPath.move(to: CGPoint(x: 0, y: fromZeroY))
                            dataPath.addLine(to: p2)
                            if isDrawLineWhenFillColor {
                                linePath.move(to: p2)
                            }
                        } else {
                            dataPath.move(to: p2)
                        }
                    }
                }
                getControlPoint(dataPath, point: p1.x, y0: p1.y, x1: p2.x, y1: p2.y, x2: p3.x, y2: p3.y, x3: p4.x, y3: p4.y)
                if isDrawLineWhenFillColor {
                    getControlPoint(linePath, point: p1.x, y0: p1.y, x1: p2.x, y1: p2.y, x2: p3.x, y2: p3.y, x3: p4.x, y3: p4.y)
                }
            }
            if isFillWithColor {
                dataPath.addLine(to: CGPoint(x: groupWidth * CGFloat(singleDataArray.count - 1), y: fromZeroY))
            }
            if isGradientFillColor {
                dataPath.addLine(to: CGPoint(x: groupWidth * CGFloat(singleDataArray.count - 1), y: fromZeroY))
            }
        }
        
        // 渐变填充色
        if isGradientFillColor {
            let gradientBgLayer = CALayer()
            if minValue >= 0 { // 最小值大于0，则无负轴
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = CGRect(x: 0, y: yAxisTopMagin, width: dataView.bounds.size.width, height: dataView.bounds.size.height - yAxisTopMagin)
                gradientLayer.colors = [UIColor.colorWithHexString(color: fillColor, alpha: 0.8).cgColor,
                                        UIColor.colorWithHexString(color: fillColor, alpha: 0.0).cgColor]
                gradientLayer.locations = [0,1]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0)
                gradientLayer.endPoint = CGPoint(x: 0, y: 1)
                gradientBgLayer.addSublayer(gradientLayer)
            } else if maxValue <= 0 { // 最大值小于0，则无正轴
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = CGRect(x: 0, y: yAxisTopMagin, width: dataView.bounds.size.width, height: dataView.bounds.size.height - yAxisTopMagin)
                gradientLayer.colors = [UIColor.colorWithHexString(color: fillColor, alpha: 0.8).cgColor,
                                        UIColor.colorWithHexString(color: fillColor, alpha: 0.0).cgColor]
                gradientLayer.locations = [0,1]
                gradientLayer.startPoint = CGPoint(x: 0, y: 1)
                gradientLayer.endPoint = CGPoint(x: 0, y: 0)
                gradientBgLayer.addSublayer(gradientLayer)
            } else {
                if yAxisNums.isEmpty { // 未传入刻度值
                    let gradient1 = CAGradientLayer()
                    gradient1.frame = CGRect(x: 0, y: yAxisTopMagin, width: dataView.bounds.size.width, height: (dataView.bounds.size.height - yAxisTopMagin) / 2)
                    gradient1.colors = [UIColor.colorWithHexString(color: fillColor, alpha: 0.8).cgColor,
                                            UIColor.colorWithHexString(color: fillColor, alpha: 0.0).cgColor]
                    gradient1.locations = [0,1]
                    gradient1.startPoint = CGPoint(x: 0, y: 0)
                    gradient1.endPoint = CGPoint(x: 0, y: 1)
                    gradientBgLayer.addSublayer(gradient1)
                    
                    let gradient2 = CAGradientLayer()
                    gradient2.frame = CGRect(x: 0, y: yAxisTopMagin + (dataView.bounds.size.height - yAxisTopMagin) / 2, width: dataView.bounds.size.width, height: (dataView.bounds.size.height - yAxisTopMagin) / 2)
                    gradient2.colors = [UIColor.colorWithHexString(color: fillColor, alpha: 0.8).cgColor,
                                            UIColor.colorWithHexString(color: fillColor, alpha: 0.0).cgColor]
                    gradient2.locations = [0,1]
                    gradient2.startPoint = CGPoint(x: 0, y: 1)
                    gradient2.endPoint = CGPoint(x: 0, y: 0)
                    gradientBgLayer.addSublayer(gradient2)
                } else { // 传入刻度值
                    if zeroY <= yAxisTopMagin { // 0刻度在最上边 没有正轴
                        let gradientLayer = CAGradientLayer()
                        gradientLayer.frame = CGRect(x: 0, y: yAxisTopMagin, width: dataView.bounds.size.width, height: dataView.bounds.size.height - yAxisTopMagin)
                        gradientLayer.colors = [UIColor.colorWithHexString(color: fillColor, alpha: 0.8).cgColor,
                                                UIColor.colorWithHexString(color: fillColor, alpha: 0.0).cgColor]
                        gradientLayer.locations = [0,1]
                        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
                        gradientLayer.endPoint = CGPoint(x: 0, y: 0)
                        gradientBgLayer.addSublayer(gradientLayer)
                    } else if zeroY >= dataView.bounds.size.height { // 0刻度在最下边 没有负轴
                        let gradientLayer = CAGradientLayer()
                        gradientLayer.frame = CGRect(x: 0, y: yAxisTopMagin, width: dataView.bounds.size.width, height: dataView.bounds.size.height - yAxisTopMagin)
                        gradientLayer.colors = [UIColor.colorWithHexString(color: fillColor, alpha: 0.8).cgColor,
                                                UIColor.colorWithHexString(color: fillColor, alpha: 0.0).cgColor]
                        gradientLayer.locations = [0,1]
                        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
                        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
                        gradientBgLayer.addSublayer(gradientLayer)
                    } else { // 正负轴都有
                        let gradient1 = CAGradientLayer()
                        gradient1.frame = CGRect(x: 0, y: yAxisTopMagin, width: dataView.bounds.size.width, height: zeroY - yAxisTopMagin)
                        gradient1.colors = [UIColor.colorWithHexString(color: fillColor, alpha: 0.8).cgColor,
                                                UIColor.colorWithHexString(color: fillColor, alpha: 0.0).cgColor]
                        gradient1.locations = [0,1]
                        gradient1.startPoint = CGPoint(x: 0, y: 0)
                        gradient1.endPoint = CGPoint(x: 0, y: 1)
                        gradientBgLayer.addSublayer(gradient1)
                        
                        let gradient2 = CAGradientLayer()
                        gradient2.frame = CGRect(x: 0, y: zeroY, width: dataView.bounds.size.width, height: dataView.bounds.size.height - zeroY)
                        gradient2.colors = [UIColor.colorWithHexString(color: fillColor, alpha: 0.8).cgColor,
                                                UIColor.colorWithHexString(color: fillColor, alpha: 0.0).cgColor]
                        gradient2.locations = [0,1]
                        gradient2.startPoint = CGPoint(x: 0, y: 1)
                        gradient2.endPoint = CGPoint(x: 0, y: 0)
                        gradientBgLayer.addSublayer(gradient2)
                    }
                }
            }
            
            let dataLayer = CAShapeLayer()
            dataLayer.path = dataPath.cgPath
            dataLayer.strokeColor = UIColor.colorWithHexString(color: lineColor.first!).cgColor
            dataLayer.fillColor = UIColor.colorWithHexString(color: fillColor, alpha: fillAlpha).cgColor
//            dataLayer.lineWidth = lineWidth
//            dataView.layer.addSublayer(dataLayer)
            
            gradientBgLayer.mask = dataLayer
            
            dataView.layer.addSublayer(gradientBgLayer)
            
        } else { // 无渐变色时
            let dataLayer = CAShapeLayer()
            dataLayer.path = dataPath.cgPath
            if isFillWithColor {
                dataLayer.strokeColor = nil
                dataLayer.fillColor = UIColor.colorWithHexString(color: fillColor, alpha: fillAlpha).cgColor
            } else {
                dataLayer.strokeColor = UIColor.colorWithHexString(color: lineColor.first!).cgColor
                dataLayer.fillColor = nil
            }
            dataLayer.lineWidth = lineWidth
            dataView.layer.addSublayer(dataLayer)
        }
        
//        let dataLayer = CAShapeLayer()
//        dataLayer.path = dataPath.cgPath
//        if isFillWithColor {
//            dataLayer.strokeColor = nil
//            dataLayer.fillColor = UIColor.colorWithHexString(color: fillColor, alpha: fillAlpha).cgColor
//        } else {
//            dataLayer.strokeColor = UIColor.colorWithHexString(color: lineColor.first!).cgColor
//            dataLayer.fillColor = nil
//        }
//        dataLayer.lineWidth = lineWidth
//        dataView.layer.addSublayer(dataLayer)
        
        if isDrawLineWhenFillColor { // 底部填充颜色时数据画线
            let lineDataLayer = CAShapeLayer()
            lineDataLayer.path = linePath.cgPath
            lineDataLayer.strokeColor = UIColor.colorWithHexString(color: lineColor.first!).cgColor
            lineDataLayer.fillColor = nil
            lineDataLayer.lineWidth = lineWidth
            dataView.layer .addSublayer(lineDataLayer)
        }
        
        // 显示具体数值
        if showDataLabel {
            for (i, num) in singleDataNumberArray.enumerated() {
                var labelCenterY:CGFloat = 0
                if yAxisNums.isEmpty { // 未传入刻度值
                    if minValue >= 0 { // 最小值大于0，则无负轴
                        labelCenterY = bgHeight - (bgHeight - xAxisHeight) * CGFloat(num / maxNum) - 8
                    } else if maxValue <= 0 { // 最大值小于0，则无正轴
                        labelCenterY = (bgHeight - xAxisHeight) * CGFloat(num / minNum) + xAxisHeight + 8
                    } else {
                        if num > 0 { // 正
                            labelCenterY = (bgHeight - xAxisHeight) / 2 + yAxisTopMagin - (bgHeight - xAxisHeight) / 2 * CGFloat(num / maxNum) - 8
                        } else { // 负
                            labelCenterY = (bgHeight - xAxisHeight) / 2 + yAxisTopMagin + (bgHeight - xAxisHeight) / 2 * CGFloat(num / minNum) + 8
                        }
                    }
                } else { // 传入刻度值
                    if num > 0 { // 正
                        labelCenterY = zeroY - (zeroY - xAxisHeight) * CGFloat(num / maxNum) - 8
                    } else {
                        labelCenterY = zeroY + (bgHeight - zeroY) * CGFloat(num / minNum) + 8
                    }
                }
                let dataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: groupWidth, height: 16))
                dataLabel.center = CGPoint(x: groupWidth * CGFloat(i), y: labelCenterY)
                dataLabel.font = UIFont.systemFont(ofSize: dataLabelFont)
                dataLabel.textColor = UIColor.colorWithHexString(color: "404040")
                dataLabel.textAlignment = .center
                dataLabel.text = singleDataArray[i]//String(format: "%.f", num)
                if i == 0 {
                    dataLabel.sizeToFit()
                    dataLabel.center = CGPoint(x: dataLabel.bounds.size.width / 2, y: labelCenterY)
                }
                if i == singleDataNumberArray.count - 1 {
                    dataLabel.sizeToFit()
                    dataLabel.center = CGPoint(x: groupWidth * CGFloat(i) - dataLabel.bounds.size.width / 2, y: labelCenterY)
                }
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
        // y轴设置
        for subview in yAxisView.subviews {
            subview.removeFromSuperview()
        }
        let lineView = UIView(frame: CGRect(x: yAxisWidth - 1, y: 0, width: 1, height: yAxisHeight - xAxisHeight))
        lineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
        yAxisView.addSubview(lineView)
        
        multiDataNumberArray.removeAll()
        var allNumArray = [Float]()
        for arrar in multiDataArray {
            var arr = [Float]()
            for num in arrar {
                arr.append(Float(num) ?? 0.0)
                allNumArray.append(Float(num) ?? 0.0)
            }
            multiDataNumberArray.append(arr)
        }
        
        var maxValue:Float = 0 // 数组最大值
        var minValue:Float = 0 // 数组最小值
        var maxNum:Float = 0 // y刻度最大值
        var minNum:Float = 0 // y刻度最小值
        var str = ""
        var level:Int = 1
        var temp = 0
        var zeroY:CGFloat = 0 // 用于传入刻度值时，记录0的高度
        
        maxValue = allNumArray.max() ?? 0 // 寻找数组中最大值
        minValue = allNumArray.min() ?? 0 // 寻找数组中最小值
        
        if yAxisNums.isEmpty { // 未传入刻度值，则自动计算
            if minValue >= 0 { // 最小值大于0，则无负轴
                maxNum = approximateRoundNumber("\(maxValue)")
                minNum = 0
                str = String(String(format: "%f", maxNum).prefix(1)) // 获取最大刻度字符的第一位
                str = str == "0" ? "1" : str
                level = (Int(maxNum) ) / Int(str)! // 数量级 整十或整百或整千等
            } else if maxValue <= 0 { // 最大值小于0，则无正轴
                maxNum = 0
                minNum = -approximateRoundNumber("\(-minValue)")
                str = String(String(format: "%f", -minNum).prefix(1)) // 获取最大刻度字符的第一位
                str = str == "0" ? "1" : str
                level = (Int(minNum) ) / Int(str)! // 数量级 整十或整百或整千等
            } else { // 最大值大于0，最小值小于0，则正负轴都有
                maxNum = approximateRoundNumber("\(maxValue)")
                minNum = -approximateRoundNumber("\(-minValue)")
                let absMax = [maxNum, -minNum].max() ?? 0
                maxNum = absMax
                minNum = -absMax
                str = String(String(format: "%f", absMax).prefix(1)) // 获取最大刻度字符的第一位
                str = str == "0" ? "1" : str
                level = (Int(absMax) ) / Int(str)! // 数量级 整十或整百或整千等
            }
            
            if minValue >= 0 { // 最小值大于0，则无负轴
                for i in 0..<Int(str)! {
                    let lblY = yAxisHeight - xAxisHeight - 8 - CGFloat(i) * lineView.bounds.size.height / CGFloat(Int(str)!)
                    let lblYAxisNum = UILabel(frame: CGRect(x: 0, y: lblY, width: yAxisWidth - 1, height: 16))
                    lblYAxisNum.font = UIFont.systemFont(ofSize: 8)
                    lblYAxisNum.textColor = UIColor.colorWithHexString(color: "898989")
                    lblYAxisNum.textAlignment = .center
                    lblYAxisNum.text = "\(i * level)"
                    yAxisView.addSubview(lblYAxisNum)
                }
                if !multiDataArray.isEmpty {
                    let lblMax = UILabel(frame: CGRect(x: 0, y: -8, width: yAxisWidth - 1, height: 16))
                    lblMax.font = UIFont.systemFont(ofSize: 8)
                    lblMax.textColor = UIColor.colorWithHexString(color: "898989")
                    lblMax.textAlignment = .center
                    lblMax.text = String(format: "%.f", maxNum)
                    yAxisView.addSubview(lblMax)
                }
            } else if maxValue <= 0 { // 最大值小于0，则无正轴
                for i in 0 ..< Int(str)! {
                    let lblY = -8 + CGFloat(i) * lineView.bounds.size.height / CGFloat(Int(str)!)
                    let lblYAxisNum = UILabel(frame: CGRect(x: 0, y: lblY, width: yAxisWidth - 1, height: 16))
                    lblYAxisNum.font = UIFont.systemFont(ofSize: 8)
                    lblYAxisNum.textColor = UIColor.colorWithHexString(color: "898989")
                    lblYAxisNum.textAlignment = .center
                    lblYAxisNum.text = "\(i * level)"
                    yAxisView.addSubview(lblYAxisNum)
                }
                if !multiDataArray.isEmpty {
                    let lblMin = UILabel(frame: CGRect(x: 0, y: lineView.bounds.size.height - 8, width: yAxisWidth - 1, height: 16))
                    lblMin.font = UIFont.systemFont(ofSize: 8)
                    lblMin.textColor = UIColor.colorWithHexString(color: "898989")
                    lblMin.textAlignment = .center
                    lblMin.text = String(format: "%.f", minNum)
                    yAxisView.addSubview(lblMin)
                    
                }
            } else { // 最大值大于0，最小值小于0，则正负轴都有
                temp = Int(str)!
                for i in 0 ..< Int(str)! * 2 {
                    let lblY = yAxisHeight - xAxisHeight - 8 - CGFloat(i) * lineView.bounds.size.height / CGFloat(Int(str)! * 2)
                    let lblYAxisNum = UILabel(frame: CGRect(x: 0, y: lblY, width: yAxisWidth - 1, height: 16))
                    lblYAxisNum.font = UIFont.systemFont(ofSize: 8)
                    lblYAxisNum.textColor = UIColor.colorWithHexString(color: "898989")
                    lblYAxisNum.textAlignment = .center
                    lblYAxisNum.text = "\((i - temp) * level)"
                    yAxisView.addSubview(lblYAxisNum)
                }
                if !multiDataArray.isEmpty {
                    let lblMax = UILabel(frame: CGRect(x: 0, y: -8, width: yAxisWidth - 1, height: 16))
                    lblMax.font = UIFont.systemFont(ofSize: 8)
                    lblMax.textColor = UIColor.colorWithHexString(color: "898989")
                    lblMax.textAlignment = .center
                    let absMax = [maxNum, -minNum].max() ?? 0
                    lblMax.text = String(format: "%.f", absMax)
                    yAxisView.addSubview(lblMax)
                }
            }
        } else { // 传入刻度值
            var yAxisNumArray = [Float]()
            for num in yAxisNums {
                yAxisNumArray.append(Float(num) ?? 0.0)
            }
            maxNum = yAxisNumArray.max() ?? 0 // 寻找数组中最大值
            minNum = yAxisNumArray.min() ?? 0 // 寻找数组中最小值
            
            for i in 0..<yAxisNums.count {
                let labelHeight:CGFloat = 16
                let labelY = CGFloat(i) * (lineView.bounds.size.height / CGFloat(yAxisNums.count - 1))
                let lblY = yAxisView.bounds.size.height - xAxisHeight - labelHeight / 2 - labelY
                let lblYAxisNum = UILabel(frame: CGRect(x: 0, y: lblY, width: yAxisWidth - 1, height: labelHeight))
                lblYAxisNum.font = UIFont.systemFont(ofSize: yAxisTitleFont)
                lblYAxisNum.textColor = UIColor.colorWithHexString(color: "898989")
                lblYAxisNum.textAlignment = .center
                lblYAxisNum.text = yAxisNums[i]
                yAxisView.addSubview(lblYAxisNum)
                if Int(yAxisNums[yAxisNums.count - i - 1]) == 0 {
                    zeroY = yAxisTopMagin + CGFloat(i) * (lineView.bounds.size.height / CGFloat(yAxisNums.count - 1))
                }
            }
        }
        
        // 确定滚动内容大小和组宽度
        if scrollEnabled {
            if dataNameArray.count <= 5 {
                groupWidth = bgWidth / CGFloat(dataNameArray.count - 1)
                scrollView.contentSize = CGSize(width: bgWidth, height: 0)
                xAxisView.frame = CGRect(x: 0, y: bgHeight, width: bgWidth, height: xAxisHeight)
            } else {
                groupWidth = bgWidth / 4
                scrollView.contentSize = CGSize(width: groupWidth * CGFloat(dataNameArray.count - 1), height: 0)
                xAxisView.frame = CGRect(x: 0, y: bgHeight, width: groupWidth * CGFloat(dataNameArray.count - 1), height: xAxisHeight)
            }
        } else {
            groupWidth = bgWidth / CGFloat(dataNameArray.count - 1)
            scrollView.contentSize = CGSize(width: bgWidth, height: 0)
            xAxisView.frame = CGRect(x: 0, y: bgHeight, width: bgWidth, height: xAxisHeight)
        }
        xAxisWidth = xAxisView.bounds.size.width
        
        // 移除xAxisView子视图
        for subview in xAxisView.subviews {
            subview.removeFromSuperview()
        }
        
        let xLineView = UIView(frame: CGRect(x: 0, y: 0, width: xAxisWidth, height: 1))
        xLineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
        xAxisView.addSubview(xLineView)
        
        // 移除scrollView子视图
        for subview in scrollView.subviews {
            if subview != xAxisView {
                subview.removeFromSuperview()
            }
        }
        
        // 水平虚线
        if showDataHorizontalLine {
            if yAxisNums.isEmpty { // 未传入刻度值
                if minValue >= 0 { // 最小值大于0，则无负轴
                    for i in 0 ..< Int(str)! {
                        let lineY = yAxisTopMagin + CGFloat(i) * (lineView.bounds.size.height / CGFloat(Int(str)!))
                        let dashLineView = UIView(frame: CGRect(x: 0, y: lineY, width: xAxisWidth, height: 1))
                        scrollView.addSubview(dashLineView)
                        let path = UIBezierPath()
                        path.move(to: CGPoint(x: 0, y: dashLineView.bounds.size.height / 2))
                        path.addLine(to: CGPoint(x: dashLineView.bounds.size.width, y: dashLineView.bounds.size.height / 2))
                        let dashLineLayer = CAShapeLayer()
                        dashLineLayer.bounds = dashLineView.bounds
                        dashLineLayer.position = CGPoint(x: dashLineView.bounds.size.width / 2, y: dashLineView.bounds.size.height / 2)
                        dashLineLayer.lineWidth = 0.5
                        dashLineLayer.lineDashPattern = [2,1]
                        dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "dcdcdc").cgColor
                        dashLineLayer.path = path.cgPath
                        dashLineView.layer.addSublayer(dashLineLayer)
                    }
                } else if maxValue <= 0 { // 最大值小于0，则无正轴
                    for i in 0 ..< Int(str)! {
                        let lineY = yAxisTopMagin + CGFloat(i) * (lineView.bounds.size.height / CGFloat(Int(str)!))
                        let dashLineView = UIView(frame: CGRect(x: 0, y: lineY, width: xAxisWidth, height: 1))
                        scrollView.addSubview(dashLineView)
                        let path = UIBezierPath()
                        path.move(to: CGPoint(x: 0, y: dashLineView.bounds.size.height / 2))
                        path.addLine(to: CGPoint(x: dashLineView.bounds.size.width, y: dashLineView.bounds.size.height / 2))
                        let dashLineLayer = CAShapeLayer()
                        dashLineLayer.bounds = dashLineView.bounds
                        dashLineLayer.position = CGPoint(x: dashLineView.bounds.size.width / 2, y: dashLineView.bounds.size.height / 2)
                        if i == 0 {
                            dashLineLayer.lineWidth = 1
                            dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "898989").cgColor
                        } else {
                            dashLineLayer.lineWidth = 0.5
                            dashLineLayer.lineDashPattern = [2,1]
                            dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "dcdcdc").cgColor
                        }
                        dashLineLayer.path = path.cgPath
                        dashLineView.layer.addSublayer(dashLineLayer)
                    }
                } else {
                    for i in 0 ..< Int(str)! * 2 {
                        let lineY = yAxisTopMagin + CGFloat(i) * (lineView.bounds.size.height / CGFloat(Int(str)! * 2))
                        let dashLineView = UIView(frame: CGRect(x: 0, y: lineY, width: xAxisWidth, height: 1))
                        scrollView.addSubview(dashLineView)
                        let path = UIBezierPath()
                        path.move(to: CGPoint(x: 0, y: dashLineView.bounds.size.height / 2))
                        path.addLine(to: CGPoint(x: dashLineView.bounds.size.width, y: dashLineView.bounds.size.height / 2))
                        let dashLineLayer = CAShapeLayer()
                        dashLineLayer.bounds = dashLineView.bounds
                        dashLineLayer.position = CGPoint(x: dashLineView.bounds.size.width / 2, y: dashLineView.bounds.size.height / 2)
                        if i == temp {
                            dashLineLayer.lineWidth = 1
                            dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "898989").cgColor
                        } else {
                            dashLineLayer.lineWidth = 0.5
                            dashLineLayer.lineDashPattern = [2,1]
                            dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "dcdcdc").cgColor
                        }
                        dashLineLayer.path = path.cgPath
                        dashLineView.layer.addSublayer(dashLineLayer)
                    }
                }
            } else { // 传入刻度值
                for i in 0..<yAxisNums.count - 1 {
                    let lineY = yAxisTopMagin + CGFloat(i) * (lineView.bounds.size.height / CGFloat(yAxisNums.count - 1))
                    let dashLineView = UIView(frame: CGRect(x: 0, y: lineY, width: xAxisWidth, height: 1))
                    scrollView.addSubview(dashLineView)
                    let path = UIBezierPath()
                    path.move(to: CGPoint(x: 0, y: dashLineView.bounds.size.height / 2))
                    path.addLine(to: CGPoint(x: dashLineView.bounds.size.width, y: dashLineView.bounds.size.height / 2))
                    let dashLineLayer = CAShapeLayer()
                    dashLineLayer.bounds = dashLineView.bounds
                    dashLineLayer.position = CGPoint(x: dashLineView.bounds.size.width / 2, y: dashLineView.bounds.size.height / 2)
                    if Int(yAxisNums[yAxisNums.count - i - 1]) == 0 {
                        dashLineLayer.lineWidth = 1
                        dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "898989").cgColor
                    } else {
                        dashLineLayer.lineWidth = 0.5
                        dashLineLayer.lineDashPattern = [2,1]
                        dashLineLayer.strokeColor = UIColor.colorWithHexString(color: "dcdcdc").cgColor
                    }
                    dashLineLayer.path = path.cgPath
                    dashLineView.layer.addSublayer(dashLineLayer)
                }
            }
        }
        
        // dataView
        dataView.removeFromSuperview()
        dataView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        dataView.layer.sublayers?.removeAll()
        dataView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: bgHeight)// scrollView.bounds.size.height - xAxisHeight)
        dataView.backgroundColor = .clear
        scrollView.addSubview(dataView)
        
        if touchEnable && !multiDataArray.isEmpty {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
            dataView.isUserInteractionEnabled = true
            dataView.addGestureRecognizer(tap)
        }
        
        if multiDataArray.isEmpty {
            return
        }
        
        // 背景layer(动画)
        let bgPath = UIBezierPath()
        bgPath.move(to: CGPoint(x: 0, y: bgHeight / 2))
        bgPath.addLine(to: CGPoint(x: dataView.bounds.size.width, y: dataView.bounds.size.height / 2))
        bgPath.lineWidth = bgHeight
        let bgLayer = CAShapeLayer()
        bgLayer.fillColor = UIColor.clear.cgColor
        bgLayer.strokeColor = UIColor.lightGray.cgColor
        bgLayer.strokeStart = 0
        bgLayer.strokeEnd = 1
        bgLayer.zPosition = 1
        bgLayer.lineWidth = bgHeight
        bgLayer.path = bgPath.cgPath
        dataView.layer.mask = bgLayer
        
        // x轴组标题
        var groupTitle = ""
        for (i, str) in dataNameArray.enumerated() {
            if groupTitle == str { // x轴标题去重（相邻重复的不显示）
                continue
            }
            let groupCenterLineView = UIView(frame: CGRect(x: groupWidth * CGFloat(i) - 0.5, y: 1, width: 1, height: 5))
            groupCenterLineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
            xAxisView.addSubview(groupCenterLineView)
            
            // 分组标题
            let groupTitleLabel = UILabel()
            groupTitleLabel.font = UIFont.systemFont(ofSize: xAxisTitleFont)
            groupTitleLabel.textColor = UIColor.colorWithHexString(color: "898989")
            groupTitleLabel.textAlignment = .center
            groupTitleLabel.text = str
            groupTitleLabel.sizeToFit()
            groupTitleLabel.center = CGPoint(x: groupWidth * CGFloat(i), y: xAxisHeight - groupTitleLabel.bounds.size.height / 2)
            if i == 0 {
                groupTitleLabel.frame.origin = CGPoint(x: 0, y: xAxisHeight - groupTitleLabel.bounds.size.height)
            }
            if i == dataNameArray.count - 1 {
                groupTitleLabel.center = CGPoint(x: groupWidth * CGFloat(i) - groupTitleLabel.bounds.size.width / 2, y: xAxisHeight - groupTitleLabel.bounds.size.height / 2)
            }
            xAxisView.addSubview(groupTitleLabel)
            
            groupTitle = str
        }
        
        // 具体数据
        for (i, array) in multiDataNumberArray.enumerated() {
            let dataPath = UIBezierPath()
            dataPath.lineWidth = lineWidth
            UIColor.colorWithHexString(color: lineColor.first!).setStroke()
            UIColor.colorWithHexString(color: lineColor.first!).setFill()
            dataPath.stroke()
            dataPath.fill()
            
            var arr = [CGPoint]()
            // 起始点
            var fromZeroY:CGFloat = 0 // 找0刻度线高度
            if yAxisNums.isEmpty { // 未传入刻度值
                if minValue >= 0 { // 最小值大于0，则无负轴
                    fromZeroY = bgHeight
                } else if maxValue <= 0 { // 最大值小于0，则无正轴
                    fromZeroY = yAxisTopMagin
                } else {
                    fromZeroY = (bgHeight - xAxisHeight) / 2 + yAxisTopMagin
                }
            } else { // 传入刻度值
                fromZeroY = zeroY
            }
            arr.append(CGPoint(x: 0, y: fromZeroY))
            
            for (j, num) in array.enumerated() {
                var pointHeight:CGFloat = 0
                var dataPoint = CGPoint(x: 0, y: 0)
                if yAxisNums.isEmpty { // 未传入刻度值
                    if minValue >= 0 { // 最小值大于0，则无负轴
                        pointHeight = (bgHeight - xAxisHeight) * CGFloat(num / maxNum)
                        dataPoint = CGPoint(x: groupWidth * CGFloat(j), y: bgHeight - pointHeight)
                    } else if maxValue <= 0 { // 最大值小于0，则无正轴
                        pointHeight = (bgHeight - xAxisHeight) * CGFloat(num / minNum)
                        dataPoint = CGPoint(x: groupWidth * CGFloat(j), y: pointHeight + xAxisHeight)
                    } else {
                        if num > 0 { // 正
                            pointHeight = (bgHeight - xAxisHeight) / 2 * CGFloat(num / maxNum)
                            dataPoint = CGPoint(x: groupWidth * CGFloat(j), y: (bgHeight - xAxisHeight) / 2 + yAxisTopMagin - pointHeight)
                        } else { // 负
                            pointHeight = (bgHeight - xAxisHeight) / 2 * CGFloat(num / minNum)
                            dataPoint = CGPoint(x: groupWidth * CGFloat(j), y: (bgHeight - xAxisHeight) / 2 + yAxisTopMagin + pointHeight)
                        }
                    }
                } else { // 传入刻度值
                    if num > 0 { // 正
                        pointHeight = (zeroY - xAxisHeight) * CGFloat(num / maxNum)
                        dataPoint = CGPoint(x: groupWidth * CGFloat(j), y: zeroY - pointHeight)
                    } else {
                        pointHeight = (bgHeight - zeroY) * CGFloat(num / minNum)
                        dataPoint = CGPoint(x: groupWidth * CGFloat(j), y: zeroY + pointHeight)
                    }
                }
                
                // 是否加粗数据点
                if showBlodPoint {
                    let pointLayer = CALayer()
                    pointLayer.frame = CGRect(x: dataPoint.x - (lineWidth + 2) / 2, y: dataPoint.y - (lineWidth + 2) / 2, width: lineWidth + 2, height: lineWidth + 2)
                    pointLayer.backgroundColor = UIColor.colorWithHexString(color: lineColor[i]).cgColor
                    pointLayer.cornerRadius = (lineWidth + 2) / 2
                    dataView.layer.addSublayer(pointLayer)
                }
                
                // 是否为平滑曲线
                if isSmooth {
                    arr.append(dataPoint)
                } else {
                    if j == 0 {
                        dataPath.move(to: dataPoint)
                    } else {
                        dataPath.addLine(to: dataPoint)
                    }
                }
            }
            
            // 平滑曲线轨迹
            if isSmooth {
                var fromZeroY:CGFloat = 0 // 找0刻度线高度
                if yAxisNums.isEmpty { // 未传入刻度值
                    if minValue >= 0 { // 最小值大于0，则无负轴
                        fromZeroY = bgHeight
                    } else if maxValue <= 0 { // 最大值小于0，则无正轴
                        fromZeroY = yAxisTopMagin
                    } else {
                        fromZeroY = (bgHeight - xAxisHeight) / 2 + yAxisTopMagin
                    }
                } else { // 传入刻度值
                    fromZeroY = zeroY
                }
                arr.append(CGPoint(x: dataView.bounds.size.width, y: fromZeroY))
                for k in 0..<array.count - 1 {
                    let p1 = arr[k]
                    let p2 = arr[k+1]
                    let p3 = arr[k+2]
                    let p4 = arr[k+3]
                    if k == 0 {
                        dataPath.move(to: p2)
                    }
                    getControlPoint(dataPath, point: p1.x, y0: p1.y, x1: p2.x, y1: p2.y, x2: p3.x, y2: p3.y, x3: p4.x, y3: p4.y)
                }
            }
            
            let dataLayer = CAShapeLayer()
            dataLayer.path = dataPath.cgPath
            dataLayer.strokeColor = UIColor.colorWithHexString(color: lineColor[i]).cgColor
            dataLayer.fillColor = nil
            dataLayer.lineWidth = lineWidth
            dataView.layer.addSublayer(dataLayer)
            
            // 显示具体数值
            if showDataLabel {
                for (l, num) in array.enumerated() {
                    var labelCenterY:CGFloat = 0
                    if yAxisNums.isEmpty { // 未传入刻度值
                        if minValue >= 0 { // 最小值大于0，则无负轴
                            labelCenterY = bgHeight - (bgHeight - xAxisHeight) * CGFloat(num / maxNum) - 8
                        } else if maxValue <= 0 { // 最大值小于0，则无正轴
                            labelCenterY = (bgHeight - xAxisHeight) * CGFloat(num / minNum) + xAxisHeight + 8
                        } else {
                            if num > 0 { // 正
                                labelCenterY = (bgHeight - xAxisHeight) / 2 + yAxisTopMagin - (bgHeight - xAxisHeight) / 2 * CGFloat(num / maxNum) - 8
                            } else { // 负
                                labelCenterY = (bgHeight - xAxisHeight) / 2 + yAxisTopMagin + (bgHeight - xAxisHeight) / 2 * CGFloat(num / minNum) + 8
                            }
                        }
                    } else { // 传入刻度值
                        if num > 0 { // 正
                            labelCenterY = zeroY - (zeroY - xAxisHeight) * CGFloat(num / maxNum) - 8
                        } else {
                            labelCenterY = zeroY + (bgHeight - zeroY) * CGFloat(num / minNum) + 8
                        }
                    }
                    let dataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: groupWidth, height: 16))
                    dataLabel.center = CGPoint(x: groupWidth * CGFloat(l), y: labelCenterY)
                    dataLabel.font = UIFont.systemFont(ofSize: dataLabelFont)
                    dataLabel.textColor = UIColor.colorWithHexString(color: lineColor[i])//"404040")
                    dataLabel.textAlignment = .center
                    dataLabel.text = multiDataArray[i][l]//String(format: "%.f", num)
                    if l == 0 {
                        dataLabel.sizeToFit()
                        dataLabel.center = CGPoint(x: dataLabel.bounds.size.width / 2, y: labelCenterY)
                    }
                    if l == multiDataArray[i].count - 1 {
                        dataLabel.sizeToFit()
                        dataLabel.center = CGPoint(x: groupWidth * CGFloat(i) - dataLabel.bounds.size.width / 2, y: labelCenterY)
                    }
                    dataView.addSubview(dataLabel)
                }
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
    
    // MARK: - tapAction
    @objc func tapAction(_ tap:UITapGestureRecognizer) {
        let point = tap.location(in: dataView)
        let index = Int((point.x + groupWidth / 2) / groupWidth)
        debugPrint(index)
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
extension GCLineChartFlushView: UIScrollViewDelegate {
    
}
