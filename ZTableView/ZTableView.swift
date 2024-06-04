//
//  ZTableView.swift
//  ZTableView
//
//  Created by 赖依娴 on 2024/5/19.
//

import UIKit



open class ZTableView: UITableView {
    public enum ZTableViewExpansionType {
        case multiple
        case single
    }
    open var expansionAnimation: UITableView.RowAnimation = .top
    open var expansionType: ZTableViewExpansionType = .multiple
    open var datas: [ZTableViewNodeProtocol] = [] {
        didSet {
            controller.datas = datas
        }
    }
    open var autoSolveDataSource: Bool = true
    open weak var zDelegate: ZTableViewDelegate? {
        didSet {
            controller.zDelegate = self.zDelegate
        }
    }
    open weak override var delegate: (any UITableViewDelegate)? {
        didSet {
            controller.delegate = self.delegate
        }
    }
    open weak override var dataSource: (any UITableViewDataSource)? {
        didSet {
            controller.dataSource = self.dataSource
        }
    }
    open weak override var dragDelegate: (any UITableViewDragDelegate)? {
        didSet {
            controller.dragDelegate = self.dragDelegate
        }
    }
    open weak override var dropDelegate: (any UITableViewDropDelegate)? {
        didSet {
            controller.dropDelegate = self.dropDelegate
        }
    }
    
    internal var controller: ZTableViewController = ZTableViewController()
    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        controller.tableView = self
        self.register(ZTableViewCell.self, forCellReuseIdentifier: zCellID)
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        controller.tableView = self
        self.register(ZTableViewCell.self, forCellReuseIdentifier: zCellID)
    }
    open override func awakeFromNib() {
        super.awakeFromNib()
        controller.tableView = self
        self.register(ZTableViewCell.self, forCellReuseIdentifier: zCellID)
    }
}
