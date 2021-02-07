//
//  GCColumnChartView.swift
//  DemosInSwift
//
//  Created by 古创 on 2021/1/11.
//  Copyright © 2021 c. All rights reserved.
//

import UIKit

class GCColumnChartView: UIView {

    // MARK: - member property
    /// 是否为单柱
    var isSingleColumn:Bool = true
    
    /// 数据标签数组
    var dataNameArray = [String]()
    
    /// 单柱数据数组
    var singleDataArray = [String]()
    
    /// 多柱数据数组（二维数组）
    var multiDataArray = [[String]]()
    
    /// y轴刻度值，递增，设置此数组则不自动计算y轴刻度值，传入刻度时必须包含0
    var yAxisNums = [String]()
    
    /// 柱体是否为渐变色
    var isColumnGradientColor:Bool = false
    
    /// 单柱颜色
    var singleColor:String = ""
    
    /// 多柱颜色数组
    var multiColorArray = [String]()
    
    /// 单柱渐变色数组
    var singleGradientColorArray = [String]()
    
    /// 多柱渐变色数组（二维数组）
    var multiGradientColorArray = [[String]]()
    
    /// x轴标题
    var xAxisTitle:String = ""
    
    /// y轴标题
    var yAxisTitle:String = ""
    
    /// 柱体宽度 （多柱若每组数量过多请务必要设置此属性，否则会默认为20）
    var columnWidth:CGFloat = 20
    
    /// 是否线束数据水平线
    var showDataHorizontalLine:Bool = true
    
    /// 每组柱体数量
    var numberOfColumn:CGFloat = 1
    
    /// 柱顶是否显示具体数据
    var showDataLabel:Bool = false
    
    /// 是否可以滚动
    var scrollEnabled:Bool = true
    
    
    // MARK: private property
    private var bgWidth:CGFloat = 0
    private var bgHeight:CGFloat = 0
    private var yAxisWidth:CGFloat = 0
    private var yAxisHeight:CGFloat = 0
    private var yAxisTopMagin:CGFloat = 20 // y轴view顶部间距
    private var xAxisHeight:CGFloat = 20
    private var xAxisWidth:CGFloat = 0
    private var yAxisTitleFont:CGFloat = 8 // y轴刻度字体大小
    private var singleDataNumberArray = [Float]() // 单柱数据数组
    private var multiDataNumberArray = [[Float]]() // 多柱数据数组
    private var groupWidth:CGFloat = 0 // 每组数据背景宽度
    
    // MARK: - init
    /// 初始化一个简易单柱柱状图
    /// - Parameters:
    ///   - frame: frame
    ///   - nameArray: 数据名称数组
    ///   - dataArray: 数据数组
    init(frame: CGRect, nameArray:[String], dataArray:[String]) {
        super.init(frame: frame)
        
        dataNameArray = nameArray
        singleDataArray = dataArray
        
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
    let scrollView:UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = .white
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    
    // y轴
    let yAxisView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // x轴
    let xAxisView:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - reset
    func resetData() {
        if isSingleColumn {
            resetSingleColumn()
        } else {
            resetMultiColumns()
        }
    }
}
// MARK: - config
extension GCColumnChartView {
    func config() {
        
        if singleColor.isEmpty {
            singleColor = "308ff7" // 默认颜色
        }
        
        if multiColorArray.isEmpty {
            multiColorArray = ["#308ff7","#fbca58","#f5447d","#a020f0","#00ffff","#00ff00"]
        }
        
        if singleGradientColorArray.isEmpty {
            singleGradientColorArray = ["#2c8efa","#42cbfe"]
        }
        
        if multiGradientColorArray.isEmpty {
            multiGradientColorArray = [["#2c8efa","#42cbfe"],["#f6457d","#f88d5c"],["#ffd700","#ffff00"],["#00cd00","#00ff00"]]
        }
        
        setUI()
    }
    
