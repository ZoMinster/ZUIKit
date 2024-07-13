//
//  ZTableView.swift
//  ZTableView
//
//  Created by Minster on 2024/5/19.
//

import UIKit



open class ZTableView: UITableView {
    public enum ZTableViewExpansionType {
        case multiple
        case single
    }
    open var addAnimation: UITableView.RowAnimation = .top
    open var removeAnimation: UITableView.RowAnimation = .top
    open var expansionType: ZTableViewExpansionType = .multiple
    open var isExpanding: Bool = false
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
    
    func compatible() {
        if #available(iOS 11.0, *) {
            self.estimatedRowHeight = 0;
            self.estimatedSectionHeaderHeight = 0;
            self.estimatedSectionFooterHeight = 0;
        }
    }
    
    internal var controller: ZTableViewController = ZTableViewController()
    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        controller.tableView = self
        compatible()
        self.register(ZTableViewCell.self, forCellReuseIdentifier: zCellID)
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        controller.tableView = self
        compatible()
        self.register(ZTableViewCell.self, forCellReuseIdentifier: zCellID)
    }
    open override func awakeFromNib() {
        super.awakeFromNib()
        controller.tableView = self
        compatible()
        self.register(ZTableViewCell.self, forCellReuseIdentifier: zCellID)
    }
    open func toggle(indexPath: IndexPath) {
        var expand = false
        if self.controller.hasSectionHeader {
            let node = self.showingDatas[indexPath.section].children[indexPath.row]
            expand = !node.expanded
        } else {
            let node = self.showingDatas[indexPath.row]
            expand = !node.expanded
        }
        self.expand(expand: expand, indexPath: indexPath)
    }
    open func expand(expand: Bool, indexPath: IndexPath) {
        let (_, _, optIndexPaths) = self.controller.solveDatas(expand: expand, indexPath: indexPath)
        if optIndexPaths.isEmpty {
            return
        }
        self.reloadData()
//        let oldContentHeight: CGFloat = self.contentSize.height
//        let oldOffsetY: CGFloat = self.contentOffset.y
//        self.performBatchUpdates {
//            if expand {
//                self.insertRows(at: optIndexPaths, with: self.addAnimation)
//            } else {
//                self.deleteRows(at: optIndexPaths, with: self.removeAnimation)
//            }
//        }
//        self.reloadData()
//        let newContentHeight: CGFloat = self.contentSize.height
//        self.contentOffset.y = oldOffsetY + (newContentHeight - oldContentHeight)
//        DispatchQueue.main.async {
//            
//        }
    }
}
