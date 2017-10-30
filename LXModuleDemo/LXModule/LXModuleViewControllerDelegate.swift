//
//  LXModuleViewControllerDelegate.swift
//  LXModuleDemo
//
//  Created by csj on 2017/10/27.
//  Copyright © 2017年 csj. All rights reserved.
//

import UIKit

enum LXModuleStatus {
    case header
    case page(index: Int)
}

class LXModuleModel {
    var sectionRangeInTableView: Range<Int>!
    var status: LXModuleStatus
    var module: LXModule
    
    init(module: LXModule, status: LXModuleStatus) {
        self.module = module
        self.status = status
    }
}

class LXSectionModel {
    var moduleModel: LXModuleModel
    var sectionIndexInModule: Int
    
    init(moduleModel: LXModuleModel, sectionIndexInModule: Int) {
        self.moduleModel = moduleModel
        self.sectionIndexInModule = sectionIndexInModule
    }
}
