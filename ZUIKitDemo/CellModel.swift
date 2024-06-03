//
//  CellModel.swift
//  ZUIKitDemo
//
//  Created by yuedong on 6/3/24.
//

import Foundation
import ZUIKit

class CellModel: ZTableViewNodeProtocol {
    var key: String
    
    var footerTitle: String?
    
    var isSectionHeader: Bool
    
    var expanded: Bool
    
    var index: Int
    
    var depth: Int
    
    var children: [any ZUIKit.ZTableViewNodeProtocol]
    
    var indexPath: IndexPath
    
    var showingChildren: [any ZUIKit.ZTableViewNodeProtocol]
    
    func copy() -> any ZUIKit.ZTableViewNodeProtocol {
        let model = CellModel()
        model.key = self.key
        model.footerTitle = self.footerTitle
        model.isSectionHeader = self.isSectionHeader
        model.expanded = self.expanded
        model.index = self.index
        model.depth = self.depth
        model.children = []
        for var model in self.children {
            model.children.append(model.copy())
        }
        model.indexPath = self.indexPath
        model.showingChildren = self.showingChildren
        return model
    }
    required init() {
        self.key = ""
        self.footerTitle = ""
        self.isSectionHeader = false
        self.expanded = false
        self.index = 0
        self.depth = 0
        self.children = []
        self.indexPath = IndexPath(row: 0, section: 0)
        self.showingChildren = []
    }
}