    func setUI() {
        addSubview(yAxisView)
        yAxisView.snp.makeConstraints { (make) in
            make.top.equalTo(yAxisTopMagin) // yAxisTopMagin
            make.left.bottom.equalTo(0)
            make.width.equalTo(30)
        }
        
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

// MARK: - reload
extension GCColumnChartView {
    // 单柱
    func resetSingleColumn() {
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
                groupWidth = bgWidth / CGFloat(singleDataArray.count)
                scrollView.contentSize = CGSize(width: bgWidth, height: 0)
                xAxisView.frame = CGRect(x: 0, y: bgHeight, width: bgWidth, height: xAxisHeight)
            } else {
                groupWidth = bgWidth / 5
                scrollView.contentSize = CGSize(width: groupWidth * CGFloat(singleDataArray.count), height: 0)
                xAxisView.frame = CGRect(x: 0, y: bgHeight, width: groupWidth * CGFloat(singleDataArray.count), height: xAxisHeight)
            }
        } else {
            groupWidth = bgWidth / CGFloat(singleDataArray.count)
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
        
        // 具体数据
        for (i,num) in singleDataNumberArray.enumerated() {
            // 每组标题的短线
            let groupCenterLineView = UIView(frame: CGRect(x: groupWidth * CGFloat(i) + groupWidth / 2 - 0.5, y: 1, width: 1, height: 5))
            groupCenterLineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
            xAxisView.addSubview(groupCenterLineView)
            // 每组标题
            let lblGroupTitle = UILabel(frame: CGRect(x: 0, y: 0, width: groupWidth, height: 14))
            lblGroupTitle.center = CGPoint(x: groupWidth * CGFloat(i) + groupWidth / 2, y: 13)
            lblGroupTitle.font = UIFont.systemFont(ofSize: 8)
            lblGroupTitle.textColor = UIColor.colorWithHexString(color: "898989")
            lblGroupTitle.textAlignment = .center
            lblGroupTitle.text = dataNameArray[i]
            xAxisView.addSubview(lblGroupTitle)
            
            // 数据背景
            let dataView = UIView(frame: CGRect(x: 0, y: 0, width: groupWidth, height: bgHeight))
            dataView.center = CGPoint(x: groupWidth * CGFloat(i) + groupWidth / 2, y: dataView.center.y)
            scrollView.addSubview(dataView)
//            dataView.backgroundColor = .cyan
            
            // 背景遮罩
            let bgPath = UIBezierPath()
            if yAxisNums.isEmpty { // 未传入刻度值
                if minValue >= 0 { // 最小值大于0，则无负轴
                    bgPath.move(to: CGPoint(x: groupWidth / 2, y: bgHeight))
                    bgPath.addLine(to: CGPoint(x: groupWidth / 2, y: 0))
                } else if maxValue <= 0 { // 最大值小于0，则无正轴
                    bgPath.move(to: CGPoint(x: groupWidth / 2, y: 0))
                    bgPath.addLine(to: CGPoint(x: groupWidth / 2, y: bgHeight))
                } else {
                    bgPath.move(to: CGPoint(x: groupWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight))
                    if num > 0 { // 数据为正
                        bgPath.addLine(to: CGPoint(x: groupWidth / 2, y: 0))
                    } else {
                        bgPath.addLine(to: CGPoint(x: groupWidth / 2, y: bgHeight))
                    }
                }
            } else { // 传入刻度值
                var bgY:CGFloat = 0 // 数据正负顶点y
                if num > 0 { // 数据为正
                    bgY = 0
                } else {
                    bgY = bgHeight
                }
                bgPath.move(to: CGPoint(x: groupWidth / 2, y: zeroY))
                bgPath.addLine(to: CGPoint(x: groupWidth / 2, y: bgY))
            }
            let bgLayer = CAShapeLayer()
            bgLayer.fillColor = UIColor.clear.cgColor
            bgLayer.strokeColor = UIColor.lightGray.cgColor
            bgLayer.strokeStart = 0
            bgLayer.strokeEnd = 1
            bgLayer.zPosition = 1
            bgLayer.lineWidth = groupWidth
            bgLayer.path = bgPath.cgPath
            dataView.layer.mask = bgLayer
//            dataView.layer.addSublayer(bgLayer)
            
            // 数据柱子
            var columnHeight:CGFloat = 0
            let columnPath = UIBezierPath()
            if yAxisNums.isEmpty { // 未传入刻度值
                if minValue >= 0 { // 最小值大于0，则无负轴
                    columnPath.move(to: CGPoint(x: groupWidth / 2, y: bgHeight))
                    columnHeight = (bgHeight - xAxisHeight) * CGFloat(num / maxNum)
                    columnPath.addLine(to: CGPoint(x: groupWidth / 2, y: dataView.bounds.size.height - columnHeight))
                } else if maxValue <= 0 { // 最大值小于0，则无正轴
                    columnPath.move(to: CGPoint(x: groupWidth / 2, y: xAxisHeight + 1))
                    columnHeight = (bgHeight - xAxisHeight) * CGFloat(num / minNum)
                    columnPath.addLine(to: CGPoint(x: groupWidth / 2, y: columnHeight + xAxisHeight))
                } else {
                    columnPath.move(to: CGPoint(x: groupWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight + (num > 0 ? 0 : 1)))
                    if num > 0 { // 正
                        columnHeight = (bgHeight - xAxisHeight) / 2 * CGFloat(num / maxNum)
                        columnPath.addLine(to: CGPoint(x: groupWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight - columnHeight))
                    } else { // 负
                        columnHeight = (bgHeight - xAxisHeight) / 2 * CGFloat(num / minNum)
                        columnPath.addLine(to: CGPoint(x: groupWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight + columnHeight))
                    }
                }
            } else { // 传入刻度值
                columnPath.move(to: CGPoint(x: groupWidth / 2, y: zeroY + (num > 0 ? 0 : 1)))
                if num > 0 { // 数据为正
                    columnHeight = (zeroY - xAxisHeight) * CGFloat(num / maxNum)
                    columnPath.addLine(to: CGPoint(x: groupWidth / 2, y: zeroY - columnHeight))
                } else {
                    columnHeight = (bgHeight - zeroY) * CGFloat(num / minNum)
                    columnPath.addLine(to: CGPoint(x: groupWidth / 2, y: zeroY + columnHeight))
                }
            }
            columnPath.lineWidth = columnWidth
            UIColor.colorWithHexString(color: singleColor).setStroke()
            UIColor.colorWithHexString(color: singleColor).setFill()
            columnPath.stroke()
            columnPath.fill()
            
            // 渐变色
            if isColumnGradientColor {
                let columnGradientLayer = CAGradientLayer()
                if yAxisNums.isEmpty { // 未传入刻度值
                    if minValue >= 0 { // 最小值大于0，则无负轴
                        columnGradientLayer.frame = CGRect(x: groupWidth / 2 - columnWidth / 2, y: bgHeight - columnHeight, width: columnWidth, height: columnHeight)
                    } else if maxValue <= 0 { // 最大值小于0，则无正轴
                        columnGradientLayer.frame = CGRect(x: groupWidth / 2 - columnWidth / 2, y: xAxisHeight + 1, width: columnWidth, height: columnHeight - 1)
                    } else {
                        if num > 0 { // 正
                            columnGradientLayer.frame = CGRect(x: groupWidth / 2 - columnWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight - columnHeight, width: columnWidth, height: columnHeight)
                        } else { // 负
                            columnGradientLayer.frame = CGRect(x: groupWidth / 2 - columnWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight + 1, width: columnWidth, height: columnHeight - 1)
                        }
                    }
                } else { // 传入刻度值
                    if num > 0 { // 数据为正
                        columnGradientLayer.frame = CGRect(x: groupWidth / 2 - columnWidth / 2, y: zeroY - columnHeight, width: columnWidth, height: columnHeight)
                    } else {
                        columnGradientLayer.frame = CGRect(x: groupWidth / 2 - columnWidth / 2, y: zeroY + 1, width: columnWidth, height: columnHeight - 1)
                    }
                }
                columnGradientLayer.colors = [UIColor.colorWithHexString(color: singleGradientColorArray[0]).cgColor,
                                              UIColor.colorWithHexString(color: singleGradientColorArray[1]).cgColor]
                columnGradientLayer.locations = [0,1]
                columnGradientLayer.startPoint = CGPoint(x: 0, y: 0)
                columnGradientLayer.endPoint = CGPoint(x: 0, y: 1)
                if num < 0 {
                    columnGradientLayer.startPoint = CGPoint(x: 0, y: 1)
                    columnGradientLayer.endPoint = CGPoint(x: 0, y: 0)
                }
                dataView.layer.addSublayer(columnGradientLayer)
            } else {
                let columnLayer = CAShapeLayer()
                columnLayer.path = columnPath.cgPath
                columnLayer.strokeColor = UIColor.colorWithHexString(color: singleColor).cgColor
                columnLayer.fillColor = UIColor.colorWithHexString(color: singleColor).cgColor
                columnLayer.lineWidth = columnWidth
                dataView.layer.addSublayer(columnLayer)
            }
            
            // 显示具体数据
            if showDataLabel {
                let dataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: groupWidth, height: 16))
                if yAxisNums.isEmpty { // 未传入刻度值
                    if minValue >= 0 { // 最小值大于0，则无负轴
                        dataLabel.center = CGPoint(x: groupWidth / 2, y: bgHeight - columnHeight - 8)
                    } else if maxValue <= 0 { // 最大值小于0，则无正轴
                        dataLabel.center = CGPoint(x: groupWidth / 2, y: xAxisHeight + columnHeight + 8)
                    } else {
                        if num > 0 { // 数据为正
                            dataLabel.center = CGPoint(x: groupWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight - columnHeight - 8)
                        } else {
                            dataLabel.center = CGPoint(x: groupWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight + columnHeight + 8)
                        }
                    }
                } else { // 传入刻度值
                    if num > 0 { // 数据为正
                        dataLabel.center = CGPoint(x: groupWidth / 2, y: zeroY - columnHeight - 8)
                    } else {
                        dataLabel.center = CGPoint(x: groupWidth / 2, y: zeroY + columnHeight + 8)
                    }
                }
                dataLabel.font = UIFont.systemFont(ofSize: 8)
                dataLabel.textColor = UIColor.colorWithHexString(color: "404040")
                dataLabel.textAlignment = .center
                dataLabel.text = singleDataArray[i]
                dataView.addSubview(dataLabel)
            }
            
            
            // 动画
            let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeAnimation.fromValue = 0 // 起始值
            strokeAnimation.toValue = 1 // 结束值
            strokeAnimation.duration = 1 // 动画持续时间
            strokeAnimation.repeatCount = 1 // 重复次数
            strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            strokeAnimation.isRemovedOnCompletion = true
            bgLayer.add(strokeAnimation, forKey: "columnAnimation")
        }
        
    }
    
