//
//  SuggestionController.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2018/08/30.
//  Copyright © 2018 Jose Paolo Talusan. All rights reserved.
//
import UIKit
import Firebase
//TODO: This should be in the check friends page
class SuggestionController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let usersRef = Database.database().reference(withPath: "users")
    let suggestionsRef = Database.database().reference(withPath: "suggestions")
    
    var items: [String] = []
    var count: UInt = 0
    let cellId = "cellId"
    var diaryEntryType: String = ""
    var friendUserID = ""
    
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
        button.setTitle("Submit suggestions", for: .normal)
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
        guard let selectedIndexes = tableView.indexPathsForSelectedRows else {
            showAlertError(title: "Error getting selected rows", "Please select an entry.")
            return
        }
        
        var itemCSV: String = ""
        for index in selectedIndexes {
            itemCSV += "\(items[index.row]);"
        }
        let output = itemCSV.dropLast()
        print(output)
        
        //Use as key
        let currentDateTime = Date()
        let currentDateTimeString = currentDateTime.currentUTCDateTimeToString
        
        let datetimeStringArray = currentDateTimeString.components(separatedBy: " ")
        
        let dateString = datetimeStringArray[0] + " 00:00:00 +0000" //"2018-03-15 21:05:04 +0000"
        let timeString = datetimeStringArray[1] + " " + datetimeStringArray[2]
        
        let currentUserId = Auth.auth().currentUser!.uid
        
        //TODO Check if entry exists for the day and ask if want to overwrite
        let diaryEntryRef = usersRef.child(friendUserID).child("suggestions").child(dateString)
        
        diaryEntryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("observerSingleEvent")
            
            if snapshot.hasChild(currentUserId) {
                let entries = snapshot.value as! [String:AnyObject]
                print(entries)
                
                //TODO: Ask if want to overwrite prior entry
                print("Suggestion already given this day")
                //                if let entry = entries["entry"],
                //                    let time = entries["time"] as? String {
                //                    let entryStr = entry as! String
                //
                //                    let date = String(dateString.split(separator: " ")[0])
                //                    let datetime = date + " " + time
                //                    self.showAlertError(title: "Duplicate entry detected.", "You entered: \(entryStr.capitalizeFirstLetter()) on \(datetime.UTCStringToLocalString)")
                //                    return
                //                }
            } else {
                let values = [//"type": diaryEntryType as String,
                    "suggested": String(output),
                    "time": timeString]
                diaryEntryRef.child(currentUserId).updateChildValues(values) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [tableView, submitButton].forEach { view.addSubview($0) }
        
        setupTableView()
        setupSubmitButton()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        friendUserID = PassClass.myInstance.string1
        
        usersRef.child(friendUserID).observe(.value, with: { snapshot in
            print(snapshot.value as Any)
            guard let userDict = snapshot.value as? [String: Any],
                let _ = userDict["email"] as? String,
                let name = userDict["name"] as? String else {
                    return
            }
            self.navigationItem.title = "Suggestions for \(name)"
        })
        
        suggestionsRef.child("suggest").observe(.value) { snapshot in
            var newItems: [String] = []
            self.count = snapshot.childrenCount
            print(self.count)
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                    let suggestItem = snapshot.value as? String {
                    newItems.append(suggestItem)
                }
            }
            self.items = newItems
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let foodItem = items[indexPath.row]
        
        cell.textLabel?.text = foodItem.capitalizeFirstLetter()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    //    TODO: Highlight only 1 cell
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
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
