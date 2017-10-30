//
//  LXModule.swift
//  LXModuleDemo
//
//  Created by csj on 2017/10/30.
//  Copyright © 2017年 csj. All rights reserved.
//

import UIKit

class LXModule: NSObject { }

extension LXModule: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension LXModule: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
