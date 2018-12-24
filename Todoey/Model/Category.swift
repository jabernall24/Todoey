//
//  Category.swift
//  Todoey
//
//  Created by Jesus Andres Bernal Lopez on 12/23/18.
//  Copyright © 2018 Jesus Andres Bernal Lopez. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name = ""
    @objc dynamic var color = ""
    let items = List<Item>()
}
