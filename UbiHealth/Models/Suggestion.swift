//
//  Suggestion.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2018/10/24.
//  Copyright © 2018 Jose Paolo Talusan. All rights reserved.
//

import Foundation
import Firebase

struct Suggestion {
    
    let ref: DatabaseReference?
    let key: String
    let date: Date
    let suggested: String
    let time: String
    
    init?(date: Date, snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let suggested = value["suggested"] as? String,
            let time = value["time"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.date = date
//        Key is suggester userID
        self.key = snapshot.key
        self.suggested = suggested
        self.time = time
    }
    
    func toAnyObject() -> Any {
        return [
            "key": key,
            "date": date,
            "suggested": suggested,
            "time": time
        ]
    }
}
