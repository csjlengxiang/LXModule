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

    func modulesClass() -> (headerClass: [LXModule.Type], pagesClass: [[LXModule.Type]]) {
        return ([], [])
    }
    
    var scrollView: UIScrollView!

    var headerClass: [LXModule.Type]!
    var pagesClass: [[LXModule.Type]]!
    var header: [LXModule] = []
    var pages: [Int: [LXModule]] = [:]

    var tableView: UITableView! = UITableView()
    var tableViews: [Int: LXModuleTableView] = [:]
    var headerSectionModels: [LXSectionModel]!
    var pagesSectionModels: [Int: [LXSectionModel]] = [:]
    
    var minPage: Int = 0
    var maxPage: Int = 0
    var currentPage: Int = 0

    var hoverHeight: CGFloat = 0
    
    var isHover: Bool = false
    
    var hoverView: UIView!
    var hoverCell: CellCollection!

    var disposeBag: DisposeBag!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.frame = UIScreen.main.bounds
        self.scrollView.backgroundColor = UIColor.yellow
        self.scrollView.isPagingEnabled = true
        self.scrollView.bounces = false
        
        self.view.addSubview(self.scrollView)
        
        let (headerClass, pagesClass) = self.modulesClass()
        self.headerClass = headerClass
        self.pagesClass = pagesClass

        self.currentPage = 2
        self.loadPage(currentPage: self.currentPage)
    }
    
    // 刷新
    func loadPage(currentPage: Int) {
        self.scrollView.isScrollEnabled = false
        
        self.hoverHeight = 0
        self.isHover = false

        self.minPage = currentPage
        self.maxPage = currentPage
        self.disposeBag = DisposeBag()
        self.headerSectionModels = []
        self.pagesSectionModels.removeAll()
        
        // 清空tableview cell数据，不然强制滚动，会有数据丢失
        
        self.headerSectionModels = self.setupHeaderDataSource(headerClass: self.headerClass)
        
        if self.headerSectionModels.last!.moduleModel.module is LXModule4 {
            (self.headerSectionModels.last!.moduleModel.module as! LXModule4).isFirstLoad = false
            (self.headerSectionModels.last!.moduleModel.module as! LXModule4).FirstLoadPage = currentPage
            (self.headerSectionModels.last!.moduleModel.module as! LXModule4).cells = CellCollection()
        }
        self.addTableView(page: currentPage) // 添加第一个
        let _ = self.addNextTableViewIfNeed(currentPage: currentPage)
        let _ = self.addPreTableViewIfNeed(currentPage: currentPage)
        

        self.scrollView.setContentOffset(CGPoint(x: screenWidth * CGFloat(currentPage), y: 0), animated: false)
//        self.scrollView.contentOffset = CGPoint(x: screenWidth * CGFloat(currentPage), y: 0)
        
        self.tableViews[currentPage]!.rx.observe(CGSize.self, "contentSize").subscribe(onNext: { [unowned self](size) in
            let sectionModel = self.headerSectionModels.last!
            if sectionModel.moduleModel.module is LXModule4 {
                
                self.hoverCell = (sectionModel.moduleModel.module as! LXModule4).cells
                self.hoverView = (sectionModel.moduleModel.module as! LXModule4).containerView
                
                self.hoverHeight = self.tableViews[currentPage]!.rectForRow(at: IndexPath(row: 0, section: self.headerSectionModels.count - 1)).origin.y

                for page in self.minPage...self.maxPage {
                    let tableView = self.tableViews[page]!
                    if tableView == self.tableViews[currentPage] {
                        continue
                    } else {
                        tableView.contentOffset = CGPoint(x: 0, y: self.hoverHeight)
                    }
                }
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: self.disposeBag)

        // 清空tableview cell数据，不然强制滚动，因为数据被清空，而没有reload,cellforrow会拿到nil数据导致crash
        self.reloadTableViews(range: 0..<self.minPage)
        self.reloadTableViews(range: (self.maxPage+1)..<self.pagesClass.count)
    }

    func reloadTableViews(range: Range<Int>) {
        for page in range.lowerBound..<range.upperBound {
            self.tableViews[page]?.reloadData()
        }
    }
    
    func updateScrollViewSize(maxPage: Int) {
        self.scrollView.contentSize = CGSize(width: screenWidth * CGFloat(maxPage + 1), height: screenHeight)
    }
    
    func addNextTableViewIfNeed(currentPage: Int) -> Bool {
        let nextPage = currentPage + 1
        if nextPage > self.maxPage && nextPage < self.pagesClass.count {
            self.maxPage = nextPage // 注意顺序
            self.addTableView(page: nextPage)
            self.updateScrollViewSize(maxPage: self.maxPage)
            return true
        }
        return false
    }
    
    func addPreTableViewIfNeed(currentPage: Int) -> Bool {
        let prePage = currentPage - 1
        if prePage < self.minPage && prePage >= 0 {
            self.minPage = prePage
            self.addTableView(page: prePage)
            return true
        }
        return false
    }
    
    func addTableView(page: Int) {
        self.setupTableViewDataSource(currentPage: page)
        // tableView
        if self.tableViews[page] == nil {
            let pageTableView = LXModuleTableView()
            pageTableView.pageIndex = page
            pageTableView.delegate = self
            pageTableView.dataSource = self
            pageTableView.frame = CGRect(x: screenWidth * CGFloat(page), y: 0, width: screenWidth, height: screenHeight)
            self.scrollView.addSubview(pageTableView)
            self.tableViews[page] = pageTableView
        } else {
            // 注意需要重新加载数据
            self.tableViews[page]!.reloadData()
        }
        self.tableViews[page]!.contentOffset = CGPoint(x: 0, y: self.hoverHeight)
        self.offsetObserve(self.tableViews[page]!)
    }
    
    func offsetObserve(_ tableView: LXModuleTableView) {
        tableView.rx.contentOffset.filter({ [unowned tableView](_) -> Bool in
            return self.currentPage == tableView.pageIndex
        }).subscribe(onNext: { [unowned self](point) in
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
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: self.disposeBag)
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

    func setupHeaderDataSource(headerClass: [LXModule.Type]) -> [LXSectionModel] {
        if self.header.count <= 0 {
            self.header = headerClass.map({ (LXModuleClass) -> LXModule in
                return LXModuleClass.init()
            })
        }
        return self.setupModuleDataSource(modules: self.header, status: .header, lowerBound: 0)
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
        if self.pages[currentPage] == nil {
            self.pages[currentPage] = self.pagesClass[currentPage].map({ (LXModuleClass) -> LXModule in
                return LXModuleClass.init()
            })
        }
        let page = self.pages[currentPage]!
        self.pagesSectionModels[currentPage] = self.setupModuleDataSource(modules: page, status: .page(index: currentPage), lowerBound: self.headerSectionModels.count)
    }
    
    func sectionModel(tableView: UITableView, section: Int) -> LXSectionModel {
        let currentPage = (tableView as! LXModuleTableView).pageIndex
        var sectionModel: LXSectionModel!
        if section < self.headerSectionModels.count {
            sectionModel = self.headerSectionModels[section]
        } else {
            sectionModel = self.pagesSectionModels[currentPage]![section - self.headerSectionModels.count]
        }
        return sectionModel
    }
}

extension LXModuleViewController: UIScrollViewDelegate {
    
    func determinCurrentPage(scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        self.currentPage = Int(offsetX / screenWidth)
        if self.addNextTableViewIfNeed(currentPage: self.currentPage) {
//            self.offsetObserve(self.tableViewsCollection[self.currentPage + 1]!)
            print("load next \(self.currentPage + 1)")
        }
        if self.addPreTableViewIfNeed(currentPage: self.currentPage) {
//            self.offsetObserve(self.tableViewsCollection[self.currentPage - 1]!)
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
        guard currentPage >= self.minPage && currentPage <= self.maxPage else {
            return 0
        }
        return self.headerSectionModels.count + self.pagesSectionModels[currentPage]!.count
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
