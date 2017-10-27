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

class LXModule1: LXModule {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Cell(style: .default, reuseIdentifier: nil)
        cell.setTitle(title: "LXModule1 \(indexPath.section) - \(indexPath.row)")
        return cell
    }
}

class LXModule2: LXModule {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Cell(style: .default, reuseIdentifier: nil)
        cell.setTitle(title: "LXModule2 \(indexPath.section) - \(indexPath.row)")
        return cell
    }
}

class LXModule3: LXModule {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Cell(style: .default, reuseIdentifier: nil)
        cell.setTitle(title: "LXModule3 \(indexPath.section) - \(indexPath.row)")
        return cell
    }
}

class ViewController: LXModuleViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    //   [1,2,3] [1,2,3]
    // [ [4,5,6] [7,8,9] ]
    override func modules() -> [LXModule]! {
        return [LXModule1(), LXModule2(), LXModule3()]
    }

}

