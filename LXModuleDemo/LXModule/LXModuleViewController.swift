//
//  LXModuleViewController.swift
//  LXModuleDemo
//
//  Created by csj on 2017/10/27.
//  Copyright © 2017年 csj. All rights reserved.
//

import UIKit

class LXModuleViewController: UIViewController, LXModuleViewControllerDelegate {
    func modules() -> [LXModule]! {
        return []
    }
    
    var tableView: UITableView! = UITableView()
    var moduleModels: [LXModuleModel]!
    var sectionModels: [LXSectionModel]!
    var sectionCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        self.tableView.frame = UIScreen.main.bounds
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.setup()
        self.tableView.reloadData()
    }
    
    func setup() {
        self.moduleModels = self.modules().map { (module) -> LXModuleModel in
            return LXModuleModel(module: module)
        }
        self.sectionCount = self.moduleModels.reduce(0) { (sectionIndexInModule, sectionModel) -> Int in
            sectionModel.sectionIndexInTableView = sectionIndexInModule
            return sectionIndexInModule + sectionModel.module.numberOfSections(in: self.tableView)
        }
        
        self.sectionModels = []
        var module: LXModule!
        var index = 0
        for sectionIndex in 0..<self.sectionCount {
            if index < self.moduleModels.count && sectionIndex >= self.moduleModels[index].sectionIndexInTableView {
                module = self.moduleModels[index].module
                index = index + 1
            }
            let sectionModel = LXSectionModel(module: module, sectionIndexInModule: sectionIndex - self.moduleModels[index - 1].sectionIndexInTableView)
            self.sectionModels.append(sectionModel)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionModel = self.sectionModels[indexPath.section]
        let moduleIndexPath = IndexPath(row: indexPath.row, section: sectionModel.sectionIndexInModule)
        return sectionModel.module.tableView(tableView, heightForRowAt: moduleIndexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionModels[section].module.tableView(tableView, numberOfRowsInSection:self.sectionModels[section].sectionIndexInModule)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = self.sectionModels[indexPath.section]
        let moduleIndexPath = IndexPath(row: indexPath.row, section: sectionModel.sectionIndexInModule)
        return sectionModel.module.tableView(tableView, cellForRowAt: moduleIndexPath)
    }
}
