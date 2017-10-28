//
//  LXModuleViewController.swift
//  LXModuleDemo
//
//  Created by csj on 2017/10/27.
//  Copyright © 2017年 csj. All rights reserved.
//

import UIKit
import RxCocoa

//class LXModuleTableView: UITableView {
//    var pageIndex: Int
//}

class LXModuleViewController: UIViewController, LXModuleViewControllerDelegate {
    func modules() -> (header :[LXModule], pages: [[LXModule]]) {
        return ([], [])
    }
    
    var scrollView: UIScrollView!
    var tableView: UITableView! = UITableView()
    
    var tableViews: [UITableView]!
    var headerModuleModels: [LXModuleModel]!
    var headerSectionModels: [LXSectionModel]!
    var pagesModuleModels: [[LXModuleModel]]!
    var pagesSectionModels: [[LXSectionModel]]!
    
    var currentPage: Int = 0
    var sectionCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//            for sectionModel in self.headerSectionModels {
//                if sectionModel.module is LXModule4 {
//                    print (self.tableViews[0].rectForRow(at: IndexPath(row: 0, section: 0)))
//                }
//            }
//        })
        // observe contentSize
        
        self.tableViews[0].rx.observe(CGSize.self, "contentSize").subscribe(onNext: { (size) in
            
            for sectionModel in self.headerSectionModels {
                if sectionModel.module is LXModule4 {
                    print (self.tableViews[0].rectForRow(at: IndexPath(row: 0, section: 0)))
                }
            }
            
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        
        
        
        self.tableViews[0].rx.contentOffset.subscribe(onNext: { (point) in
            print(point)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        
    }
    
    func pageIndex(_ tableView: UITableView) -> Int {
        for index in 0..<self.tableViews.count {
            if tableView == self.tableViews[index] {
                return index
            }
        }
        assert(false, "error")
        return 0
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
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let pageCount = self.pagesModuleModels.count
        self.scrollView = UIScrollView()
        self.scrollView.frame = UIScreen.main.bounds
        self.scrollView.backgroundColor = UIColor.yellow
        self.scrollView.isPagingEnabled = true
        self.scrollView.contentSize = CGSize(width: screenWidth * CGFloat(pageCount), height: screenHeight)
        self.view.addSubview(self.scrollView)
        
        self.tableViews = []
        for index in 0..<pageCount {
            let pageTableView = UITableView()
            pageTableView.delegate = self
            pageTableView.dataSource = self
            pageTableView.frame = CGRect(x: screenWidth * CGFloat(index), y: 0, width: screenWidth, height: screenHeight)
            self.scrollView.addSubview(pageTableView)
            self.tableViews.append(pageTableView)
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
        
        self.currentPage = self.pageIndex(tableView)
        
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
        self.currentPage = self.pageIndex(tableView)
        return self.headerSectionModels.count + self.pagesSectionModels[self.currentPage].count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.currentPage = self.pageIndex(tableView)
        var sectionModel: LXSectionModel!
        if section < self.headerSectionModels.count {
            sectionModel = self.headerSectionModels[section]
        } else {
            sectionModel = self.pagesSectionModels[self.currentPage][section - self.headerSectionModels.count]
        }
        return sectionModel.module.tableView(tableView, numberOfRowsInSection:sectionModel.sectionIndexInModule)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.currentPage = self.pageIndex(tableView)
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
