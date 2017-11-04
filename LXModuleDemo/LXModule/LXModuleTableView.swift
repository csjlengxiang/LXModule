//
//  LXModuleTableView.swift
//  LXModuleDemo
//
//  Created by csj on 2017/10/30.
//  Copyright © 2017年 csj. All rights reserved.
//

import UIKit

class LXModuleTableView: UITableView {
    var pageIndex: Int = 0
    
    deinit {
        print ("LXModuleTableView deinit")
    }
    
    func addRegisters(header: [LXModule], page: [LXModule]) {
        let modules = header + page
        for module in modules {
            for register in module.registers {
                self.register(register.0, forCellReuseIdentifier: register.1)
            }
        }
    }
}
