//
//  ViewController.swift
//  LXModuleDemo
//
//  Created by csj on 2017/10/27.
//  Copyright © 2017年 csj. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {
    
    var lb: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let lb = UILabel()
        lb.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
        lb.textAlignment = .center
        self.addSubview(lb)
        self.lb = lb
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(title: String) {
        self.lb.text = title
    }
    
}

class CellCollection {
    var cells: [Int : UITableViewCell] = [:]
    
}

class LXModule4: LXModule {
    
    var containerView: UIView!
    
    var cells: CellCollection!
    
    var isFirstLoad: Bool = false
    
    override init() {
        
        self.cells = CellCollection()
        containerView = UIView()
        containerView.backgroundColor = UIColor.red
        containerView.alpha = 0.5
        containerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 43)
        let lb = UILabel()
        lb.frame = CGRect(x: 200, y: 0, width: 200, height: 44)
        lb.text = "悬浮窗"
        containerView.addSubview(lb)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ _tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableView = _tableView as! LXModuleTableView
        
        let cell: UITableViewCell!
        let index = tableView.pageIndex
        if self.cells.cells[index] != nil {
            cell = self.cells.cells[index]!
        } else {
            cell = Cell(style: .default, reuseIdentifier: nil)
            cell.backgroundColor = UIColor.green
            self.cells.cells[index] = cell
        }
        if index == 0 && !self.isFirstLoad {
            self.isFirstLoad = true
            cell.addSubview(self.containerView)
        }
        return cell!
    }
}

class LXModule1: LXModule {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Cell(style: .default, reuseIdentifier: nil)
        cell.setTitle(title: "LXModule1 \(indexPath.section) - \(indexPath.row)")
        cell.backgroundColor = UIColor.gray
        return cell
    }
}

class LXModule2: LXModule {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Cell(style: .default, reuseIdentifier: nil)
        cell.setTitle(title: "LXModule2 \(indexPath.section) - \(indexPath.row)")
        cell.backgroundColor = UIColor.darkGray
        return cell
    }
}

class LXModule3: LXModule {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cell(style: .default, reuseIdentifier: nil)
        cell.setTitle(title: "LXModule3 \(indexPath.section) - \(indexPath.row)")
        cell.backgroundColor = UIColor.lightGray
        return cell
    }
}

class ViewController: LXModuleViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //   [1,2,3] [1,2,3]
    // [ [4,5,6] [7,8,9] ]
    override func modules() -> (header :[LXModule], pages: [[LXModule]]) {
        return ([LXModule1(), LXModule4()], [[LXModule2(), LXModule3()],
                                             [LXModule3(), LXModule2()],
                                             [LXModule2()],
                                             [LXModule3()],
                                             [LXModule2(), LXModule2()],
                                             [LXModule3(), LXModule3()]])
    }
}

