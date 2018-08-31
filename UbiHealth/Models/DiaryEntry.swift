//
//  DiaryEntry.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2018/08/31.
//  Copyright © 2018 Jose Paolo Talusan. All rights reserved.
//

import Foundation
import Firebase

struct DiaryEntry {
    
    let ref: DatabaseReference?
    let key: String
    let date: Date
    let entry: String
    let time: String
    
//    init(entry: String, time: String, key: String = "") {
//        self.ref = nil
//        self.key = key
//        self.entry = entry
//        self.time = time
//    }
    
    init?(date: Date, snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let entry = value["entry"] as? String,
            let time = value["time"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.date = date
        self.key = snapshot.key
        self.entry = entry
        self.time = time
    }
    
    func toAnyObject() -> Any {
        return [
            "key": key,
            "date": date,
            "entry": entry,
            "time": time
        ]
    }
}
