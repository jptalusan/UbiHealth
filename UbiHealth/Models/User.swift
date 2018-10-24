//
//  User.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2018/10/24.
//  Copyright © 2018 Jose Paolo Talusan. All rights reserved.
//

import Foundation
import Firebase

struct User {
    
    let ref: DatabaseReference?
    let id: String
//    let diaryEntry: String
    let email: String
    let name: String
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: Any],
//            let diaryEntry = value["diary_entries"] as? DiaryEntry,
            let email = value["email"] as? String,
            let name = value["name"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.id = snapshot.key
        self.email = email
        self.name = name
//        self.diaryEntry = diaryEntry
    }
    
    func toAnyObject() -> Any {
        return [
            "id": id,
            "email": email,
            "name": "name"
        ]
    }
}
