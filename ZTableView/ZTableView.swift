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
    open var showingDatas: [ZTableViewNodeProtocol] {
        get {
            return controller.showingDatas
        }
    }
    open var autoSolveDataSource: Bool = true
    open var autoSelectRow: Bool = true
    open weak var zDelegate: ZTableViewDelegate? {
        willSet(zDelegate) {
            controller.zDelegate = zDelegate
        }
    }
    open weak override var delegate: (any UITableViewDelegate)? {
        willSet(delegate) {
            if delegate?.isKind(of: ZTableViewController.self) == true {
                return
            }
            controller.delegate = delegate
        }
        didSet {
            if self.delegate?.isKind(of: ZTableViewController.self) == true {
                return
            }
            self.delegate = controller
        }
    }
    open weak override var dataSource: (any UITableViewDataSource)? {
        willSet(dataSource) {
            if dataSource?.isKind(of: ZTableViewController.self) == true {
                return
            }
            controller.dataSource = dataSource
        }
        didSet {
            if self.dataSource?.isKind(of: ZTableViewController.self) == true {
                return
            }
            self.dataSource = controller
        }
    }
    open weak override var dragDelegate: (any UITableViewDragDelegate)? {
        willSet(dragDelegate) {
            if dragDelegate?.isKind(of: ZTableViewController.self) == true {
                return
            }
            controller.dragDelegate = dragDelegate
        }
        didSet {
            if self.dragDelegate?.isKind(of: ZTableViewController.self) == true {
                return
            }
            self.dragDelegate = controller
        }
    }
    open weak override var dropDelegate: (any UITableViewDropDelegate)? {
        willSet(dropDelegate) {
            if dropDelegate?.isKind(of: ZTableViewController.self) == true {
                return
            }
            controller.dropDelegate = dropDelegate
        }
        didSet {
            if self.dropDelegate?.isKind(of: ZTableViewController.self) == true {
                return
            }
            self.dropDelegate = controller
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
