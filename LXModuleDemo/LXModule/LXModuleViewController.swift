//
//  LXModuleViewController.swift
//  LXModuleDemo
//
//  Created by csj on 2017/10/27.
//  Copyright © 2017年 csj. All rights reserved.
//

import UIKit

class LXModuleViewController: UIViewController, LXModuleViewControllerDelegate {
    func modules() -> (header :[LXModule], pages: [[LXModule]]) {
        return ([], [])
    }
    
    var tableView: UITableView! = UITableView()
    var headerModuleModels: [LXModuleModel]!
    var headerSectionModels: [LXSectionModel]!
    var pagesModuleModels: [[LXModuleModel]]!
    var pagesSectionModels: [[LXSectionModel]]!
    
    var currentPage: Int = 0
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
        self.headerModuleModels = self.modules().header.map { (module) -> LXModuleModel in
            return LXModuleModel(module: module)
        }
        self.pagesModuleModels = []
        for pageModules in self.modules().pages {
            let pageModuleModels = pageModules.map({ (module) -> LXModuleModel in
                return LXModuleModel(module: module)
            })
            self.pagesModuleModels.append(pageModuleModels)
        }
            
        let headerSectionCount = self.headerModuleModels.reduce(0) { (sectionIndexInTableView, sectionModel) -> Int in
            sectionModel.sectionIndexInTableView = sectionIndexInTableView
            return sectionIndexInTableView + sectionModel.module.numberOfSections(in: self.tableView)
        }
        
        var pagesSectionCount: [Int] = []
        for pageModuleModels in self.pagesModuleModels {
            let pageSectionCount = pageModuleModels.reduce(headerSectionCount, { (sectionIndexInTableView, sectionModel) -> Int in
                sectionModel.sectionIndexInTableView = sectionIndexInTableView
                return sectionIndexInTableView + sectionModel.module.numberOfSections(in: self.tableView)
            })
            pagesSectionCount.append(pageSectionCount)
        }
        
        self.headerSectionModels = []
        var module: LXModule!
        var index = 0
        for sectionIndex in 0..<headerSectionCount {
            if index < self.headerModuleModels.count && sectionIndex >= self.headerModuleModels[index].sectionIndexInTableView {
                module = self.headerModuleModels[index].module
                index = index + 1
            }
            let sectionModel = LXSectionModel(module: module, sectionIndexInModule: sectionIndex - self.headerModuleModels[index - 1].sectionIndexInTableView)
            self.headerSectionModels.append(sectionModel)
        }
        
        self.pagesSectionModels = []
        
        for pageIndex in 0..<self.pagesModuleModels.count {
            let pageModuleModels = self.pagesModuleModels[pageIndex]
            let pageSectionCount = pagesSectionCount[pageIndex]
            var index = 0
            var pageSectionModels: [LXSectionModel] = []
            for sectionIndex in headerSectionCount..<pageSectionCount {
                if index < pageModuleModels.count && sectionIndex >= pageModuleModels[index].sectionIndexInTableView {
                    module = pageModuleModels[index].module
                    index = index + 1
                }
                let sectionModel = LXSectionModel(module: module, sectionIndexInModule: sectionIndex - pageModuleModels[index - 1].sectionIndexInTableView)
                pageSectionModels.append(sectionModel)
            }
            self.pagesSectionModels.append(pageSectionModels)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        var sectionModel: LXSectionModel!
        if section < self.headerSectionModels.count {
            sectionModel = self.headerSectionModels[section]
        } else {
            sectionModel = self.pagesSectionModels[self.currentPage][section - self.headerSectionModels.count]
        }
        let moduleIndexPath = IndexPath(row: indexPath.row, section: sectionModel.sectionIndexInModule)
        return sectionModel.module.tableView(tableView, heightForRowAt: moduleIndexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.headerSectionModels.count + self.pagesSectionModels[self.currentPage].count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var sectionModel: LXSectionModel!
        if section < self.headerSectionModels.count {
            sectionModel = self.headerSectionModels[section]
        } else {
            sectionModel = self.pagesSectionModels[self.currentPage][section - self.headerSectionModels.count]
        }
        return sectionModel.module.tableView(tableView, numberOfRowsInSection:sectionModel.sectionIndexInModule)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        var sectionModel: LXSectionModel!
        if section < self.headerSectionModels.count {
            sectionModel = self.headerSectionModels[section]
        } else {
            sectionModel = self.pagesSectionModels[self.currentPage][section - self.headerSectionModels.count]
        }
        let moduleIndexPath = IndexPath(row: indexPath.row, section: sectionModel.sectionIndexInModule)
        return sectionModel.module.tableView(tableView, cellForRowAt: moduleIndexPath)
    }
}
