//
//  ViewController.swift
//  ZUIKitDemo
//
//  Created by yuedong on 6/3/24.
//

import UIKit
import ZUIKit

let cellID = "cell.id.default"

class ViewController: UIViewController, ZTableViewDelegate, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    weak var tableView : ZTableView?
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: any UITableViewDropCoordinator) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.selectionStyle = .default
        cell.textLabel?.text = self.tableView!.showingDatas[indexPath.row].key
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView?.toggle(indexPath: indexPath)
        self.tableView?.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view.
        self.view.translatesAutoresizingMaskIntoConstraints = false
        let tableView = ZTableView(frame: CGRectZero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.autoSolveDataSource = true
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        self.view.addSubview(tableView)
        self.tableView = tableView
        
        
        let topC = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
        let bottomC = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        let leftC = NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 0)
        let rightC = NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1, constant: 0)
        self.view.addConstraints([topC, bottomC, leftC, rightC])
        
        var datas: [CellModel] = []
        for _ in 0...20 {
            let model = CellModel()
            for _ in 0...3 {
                let m0 = CellModel()
                model.children.append(m0)
                for _ in 0...3 {
                    let m1 = CellModel()
                    m0.children.append(m1)
                }
            }
            datas.append(model)
        }
        tableView.datas = datas
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
}