    // 多柱子
    func resetMultiColumns() {
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
            if multiDataArray.count <= 5 {
                groupWidth = bgWidth / CGFloat(multiDataArray.count)
                scrollView.contentSize = CGSize(width: bgWidth, height: 0)
                xAxisView.frame = CGRect(x: 0, y: bgHeight, width: bgWidth, height: xAxisHeight)
            } else {
                groupWidth = bgWidth / 5
                scrollView.contentSize = CGSize(width: groupWidth * CGFloat(multiDataArray.count), height: 0)
                xAxisView.frame = CGRect(x: 0, y: bgHeight, width: groupWidth * CGFloat(multiDataArray.count), height: xAxisHeight)
            }
        } else {
            groupWidth = bgWidth / CGFloat(multiDataArray.count)
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
        
        // 具体数据
        for (i,array) in multiDataNumberArray.enumerated() {
            // 每组标题的短线
            let groupCenterLineView = UIView(frame: CGRect(x: groupWidth * CGFloat(i) + groupWidth / 2 - 0.5, y: 1, width: 1, height: 5))
            groupCenterLineView.backgroundColor = UIColor.colorWithHexString(color: "898989")
            xAxisView.addSubview(groupCenterLineView)
            // 每组标题
            let lblGroupTitle = UILabel(frame: CGRect(x: 0, y: 0, width: groupWidth, height: 14))
            lblGroupTitle.center = CGPoint(x: groupWidth * CGFloat(i) + groupWidth / 2, y: 13)
            lblGroupTitle.font = UIFont.systemFont(ofSize: 8)
            lblGroupTitle.textColor = UIColor.colorWithHexString(color: "898989")
            lblGroupTitle.textAlignment = .center
            lblGroupTitle.text = dataNameArray[i]
            xAxisView.addSubview(lblGroupTitle)
            
            // 组数据背景
            let groupView = UIView(frame: CGRect(x: 0, y: 0, width: groupWidth, height: bgHeight))
            groupView.center = CGPoint(x: groupWidth * CGFloat(i) + groupWidth / 2, y: groupView.center.y)
            scrollView.addSubview(groupView)
//            groupView.backgroundColor = .cyan
//            groupView.layer.borderWidth = 1
//            groupView.layer.borderColor = UIColor.black.cgColor
            
            for (j,num) in array.enumerated() {
                // 每条数据背景
                let dataView = UIView(frame: CGRect(x: 0, y: 0, width: columnWidth, height: bgHeight))
                let margin:CGFloat = 5 // 每个具体数据柱体之间的间距
                let columnLeft:CGFloat = groupWidth / 2 - (columnWidth / 2 + margin / 2) * CGFloat(array.count - 1) + (columnWidth + margin) * CGFloat(j)
                dataView.center = CGPoint(x: columnLeft, y: dataView.center.y)
                groupView.addSubview(dataView)
//                dataView.backgroundColor = .cyan
                
                // 背景遮罩
                let bgPath = UIBezierPath()
                if yAxisNums.isEmpty { // 未传入刻度值
                    if minValue >= 0 { // 最小值大于0，则无负轴
                        bgPath.move(to: CGPoint(x: columnWidth / 2, y: bgHeight))
                        bgPath.addLine(to: CGPoint(x: columnWidth / 2, y: 0))
                    } else if maxValue <= 0 { // 最大值小于0，则无正轴
                        bgPath.move(to: CGPoint(x: columnWidth / 2, y: 0))
                        bgPath.addLine(to: CGPoint(x: columnWidth / 2, y: bgHeight))
                    } else {
                        bgPath.move(to: CGPoint(x: columnWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight))
                        if num > 0 { // 数据为正
                            bgPath.addLine(to: CGPoint(x: columnWidth / 2, y: 0))
                        } else {
                            bgPath.addLine(to: CGPoint(x: columnWidth / 2, y: bgHeight))
                        }
                    }
                } else { // 传入刻度值
                    var bgY:CGFloat = 0 // 数据正负顶点y
                    if num > 0 { // 数据为正
                        bgY = 0
                    } else {
                        bgY = bgHeight
                    }
                    bgPath.move(to: CGPoint(x: columnWidth / 2, y: zeroY))
                    bgPath.addLine(to: CGPoint(x: columnWidth / 2, y: bgY))
                }
                let bgLayer = CAShapeLayer()
                bgLayer.fillColor = UIColor.clear.cgColor
                bgLayer.strokeColor = UIColor.lightGray.cgColor
                bgLayer.strokeStart = 0
                bgLayer.strokeEnd = 1
                bgLayer.zPosition = 1
                bgLayer.lineWidth = columnWidth
                bgLayer.path = bgPath.cgPath
                dataView.layer.mask = bgLayer
//                dataView.layer.addSublayer(bgLayer)
                
                // 数据柱子
                var columnHeight:CGFloat = 0
                let columnPath = UIBezierPath()
                if yAxisNums.isEmpty { // 未传入刻度值
                    if minValue >= 0 { // 最小值大于0，则无负轴
                        columnPath.move(to: CGPoint(x: columnWidth / 2, y: bgHeight))
                        columnHeight = (bgHeight - xAxisHeight) * CGFloat(num / maxNum)
                        columnPath.addLine(to: CGPoint(x: columnWidth / 2, y: dataView.bounds.size.height - columnHeight))
                    } else if maxValue <= 0 { // 最大值小于0，则无正轴
                        columnPath.move(to: CGPoint(x: columnWidth / 2, y: xAxisHeight + 1))
                        columnHeight = (bgHeight - xAxisHeight) * CGFloat(num / minNum)
                        columnPath.addLine(to: CGPoint(x: columnWidth / 2, y: columnHeight + xAxisHeight))
                    } else {
                        columnPath.move(to: CGPoint(x: columnWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight + (num > 0 ? 0 : 1)))
                        if num > 0 { // 正
                            columnHeight = (bgHeight - xAxisHeight) / 2 * CGFloat(num / maxNum)
                            columnPath.addLine(to: CGPoint(x: columnWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight - columnHeight))
                        } else { // 负
                            columnHeight = (bgHeight - xAxisHeight) / 2 * CGFloat(num / minNum)
                            columnPath.addLine(to: CGPoint(x: columnWidth / 2, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight + columnHeight))
                        }
                    }
                } else { // 传入刻度值
                    columnPath.move(to: CGPoint(x: columnWidth / 2, y: zeroY + (num > 0 ? 0 : 1)))
                    if num > 0 { // 数据为正
                        columnHeight = (zeroY - xAxisHeight) * CGFloat(num / maxNum)
                        columnPath.addLine(to: CGPoint(x: columnWidth / 2, y: zeroY - columnHeight))
                    } else {
                        columnHeight = (bgHeight - zeroY) * CGFloat(num / minNum)
                        columnPath.addLine(to: CGPoint(x: columnWidth / 2, y: zeroY + columnHeight))
                    }
                }
                columnPath.lineWidth = columnWidth
                UIColor.colorWithHexString(color: multiColorArray[j]).setStroke()
                UIColor.colorWithHexString(color: multiColorArray[j]).setFill()
                columnPath.stroke()
                columnPath.fill()
                
                // 渐变色
                if isColumnGradientColor {
                    let columnGradientLayer = CAGradientLayer()
                    if yAxisNums.isEmpty { // 未传入刻度值
                        if minValue >= 0 { // 最小值大于0，则无负轴
                            columnGradientLayer.frame = CGRect(x: 0, y: bgHeight - columnHeight, width: columnWidth, height: columnHeight)
                        } else if maxValue <= 0 { // 最大值小于0，则无正轴
                            columnGradientLayer.frame = CGRect(x: 0, y: xAxisHeight + 1, width: columnWidth, height: columnHeight - 1)
                        } else {
                            if num > 0 { // 正
                                columnGradientLayer.frame = CGRect(x: 0, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight - columnHeight, width: columnWidth, height: columnHeight)
                            } else { // 负
                                columnGradientLayer.frame = CGRect(x: 0, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight + 1, width: columnWidth, height: columnHeight - 1)
                            }
                        }
                    } else { // 传入刻度值
                        if num > 0 { // 数据为正
                            columnGradientLayer.frame = CGRect(x: 0, y: zeroY - columnHeight, width: columnWidth, height: columnHeight)
                        } else {
                            columnGradientLayer.frame = CGRect(x: 0, y: zeroY + 1, width: columnWidth, height: columnHeight - 1)
                        }
                    }
                    let gradientColorArr = multiGradientColorArray[j]
                    columnGradientLayer.colors = [UIColor.colorWithHexString(color: gradientColorArr[0]).cgColor,
                                                  UIColor.colorWithHexString(color: gradientColorArr[1]).cgColor]
                    columnGradientLayer.locations = [0,1]
                    columnGradientLayer.startPoint = CGPoint(x: 0, y: 0)
                    columnGradientLayer.endPoint = CGPoint(x: 0, y: 1)
                    if num < 0 {
                        columnGradientLayer.startPoint = CGPoint(x: 0, y: 1)
                        columnGradientLayer.endPoint = CGPoint(x: 0, y: 0)
                    }
                    dataView.layer.addSublayer(columnGradientLayer)
                } else {
                    let columnLayer = CAShapeLayer()
                    columnLayer.path = columnPath.cgPath
                    columnLayer.strokeColor = UIColor.colorWithHexString(color: multiColorArray[j]).cgColor
                    columnLayer.fillColor = UIColor.colorWithHexString(color: multiColorArray[j]).cgColor
                    columnLayer.lineWidth = columnWidth
                    dataView.layer.addSublayer(columnLayer)
                }
                
                // 显示具体数据
                if showDataLabel {
                    let dataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: columnWidth, height: 16))
                    dataLabel.font = UIFont.systemFont(ofSize: 8)
                    dataLabel.textColor = UIColor.colorWithHexString(color: "404040")
                    dataLabel.textAlignment = .center
                    dataLabel.text = String(format: "%.f", num)
                    dataLabel.sizeToFit()
                    groupView.addSubview(dataLabel)
                    if yAxisNums.isEmpty { // 未传入刻度值
                        if minValue >= 0 { // 最小值大于0，则无负轴
                            dataLabel.center = CGPoint(x: columnLeft, y: bgHeight - columnHeight - 8)
                        } else if maxValue <= 0 { // 最大值小于0，则无正轴
                            dataLabel.center = CGPoint(x: columnLeft, y: xAxisHeight + columnHeight + 8)
                        } else {
                            if num > 0 { // 数据为正
                                dataLabel.center = CGPoint(x: columnLeft, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight - columnHeight - 8)
                            } else {
                                dataLabel.center = CGPoint(x: columnLeft, y: (bgHeight - xAxisHeight) / 2 + xAxisHeight + columnHeight + 8)
                            }
                        }
                    } else { // 传入刻度值
                        if num > 0 { // 数据为正
                            dataLabel.center = CGPoint(x: columnLeft, y: zeroY - columnHeight - 8)
                        } else {
                            dataLabel.center = CGPoint(x: columnLeft, y: zeroY + columnHeight + 8)
                        }
                    }
                }
                
                // 动画
                let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
                strokeAnimation.fromValue = 0 // 起始值
                strokeAnimation.toValue = 1 // 结束值
                strokeAnimation.duration = 1 // 动画持续时间
                strokeAnimation.repeatCount = 1 // 重复次数
                strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                strokeAnimation.isRemovedOnCompletion = true
                bgLayer.add(strokeAnimation, forKey: "columnAnimation")
            }
        }
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
}

