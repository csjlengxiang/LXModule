//
//  LXModuleViewController.swift
//  LXModuleDemo
//
//  Created by csj on 2017/10/27.
//  Copyright © 2017年 csj. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

class LXModuleViewController: UIViewController {

    func modules() -> (header :[LXModule], pages: [[LXModule]]) {
        return ([], [])
    }
    
    var scrollView: UIScrollView!
    var header: [LXModule]!
    var pages: [[LXModule]]!
    var tableView: UITableView! = UITableView()
    var tableViewsCollection: [Int: LXModuleTableView] = [:]
    var headerSectionModels: [LXSectionModel]!
    var pagesSectionModelsCollection: [Int: [LXSectionModel]] = [:]
    
    var dispose: Disposable?
    
    var minPage: Int = 0
    var maxPage: Int = 0
    var currentPage: Int = 0
    var sectionCount: Int = 0

    var hoverHeight: CGFloat = 0
    
    var isHover: Bool = false
    
    var hoverView: UIView!
    var hoverCell: CellCollection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.frame = UIScreen.main.bounds
        self.scrollView.backgroundColor = UIColor.yellow
        self.scrollView.isPagingEnabled = true
        self.scrollView.bounces = false
        
        self.view.addSubview(self.scrollView)
        
        // load
        let (header, pages) = self.modules()
        self.header = header
        self.pages = pages
        
        
        self.currentPage = 2
        
        self.loadPage(currentPage: self.currentPage)
        
        self.scrollView.isScrollEnabled = false
        
