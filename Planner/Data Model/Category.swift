//
//  Category.swift
//  Planner
//
//  Created by Tarek Nabulsi on 1/11/19.
//  Copyright © 2019 Tarek Nabulsi. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
