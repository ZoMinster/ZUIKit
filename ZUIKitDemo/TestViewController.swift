    //
    //  ViewController.swift
    //  ZUIKitDemo
    //
    //  Created by yuedong on 6/3/24.
    //

import UIKit
import ZUIKit


class TestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var tableView : UITableView?
    var datas: [CellModel]?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.backgroundView = UIView()
        cell.selectionStyle = .default
        cell.textLabel?.text = self.datas![indexPath.row].key
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = CellModel()
        item.key = "\(indexPath.row+1)"
        self.datas?.insert(item, at: indexPath.row+1)
        self.datas?.insert(item, at: indexPath.row+2)
        self.tableView?.performBatchUpdates({
            self.tableView?.insertRows(at: [IndexPath(row: indexPath.row+1, section: 0), IndexPath(row: indexPath.row+2, section: 0)], with: .top)
        })
        self.tableView?.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view.
        self.view.translatesAutoresizingMaskIntoConstraints = false
        let tableView = UITableView(frame: CGRectZero, style: .grouped)
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.autoSolveDataSource = true
        tableView.allowsSelection = true
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0, bottom: self.view.safeAreaInsets.bottom, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.view.addSubview(tableView)
        self.tableView = tableView
        
        
        let topC = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let bottomC = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let leftC = NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0)
        let rightC = NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0)
        self.view.addConstraints([topC, bottomC, leftC, rightC])
        
        var datas: [CellModel] = []
        for i in 0...20 {
            let model = CellModel()
            model.key = "\(i)"
//            for _ in 0...3 {
//                let m0 = CellModel()
//                model.children.append(m0)
//                for _ in 0...3 {
//                    let m1 = CellModel()
//                    m0.children.append(m1)
//                }
//            }
            datas.append(model)
        }
        self.datas = datas
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
}