        for tableView in self.tableViewsCollection.values {
            self.offsetObserve(tableView)
        }
    }
    
    // 刷新
    func loadPage(currentPage: Int) {
        self.minPage = currentPage
        self.maxPage = currentPage
        // 清空tableview
        for tableView in self.tableViewsCollection.values {
            tableView.removeFromSuperview()
        }
        self.tableViewsCollection.removeAll()
        // 清空数据
        self.pagesSectionModelsCollection.removeAll()
        
        self.headerSectionModels = self.setupHeaderDataSource(header: self.header)
        self.addTableView(page: currentPage) // 添加第一个
        let _ = self.addNextTableViewIfNeed(currentPage: currentPage)
        let _ = self.addPreTableViewIfNeed(currentPage: currentPage)

        if self.headerSectionModels.last!.moduleModel.module is LXModule4 {
            (self.headerSectionModels.last!.moduleModel.module as! LXModule4).isFirstLoad = false
            (self.headerSectionModels.last!.moduleModel.module as! LXModule4).FirstLoadPage = currentPage
        }
        self.scrollView.contentOffset = CGPoint(x: screenWidth * CGFloat(currentPage), y: 0)
        
        self.dispose?.dispose()
        self.dispose = self.tableViewsCollection[currentPage]!.rx.observe(CGSize.self, "contentSize").subscribe(onNext: { (size) in
            let sectionModel = self.headerSectionModels.last!
            if sectionModel.moduleModel.module is LXModule4 {
                
                self.hoverCell = (sectionModel.moduleModel.module as! LXModule4).cells
                self.hoverView = (sectionModel.moduleModel.module as! LXModule4).containerView
                
                self.hoverCell.cells[currentPage]?.addSubview(self.hoverView)
                
                self.hoverHeight = self.tableViewsCollection[currentPage]!.rectForRow(at: IndexPath(row: 0, section: self.headerSectionModels.count - 1)).origin.y
                
                for tableView in self.tableViewsCollection.values {
                    if tableView == self.tableViewsCollection[currentPage] {
                        continue
                    } else {
                        tableView.contentOffset = CGPoint(x: 0, y: self.hoverHeight)
                    }
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
    }
    
    func addNextTableViewIfNeed(currentPage: Int) -> Bool {
        let nextPage = currentPage + 1
        if nextPage > self.maxPage && nextPage < self.pages.count {
            self.maxPage = self.maxPage + 1
            self.addTableView(page: nextPage)
            return true
        }
        return false
    }
    
    func addPreTableViewIfNeed(currentPage: Int) -> Bool {
        let prePage = currentPage - 1
        if prePage < self.minPage && prePage >= 0 {
            self.minPage = self.minPage - 1
            self.addTableView(page: prePage)
            return true
        }
        return false
    }
    
    func addTableView(page: Int) {
        self.setupTableViewDataSource(currentPage: page)
        // tableView
        let pageTableView = LXModuleTableView()
        pageTableView.pageIndex = page
        pageTableView.delegate = self
        pageTableView.dataSource = self
        pageTableView.frame = CGRect(x: screenWidth * CGFloat(page), y: 0, width: screenWidth, height: screenHeight)
        
        self.tableViewsCollection[page] = pageTableView
        self.scrollView.addSubview(pageTableView)
        pageTableView.contentOffset = CGPoint(x: 0, y: self.hoverHeight)
        self.scrollView.contentSize = CGSize(width: screenWidth * CGFloat(self.maxPage + 1), height: screenHeight)
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
    
    func setupHeaderDataSource(header: [LXModule]) -> [LXSectionModel] {
        return self.setupModuleDataSource(modules: header, status: .header, lowerBound: 0)
    }
    
    func setupPageDataSource(page: [LXModule], pageIndex: Int, lowerBound: Int) -> [LXSectionModel] {
        return self.setupModuleDataSource(modules: page, status: .page(index: pageIndex), lowerBound: lowerBound)
    }
    
    func setupModuleDataSource(modules: [LXModule], status: LXModuleStatus, lowerBound: Int) -> [LXSectionModel] {
        let moduleModels = self.generateModuleModels(modules: modules, status: status)
        let sectionEnd = self.fillModuleModelsRange(lowerBound: lowerBound, moduleModels: moduleModels)
        var sectionModels: [LXSectionModel] = []
        var moduleModel: LXModuleModel!
        var index = 0
        for sectionIndex in lowerBound..<sectionEnd {
            if index < moduleModels.count && sectionIndex >= moduleModels[index].sectionRangeInTableView.lowerBound {
                moduleModel = moduleModels[index]
                index = index + 1
            }
            let sectionModel = LXSectionModel(moduleModel: moduleModel, sectionIndexInModule: sectionIndex - moduleModels[index - 1].sectionRangeInTableView.lowerBound)
            sectionModels.append(sectionModel)
        }
        return sectionModels
    }
    
    func setupTableViewDataSource(currentPage: Int) {
        
        print ("load datasource \(currentPage)")
        let page = self.pages[currentPage]
        self.pagesSectionModelsCollection[currentPage] = self.setupPageDataSource(page: page, pageIndex: currentPage, lowerBound: self.headerSectionModels.count)
    }
    
    func sectionModel(tableView: UITableView, section: Int) -> LXSectionModel {
        let currentPage = (tableView as! LXModuleTableView).pageIndex
        var sectionModel: LXSectionModel!
        if section < self.headerSectionModels.count {
            sectionModel = self.headerSectionModels[section]
        } else {
            sectionModel = self.pagesSectionModelsCollection[currentPage]![section - self.headerSectionModels.count]
        }
        return sectionModel
    }
}

extension LXModuleViewController: UIScrollViewDelegate {
    
    func determinCurrentPage(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        self.currentPage = Int(offsetX / screenWidth)
        if self.addNextTableViewIfNeed(currentPage: self.currentPage) {
            self.offsetObserve(self.tableViewsCollection[self.currentPage + 1]!)
            print("load next \(self.currentPage + 1)")
        }
        if self.addPreTableViewIfNeed(currentPage: self.currentPage) {
            self.offsetObserve(self.tableViewsCollection[self.currentPage - 1]!)
            print("load pree \(self.currentPage - 1)")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let offsetX = scrollView.contentOffset.x
            if offsetX <= screenWidth * CGFloat(self.minPage) {
                scrollView.contentOffset.x = screenWidth * CGFloat(self.minPage)
                print ("range min")
            } else if offsetX >= screenWidth * CGFloat(self.maxPage) {
                scrollView.contentOffset.x = screenWidth * CGFloat(self.maxPage)
                print ("range max")
            }
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
        return self.headerSectionModels.count + self.pagesSectionModelsCollection[currentPage]!.count
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
