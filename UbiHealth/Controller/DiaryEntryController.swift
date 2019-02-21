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
    
    var twoDimensionItemArray: [ExpandableNames] = []
    
    var selectedItems: [Int : Int] = [Int : Int]()
    
    var showIndexPaths = false
    
    @objc func handleShowIndex() {
        print("Attempting to reload")
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FoodItemClass.self, forCellReuseIdentifier: cellId)
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
    
    fileprivate func showAlertError(title: String, _ error: String) {
        let alert = UIAlertController(title: title,
                                      message: error,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc
    func handleSubmit() {
//        guard let selectedIndexes = tableView.indexPathsForSelectedRows else {
        if selectedItems.count == 0 {
            showAlertError(title: "Sorry! No Items Selected", "Please select an entry.")
            return
        }
        
        var itemCSV: String = ""
        for (section, row) in selectedItems {
            let foodItem = twoDimensionItemArray[section].header
            let foodQuantity = twoDimensionItemArray[section].names[row].split(separator: " ")[0]
            print("You ate \(foodQuantity) of \(foodItem)")
            itemCSV += "\(foodItem)-\(foodQuantity);"
        }
        
        let output = itemCSV.dropLast()
        print(output)

//        //Use as key
        let currentDateTime = Date()
        let currentDateTimeString = currentDateTime.currentUTCDateTimeToString

        let datetimeStringArray = currentDateTimeString.components(separatedBy: " ")

        let dateString = datetimeStringArray[0] + " 00:00:00 +0000" //"2018-03-15 21:05:04 +0000"
        let timeString = datetimeStringArray[1] + " " + datetimeStringArray[2]

        let userID = Auth.auth().currentUser!.uid

        //TODO Check if entry exists for the day and ask if want to overwrite
        let diaryEntryRef = usersRef.child(userID).child("diary_entries").child(dateString).child(diaryEntryType)

        diaryEntryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("observerSingleEvent")

            if snapshot.hasChild("entry") && snapshot.hasChild("time") {
                var entries = snapshot.value as! [String:AnyObject]
                print(entries)

                //TODO: Ask if want to overwrite prior entry
                print("Entry already exists")
                if let entry = entries["entry"],
                    let time = entries["time"] as? String {
                    let entryStr = entry as! String
//                    THIS IS FOR DEBUGGING
                    let newentry = entryStr + ";" + String(output)
                    let values = [//"type": diaryEntryType as String,
                        "entry": newentry,
                        "time": timeString]
                    diaryEntryRef.updateChildValues(values) {
                        error, ref in
                        if error != nil {
                            print(error!.localizedDescription)
                            self.showAlertError(title: "Error inserting data", error!.localizedDescription)
                            return
                        }
                        print("Saved successfully into firebase")
                        self.navigationController?.popViewController(animated: true)
                    }
//                    let date = String(dateString.split(separator: " ")[0])
//                    let datetime = date + " " + time
//                    self.showAlertError(title: "Oops!", "You have already submitted this entry for today -> \(entryStr.capitalizeFirstLetter()) at \(datetime.UTCStringToLocalString)")
                    return
                }
            }

            else {
                let values = [//"type": diaryEntryType as String,
                              "entry": String(output),
                              "time": timeString]
                diaryEntryRef.updateChildValues(values) {
                    error, ref in
                    if error != nil {
                        print(error!.localizedDescription)
                        self.showAlertError(title: "Error inserting data", error!.localizedDescription)
                        return
                    }
                    print("Saved successfully into firebase")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        button.setTitle("   \(twoDimensionItemArray[section].header.camelCapital()) +", for: .normal)
        
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.contentHorizontalAlignment = .leading
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleExpandClose), for: .touchUpInside)
        button.tag = section
        return button
    }
    
    @objc func handleExpandClose(button: UIButton) {
        print("Trying to expand")
        let section = button.tag
        var indexPaths = [IndexPath]()

        for row in twoDimensionItemArray[section].names.indices {
            print(0, row)
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }

        let isExpanded = twoDimensionItemArray[section].isExpanded
        twoDimensionItemArray[section].isExpanded = !isExpanded

        if !isExpanded {
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        let title = twoDimensionItemArray[section].header
        button.setTitle(!isExpanded ? "   \(title.camelCapital()) -" : "   \(title.camelCapital()) +", for: .normal)
    }
    
    override func viewDidLoad() {
        //TODO: Check if date and entry exists, if so, grey out or have some indicator that it's filled up
        super.viewDidLoad()
        
        diaryEntryType = PassClass.myInstance.string1
        print(diaryEntryType)
        
        navigationItem.title = "\(diaryEntryType) Diary Entry"
        
        
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
            
            for item in self.items {
                //                print(FoodServingDict[item])
                let en = ExpandableNames(isExpanded: false, names: FoodServingDict[item] ?? ["30 minutes", "60 minutes", "90 minutes", "120 minutes"], header: item)
                self.twoDimensionItemArray.append(en)
            }
            
            self.tableView.reloadData()
            
        }
        
        [tableView, submitButton].forEach { view.addSubview($0) }
        
        setupTableView()
        setupSubmitButton()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return twoDimensionItemArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !twoDimensionItemArray[section].isExpanded {
            return 0
        }
        return twoDimensionItemArray[section].names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! FoodItemClass
        cell.link = self
        if twoDimensionItemArray.count != 0 {
            if twoDimensionItemArray[indexPath.section].isExpanded {
                let foodItem = twoDimensionItemArray[indexPath.section].names[indexPath.row]
                cell.textLabel?.text = foodItem.capitalizeFirstLetter()
                cell.detailTextLabel?.text = "-"
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selectedItems.removeValue(forKey: indexPath.section)
        print("This cell was selected and now deselected: \(indexPath.section), \(indexPath.row)")
        let cell = tableView.cellForRow(at: indexPath)
        cell?.detailTextLabel?.text = "-"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let selected_row = indexPath.row
        selectedItems[section] = selected_row
        print(selectedItems)
        for row in twoDimensionItemArray[section].names.indices {
            if row != selected_row {
                let indexPath = IndexPath(row: row, section: section)
                tableView.deselectRow(at: indexPath, animated: false)
                let cell = tableView.cellForRow(at: indexPath)
                cell?.detailTextLabel?.text = "-"
            }
        }
        let cell = tableView.cellForRow(at: indexPath)
        cell?.detailTextLabel?.text = "+"
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
}
