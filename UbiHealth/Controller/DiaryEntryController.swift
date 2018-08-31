//
//  DiaryEntryController.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2018/08/30.
//  Copyright © 2018 Jose Paolo Talusan. All rights reserved.
//

import UIKit
import Firebase

class DiaryEntryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ref = Database.database().reference(withPath: "diarychoices")
    let usersRef = Database.database().reference(withPath: "users")
    var items: [String] = []
    var count: UInt = 0
    let cellId = "cellId"
    var diaryEntryType: String = ""
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.bounces = false
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
//        tableView.addTarget(self, action: #selector(handleDiary), for: .touchUpInside)
        return tableView
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        button.setTitle("Submit entry", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()
    
    @objc
    func handleSubmit() {
        guard let selectedIndexes = tableView.indexPathsForSelectedRows else {
            print("Error getting selected rows")
            return
        }
        
        var itemCSV: String = ""
        for index in selectedIndexes {
            itemCSV += "\(items[index.row]);"
//            print("\(items[index.row])") //Here you get the text of cell
        }
        let output = itemCSV.dropLast()
        print(output)

        //Use as key
        let datestr = Date().currentUTCTimeZoneDate
        print(datestr)
        let datetimeArr = datestr.components(separatedBy: " ")
        print(datetimeArr[0])
        print(datetimeArr[1])
        
        //Convert back for comparing
        let date2 = convertDateTimeStringToDate(datetime: datestr)
        print(date2)
        
        let userID = Auth.auth().currentUser!.uid
        
        //TODO Check if entry exists for the day and ask if want to overwrite
        let diaryEntryRef = usersRef.child(userID).child("diary_entries").child(datetimeArr[0].lowercased()).child(diaryEntryType)
        
        diaryEntryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("observerSingleEvent")
            
            if snapshot.hasChild("entry") && snapshot.hasChild("time") {
                var entries = snapshot.value as! [String:AnyObject]
                print(entries)
                
                //TODO: Ask if want to overwrite prior entry
                print("Entry already exists")
                if let entry = entries["entry"],
                    let time = entries["time"] {
//                    print("on \(time) you entered: \(entry)")
                    let entryStr = entry as! String
                    let alert = UIAlertController(title: "Duplicate entry detected.",
                                                  message: "You entered: \(entryStr.capitalizingFirstLetter()) on \(time)",
                                                  preferredStyle: .alert)
    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                let values = [//"type": diaryEntryType as String,
                              "entry": String(output),
                              "time": datetimeArr[1]]
                diaryEntryRef.updateChildValues(values) {
                    error, ref in
                    if error != nil {
                        print(error!.localizedDescription)
                        let alert = UIAlertController(title: "Inserting data failed",
                                                      message: error?.localizedDescription,
                                                      preferredStyle: .alert)
        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
        
                        return
                    }
                    print("Saved successfully into firebase")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    override func viewDidLoad() {
        //TODO: Check if date and entry exists, if so, grey out or have some indicator that it's filled up
        super.viewDidLoad()
        
        diaryEntryType = PassClass.myInstance.string1
        print(diaryEntryType)
        
        navigationItem.title = "\(diaryEntryType) Diary Entry"
        
        [tableView, submitButton].forEach { view.addSubview($0) }
        
        setupTableView()
        setupSubmitButton()
        
        var entryTypeRef: DatabaseReference
        
        if diaryEntryType == "Exercise" {
            entryTypeRef = ref.child("exercise")
        } else {
            entryTypeRef = ref.child("food")
        }
        
        entryTypeRef.observe(.value) { snapshot in
            var newItems: [String] = []
            self.count = snapshot.childrenCount
            print(self.count)
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let foodItem = snapshot.value as? String {
                    newItems.append(foodItem)
                }
            }
            self.items = newItems
//            print(self.items)
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let foodItem = items[indexPath.row]
        
        cell.textLabel?.text = foodItem.capitalizingFirstLetter()
        
        return cell
    }
    
    func setupTableView() {
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor,
                         bottom: nil, trailing: view.trailingAnchor,
                         size: .init(width: 0, height: view.frame.height - 150))
    }
    
    func setupSubmitButton() {
        submitButton.anchor(top: tableView.bottomAnchor, leading: view.leadingAnchor,
                         bottom: view.bottomAnchor, trailing: view.trailingAnchor,
                         size: .init(width: 0, height: 0))
    }
    
    func convertDateTimeStringToDate(datetime: String) -> Date {
        let dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        guard let date = dateFormatter.date(from: datetime) else {
            return Date()
        }
        return date
    }
    

}

extension Date {
    
    var currentUTCTimeZoneDate: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return "\(formatter.string(from: self))"
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var convertDateStringToDate: Date {
        let dateFormat = "yyyy-MM-dd"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        guard let date = dateFormatter.date(from: self) else {
            return Date()
        }
        return date
    }
    
}
