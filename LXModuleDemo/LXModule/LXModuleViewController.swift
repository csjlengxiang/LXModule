//
//  LXModuleViewController.swift
//  LXModuleDemo
//
//  Created by csj on 2017/10/27.
//  Copyright © 2017年 csj. All rights reserved.
//

import UIKit
import RxCocoa

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

class LXModuleViewController: UIViewController {

    func modules() -> (header :[LXModule], pages: [[LXModule]]) {
        return ([], [])
    }
    
    var scrollView: UIScrollView!
    var pageCount: Int = 0
    var tableView: UITableView! = UITableView()
    var tableViews: [LXModuleTableView]!
    var headerSectionModels: [LXSectionModel]!
    var pagesSectionModels: [[LXSectionModel]]!
    
    var currentPage: Int = 0
    var sectionCount: Int = 0

    var hoverHeight: CGFloat = 0
    
    var isHover: Bool = false
    
    var hoverView: UIView!
    var hoverCell: CellCollection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableViewDataSource()
    
        let pageCount = self.pageCount
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.frame = UIScreen.main.bounds
        self.scrollView.backgroundColor = UIColor.yellow
        self.scrollView.isPagingEnabled = true
        self.scrollView.bounces = false
        
        let initPageCount = CGFloat(min(2, pageCount))
        
        self.scrollView.contentSize = CGSize(width: screenWidth * initPageCount, height: screenHeight)
        self.view.addSubview(self.scrollView)
        
        self.currentPage = 0
        self.tableViews = []
        self.addTableView(page: 0) // 添加第一个
        let _ = self.addTableViewIfNeed()
        
