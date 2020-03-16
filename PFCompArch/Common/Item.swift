//
//  Item.swift
//  PFCompArch
//
//  Created by Sven A. Schmidt on 03/02/2020.
//  Copyright © 2020 finestructure. All rights reserved.
//

import Foundation


struct Item: Identifiable, Codable {
    let id: UUID
    var value: Int
}


extension Item: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self.id = UUID()
        self.value = value
    }
}
