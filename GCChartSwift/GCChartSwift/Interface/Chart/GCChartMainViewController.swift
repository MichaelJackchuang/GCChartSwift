//
//  GCChartMainViewController.swift
//  DemosInSwift
//
//  Created by gc on 2020/3/19.
//  Copyright © 2020 c. All rights reserved.
//

import UIKit

class GCChartMainViewController: BaseViewController {

    lazy var tableView:UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "图表"
        
        setUI()
    }
    
    // MARK: - setUI
    func setUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
        }
    }
    

    

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension GCChartMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.selectionStyle = .none
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "扇形图（饼图）"
        case 1:
            cell?.textLabel?.text = "圆环图"
        case 2:
            cell?.textLabel?.text = "柱状图"
        case 3:
            cell?.textLabel?.text = "柱状图(横屏)"
        case 4:
            cell?.textLabel?.text = "折线图&曲线图"
        case 5:
            cell?.textLabel?.text = "雷达图"
        default:
            break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = PieChartViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = CircleRingChartViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = ColumnChartViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = ColumnChartFullScreenViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = LineViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 5:
            let vc = RadarChartViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
