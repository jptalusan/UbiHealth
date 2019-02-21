//
//  FoodItemClass.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2019/02/20.
//  Copyright © 2019 Jose Paolo Talusan. All rights reserved.
//

import UIKit

class FoodItemClass: UITableViewCell {
    var link: DiaryEntryController?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
//        backgroundColor = .red
        
//        let textField = UILabel()
//        textField.text = "Y"
//        let starButton = UIButton(type: .system)
//        starButton.setImage(UIImage(named: "report"), for: .normal)
//        starButton.tintColor =  .red
//        textField.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
//        starButton.addTarget(self, action: #selector(handleSelection), for: .touchUpInside)
//        accessoryView = textField
    }
    
    @objc private func handleSelection() {
        print("Marking as selected")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
