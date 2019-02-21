//
//  ExpandableEntryController.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2019/02/20.
//  Copyright © 2019 Jose Paolo Talusan. All rights reserved.
//

import UIKit

class ExpandableEntryController: UITableViewController {
    
    let cellId = "cellId123123"

    var twoDimensionalArray = [
        ExpandableNames(isExpanded: true, names: ["Rice", "Udon", "Soba", "Katsudon", "BARGA"], header: "A"),
        ExpandableNames(isExpanded: true, names: ["Sushi", "Research", "JP", "Cho"], header: "B"),
        ExpandableNames(isExpanded: true, names: ["David", "Dan"], header: "C"),
        ExpandableNames(isExpanded: true, names: ["Patrick", "Patty"], header: "D")
    ]
    
    var showIndexPaths = false
    
    @objc func handleShowIndex() {
        print("Attempting to reload")
        
        // build all indexPaths we want to reload
        var indexPathsToReload = [IndexPath]()
        
        for section in twoDimensionalArray.indices {
            if twoDimensionalArray[section].isExpanded {
                for row in twoDimensionalArray[section].names.indices {
                    print(section, row)
                    let indexPath = IndexPath(row: row, section: section)
                    indexPathsToReload.append(indexPath)
                }
            }
        }
        
        showIndexPaths = !showIndexPaths
        let animationStyle = showIndexPaths ? UITableView.RowAnimation.right : .left
        tableView.reloadRows(at: indexPathsToReload, with: animationStyle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show Index", style: .plain, target: self, action: #selector(handleShowIndex))
        
        navigationItem.title = "Entries"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        button.setTitle("\(twoDimensionalArray[section].header) Close", for: .normal)
        button.backgroundColor = .yellow
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
        
        for row in twoDimensionalArray[section].names.indices {
            print(0, row)
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = twoDimensionalArray[section].isExpanded
        twoDimensionalArray[section].isExpanded = !isExpanded
        
        if !isExpanded {
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        let title = twoDimensionalArray[section].header
        button.setTitle(!isExpanded ? "\(title) Close" : "\(title) Open", for: .normal)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return twoDimensionalArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !twoDimensionalArray[section].isExpanded {
            return 0
        }
        return twoDimensionalArray[section].names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let name = twoDimensionalArray[indexPath.section].names[indexPath.row]
        
        cell.textLabel?.text = name
        if showIndexPaths {
            cell.textLabel?.text = "\(name) Section:\(indexPath.section) Row:\(indexPath.row)"
        }
        
        return cell
    }
}