        let _ = self.tableViews[0].rx.observe(CGSize.self, "contentSize").subscribe(onNext: { (size) in
            for sectionIndex in 0..<self.headerSectionModels.count {
                let sectionModel = self.headerSectionModels[sectionIndex]
                if sectionModel.moduleModel.module is LXModule4 {
//                    print (self.tableViews[0].rectForRow(at: IndexPath(row: 0, section: sectionIndex)))
                    
                    self.hoverCell = (sectionModel.moduleModel.module as! LXModule4).cells
                    self.hoverView = (sectionModel.moduleModel.module as! LXModule4).containerView
                    self.hoverHeight = self.tableViews[0].rectForRow(at: IndexPath(row: 0, section: sectionIndex)).origin.y
                    
                    // 预先加载第二个
                    for index in 1..<self.tableViews.count {
                        self.tableViews[index].contentOffset = CGPoint(x: 0, y: self.hoverHeight)
                    }
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        
        self.scrollView.isScrollEnabled = false
        
        for tableView in self.tableViews {
            self.offsetObserve(tableView)
        }
    }
    
    func addTableViewIfNeed() -> Bool {
        let nextPage = self.currentPage + 1
        if nextPage >= self.tableViews.count && nextPage < self.pageCount {
            self.addTableView(page: nextPage)
            return true
        }
        return false
    }
    
    func addTableView(page: Int) {
        let pageTableView = LXModuleTableView()
        pageTableView.pageIndex = page
        pageTableView.delegate = self
        pageTableView.dataSource = self
        pageTableView.frame = CGRect(x: screenWidth * CGFloat(page), y: 0, width: screenWidth, height: screenHeight)
        self.tableViews.append(pageTableView)
        self.scrollView.addSubview(pageTableView)
        pageTableView.contentOffset = CGPoint(x: 0, y: self.hoverHeight)
        self.scrollView.contentSize = CGSize(width: screenWidth * CGFloat(page + 1), height: screenHeight)
    }
    
    func offsetObserve(_ tableView: LXModuleTableView) {
        let _ = tableView.rx.contentOffset.subscribe(onNext: { (point) in
            print(point)
            if point.y > self.hoverHeight && !self.isHover {
                self.scrollView.isScrollEnabled = true
                print ("悬浮")
                self.isHover = true
                self.view.addSubview(self.hoverView)
            } else if point.y < self.hoverHeight && self.isHover && self.hoverCell.cells[tableView.pageIndex] != nil {
                self.scrollView.isScrollEnabled = false
                print ("取消悬浮")
                self.hoverCell.cells[tableView.pageIndex]!.addSubview(self.hoverView)
                self.isHover = false
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
    }
    
    func generateModuleModels(modules: [LXModule], status: LXModuleStatus) -> [LXModuleModel] {
        return modules.map({ (module) -> LXModuleModel in
            return LXModuleModel(module: module, status: status)
        })
    }
    
    func fillModuleModelsRange(lowerBound: Int, moduleModels: [LXModuleModel]) -> Int {
        return moduleModels.reduce(lowerBound) { (lowerBound, sectionModel) -> Int in
            let upperBound = lowerBound + sectionModel.module.numberOfSections(in: self.tableView)
            sectionModel.sectionRangeInTableView = lowerBound..<upperBound
            return upperBound
        }
    }
    
    func setupTableViewDataSource() {
        let (header, pages) = self.modules()
        self.pageCount = pages.count
        let headerModuleModels = self.generateModuleModels(modules: header, status: .header)
        let headerSectionEnd = self.fillModuleModelsRange(lowerBound: 0, moduleModels: headerModuleModels)

        var pagesModuleModels: [[LXModuleModel]] = []
        var pagesSectionEnd: [Int] = []
        for index in 0..<pages.count {
            let page = pages[index]
            let pageModuleModels = self.generateModuleModels(modules: page, status: .page(index: index))
            let pageSectionCount = self.fillModuleModelsRange(lowerBound: headerSectionEnd, moduleModels: pageModuleModels)
            pagesModuleModels.append(pageModuleModels)
            pagesSectionEnd.append(pageSectionCount)
        }
        
        self.headerSectionModels = []
        var moduleModel: LXModuleModel!
        var index = 0
        for sectionIndex in 0..<headerSectionEnd {
            if index < headerModuleModels.count && sectionIndex >= headerModuleModels[index].sectionRangeInTableView.lowerBound {
                moduleModel = headerModuleModels[index]
                index = index + 1
            }
            let sectionModel = LXSectionModel(moduleModel: moduleModel, sectionIndexInModule: sectionIndex - headerModuleModels[index - 1].sectionRangeInTableView.lowerBound)
            self.headerSectionModels.append(sectionModel)
        }
        
        self.pagesSectionModels = []
        
        for pageIndex in 0..<pagesModuleModels.count {
            let pageModuleModels = pagesModuleModels[pageIndex]
            let pageSectionCount = pagesSectionEnd[pageIndex]
            var index = 0
            var pageSectionModels: [LXSectionModel] = []
            for sectionIndex in headerSectionEnd..<pageSectionCount {
                if index < pageModuleModels.count && sectionIndex >= pageModuleModels[index].sectionRangeInTableView.lowerBound {
                    moduleModel = pageModuleModels[index]
                    index = index + 1
                }
                let sectionModel = LXSectionModel(moduleModel: moduleModel, sectionIndexInModule: sectionIndex - pageModuleModels[index - 1].sectionRangeInTableView.lowerBound)
                pageSectionModels.append(sectionModel)
            }
            self.pagesSectionModels.append(pageSectionModels)
        }
    }
    
    func sectionModel(tableView: UITableView, section: Int) -> LXSectionModel {
        let currentPage = (tableView as! LXModuleTableView).pageIndex
        var sectionModel: LXSectionModel!
        if section < self.headerSectionModels.count {
            sectionModel = self.headerSectionModels[section]
        } else {
            sectionModel = self.pagesSectionModels[currentPage][section - self.headerSectionModels.count]
        }
        return sectionModel
    }
}

extension LXModuleViewController: UIScrollViewDelegate {
    
    func determinCurrentPage(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        self.currentPage = Int(offsetX / screenWidth)
        if self.addTableViewIfNeed() {
            self.offsetObserve(self.tableViews.last!)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && scrollView == self.scrollView {
            self.determinCurrentPage(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            self.determinCurrentPage(scrollView: scrollView)
        }
    }
}

extension LXModuleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionModel = self.sectionModel(tableView: tableView, section: indexPath.section)
        let moduleIndexPath = IndexPath(row: indexPath.row, section: sectionModel.sectionIndexInModule)
        return sectionModel.moduleModel.module.tableView(tableView, heightForRowAt: moduleIndexPath)
    }
}

extension LXModuleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let currentPage = (tableView as! LXModuleTableView).pageIndex
        return self.headerSectionModels.count + self.pagesSectionModels[currentPage].count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionModel = self.sectionModel(tableView: tableView, section: section)
        return sectionModel.moduleModel.module.tableView(tableView, numberOfRowsInSection:sectionModel.sectionIndexInModule)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = self.sectionModel(tableView: tableView, section: indexPath.section)
        let moduleIndexPath = IndexPath(row: indexPath.row, section: sectionModel.sectionIndexInModule)
        return sectionModel.moduleModel.module.tableView(tableView, cellForRowAt: moduleIndexPath)
    }
}
