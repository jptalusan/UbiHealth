//
//  CheckFriendsController.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2018/08/30.
//  Copyright © 2018 Jose Paolo Talusan. All rights reserved.
//

import UIKit
import Firebase

class CheckFriendsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let usersRef = Database.database().reference(withPath: "users")
    var users: [User]! {
        didSet{
            tableView.reloadData()
        }
    }
    
//    var items: [String] = []
    
    
    var items:[String]! {
        didSet{
            tableView.reloadData()
        }
    }
    var count: UInt = 0
    let cellId = "cellId"
    
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
        print("Button press")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [tableView].forEach { view.addSubview($0) }
        setupTableView()
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
        let userID = Auth.auth().currentUser!.uid
        
        usersRef.child(userID).observe(.value, with: { snapshot in
            //            print(snapshot.value as Any)
            guard let userDict = snapshot.value as? [String: Any],
                let _ = userDict["email"] as? String,
                let name = userDict["name"] as? String else {
                    return
            }
            self.navigationItem.title = "Your Friends"
        })
        
        usersRef.observe(.value) { snapshot in
            var newItems: [String] = []
            var newUsers: [User] = []
            self.count = snapshot.childrenCount
//            print(self.count)
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                    let user = User(snapshot: snap) {
                    if user.id == userID {
                        print(user.id, userID)
                        print(user.name)
                    } else {
                        newUsers.append(user)
                        newItems.append(user.name)
                    }
                }
            }
            self.items = newItems
            self.users = newUsers
//            self.tableView.reloadData()
        }
        print(items)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(count)
        return Int(count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        print(items.count)
        print(indexPath.row)
        if (indexPath.row < items.count) {
            let user = items[indexPath.row]
            cell.textLabel?.text = user.capitalizeFirstLetter()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row: \(indexPath.row)")
        let friendID = users[indexPath.row].id
        print("id: \(friendID)")
        let personalReportController = PersonalReportController()
        PassClass.myInstance.string1 = friendID
        self.navigationController?.pushViewController(personalReportController, animated: true)
//        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
    }

    //    TODO: Highlight only 1 cell
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func setupTableView() {
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor,
                         bottom: nil, trailing: view.trailingAnchor,
                         size: .init(width: 0, height: view.frame.height))
    }
    
    func setupSubmitButton() {
        submitButton.anchor(top: tableView.bottomAnchor, leading: view.leadingAnchor,
                            bottom: view.bottomAnchor, trailing: view.trailingAnchor,
                            size: .init(width: 0, height: 0))
    }
}
