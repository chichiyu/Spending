//
//  Spending.swift
//  Spending
//
//  Created by Chi Yu on 8/3/18.
//  Copyright © 2018 Chi Yu. All rights reserved.
//

import UIKit

class Spending: NSObject, NSCoding {
    // MARK: Properties
    var date: Date
    var descript: String?
    var money: Double
    var type: String
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("spendings")
    
    // MARK: Types
    struct PropertyKey {
        static let date = "date"
        static let descript = "descript"
        static let money = "money"
        static let type = "type"
    }
    
    // MARK: Initialization
    init(date: Date, descript: String?, money: Double, type: String) {
        self.date = date
        self.descript = descript
        self.money = money
        self.type = type
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(descript, forKey: PropertyKey.descript)
        aCoder.encode(money, forKey: PropertyKey.money)
        aCoder.encode(type, forKey: PropertyKey.type)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObject(forKey: PropertyKey.date) as! Date
        let descript = aDecoder.decodeObject(forKey: PropertyKey.descript) as? String
        let money = aDecoder.decodeDouble(forKey: PropertyKey.money)
        let type = aDecoder.decodeObject(forKey: PropertyKey.type) as? String
        
        self.init(date: date, descript: descript, money: money, type: type ?? "")
    }
}
