//
//  PersonalReportController.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2018/08/30.
//  Copyright © 2018 Jose Paolo Talusan. All rights reserved.
//

import UIKit
import Firebase
import Charts

class PersonalReportController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dietExerciseSegmentedControl.selectedSegmentIndex == 0 {
            return foodTableViewList.count
        } else {
            return exerTableViewList.count
        }
    }
    
    var newFoodDict: [String : Int] = [String : Int]()
    var newExerDict: [String : Int] = [String : Int]()
    let cellId = "cellId"
//    let ref = Database.database().reference(withPath: "diarychoices")
    let usersRef = Database.database().reference(withPath: "users")
    var userID: String = ""
    let surveyData = ["cat": 20, "dog": 30, "both": 5, "neither": 45]
    var diaryEntries: [DiaryEntry] = []
    var foodEntriesDict = [String: Int]()
    var exerEntriesDict = [String: Int]()
    var isThisCurrentUser = false
    var colors: [UIColor] = []
    var foodTableViewList: [String] = []
    
    var exerTableViewList: [String] = []
    
    let titleLabel: UILabel = {
        let label = UILabel()
        //        label.backgroundColor = UIColor(r: 80, g: 101, b:161)
        label.text = "Week"
        //        label.text = "+"
        label.textAlignment = .center
        label.font = label.font.withSize(30)
        label.font = .boldSystemFont(ofSize: 20.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.bounces = false
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        return tableView
    }()
    
    lazy var pieChart: PieChartView = {
        let p = PieChartView()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.noDataText = "No data to display"
        p.legend.enabled = true
        p.chartDescription?.text = ""
        p.legend.textColor = .white
        p.legend.textHeightMax = 20
        p.legend.font = UIFont(name: "HelveticaNeue-Light", size: 16.0)!
        p.legend.formSize = 15
        p.entryLabelFont = UIFont(name: "HelveticaNeue-Light", size: 16.0)!
        p.entryLabelColor = .black
        p.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        p.drawHoleEnabled = false
        p.drawSlicesUnderHoleEnabled = true
        p.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        p.delegate = self
        return p
    }()
    
    lazy var dietExerciseSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Diet", "Exercise"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        sc.selectedSegmentIndex = 0
        sc.layer.cornerRadius = 5
        sc.addTarget(self, action: #selector(handleDietExerciseChange), for: .valueChanged)
        return sc
    }()
    
    lazy var suggestionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        button.setTitle("Suggestions", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleSuggestion), for: .touchUpInside)
        return button
    }()
    
    @objc
    func handleSuggestion() {
        print("Suggestions!!!")
        let suggestionController = SuggestionController()
        PassClass.myInstance.string1 = userID
        self.navigationController?.pushViewController(suggestionController, animated: true)
    }
    @objc
    func handleDietExerciseChange() {
        print(dietExerciseSegmentedControl.selectedSegmentIndex)
//        pieChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        if dietExerciseSegmentedControl.selectedSegmentIndex == 0 {
//            self.fillChart(entriesDict: self.foodEntriesDict)
//            self.foodTableViewList = self.newFoodDict.map{ "\($0.key) \($0.value)" }
        } else {
//            self.fillChart(entriesDict: self.exerEntriesDict)
            print("EXER BUTTON")
//            self.foodTableViewList = self.newExerDict.map{ "\($0.key) \($0.value)" }
        }
        print(self.foodTableViewList)
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        let currentUserID = Auth.auth().currentUser!.uid
        let diaryEntryType = PassClass.myInstance.string1
        userID = diaryEntryType
        
        usersRef.child(userID).observeSingleEvent(of: .value, with: { snapshot in
//            print(snapshot.value as Any)
            guard let userDict = snapshot.value as? [String: Any],
                let _ = userDict["email"] as? String,
                let name = userDict["name"] as? String else {
                    return
            }
            self.navigationItem.title = "\(name)'s Personal Report"
        })
        
        view.addSubview(titleLabel)
//        view.addSubview(pieChart)
        view.addSubview(tableView)
        view.addSubview(dietExerciseSegmentedControl)
        if (currentUserID != userID) {
            view.addSubview(suggestionButton)
            setupSuggestionButton()
            isThisCurrentUser = false
        } else {
            isThisCurrentUser = true
        }
//        setupPieChart()
        setupDietExerciseSegmentedControl()
        setupTitleLabel()
        getEntriesFromDB()
        
        let diaryEntryRef = usersRef.child(userID).child("diary_entries")
        
        diaryEntryRef.observe(.value, with: { snapshot in
            self.getEntriesFromDB()
        })
        setupTableView()
    }
    
    func setupTitleLabel() {
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: tableView.topAnchor, trailing: view.trailingAnchor, padding: .init(top: -10, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 0))
    }
    
    func setupTableView() {
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        if (isThisCurrentUser) {
            tableView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -8, right: 0), size: .init(width: 0, height: view.frame.height - 100))
        } else {
            tableView.anchor(top: nil, leading: view.leadingAnchor, bottom: dietExerciseSegmentedControl.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -8, right: 0), size: .init(width: 0, height: view.frame.height - 150))
        }
    }
    func setupPieChart() {
        pieChart.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        pieChart.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        pieChart.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -8, right: 0), size: .init(width: 0, height: view.frame.height - 100))
    }
    
    func setupDietExerciseSegmentedControl() {
        if (isThisCurrentUser) {
            dietExerciseSegmentedControl.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 8, left: 8, bottom: -8, right: -8), size: .init(width: 20, height: 50))
        } else {
            dietExerciseSegmentedControl.anchor(top: nil, leading: view.leadingAnchor, bottom: suggestionButton.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 8, left: 8, bottom: -8, right: -8), size: .init(width: 0, height: 50))
        }

    }
    
    func setupSuggestionButton() {
        suggestionButton.anchor(top: nil, leading: view.leadingAnchor,
                                bottom: view.bottomAnchor, trailing: view.trailingAnchor,
                                padding: .init(top: 8, left: 8, bottom: -8, right: -8), size: .init(width: 0, height: 200))
    }
    
    func fillChart(entriesDict: [String: Int]) {
        var dataEntries: [PieChartDataEntry] = []
        var sum = 0
        for value in entriesDict.values {
            sum += value
        }
        
        for (key, val) in entriesDict {
            print(key, val)
            let percent = Double(val) / Double(sum)
            let entry = PieChartDataEntry(value: percent, label: key.capitalizeFirstLetter())
            dataEntries.append(entry)
        }
        
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        
        chartDataSet.sliceSpace = 2
        chartDataSet.selectionShift = 10
        chartDataSet.valueTextColor = .white
        
        if (colors.count == 0) {
            for _ in 0..<entriesDict.count {
                let red = Double(arc4random_uniform(256))
                let green = Double(arc4random_uniform(256))
                let blue = Double(arc4random_uniform(256))
                
                let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                colors.append(color)
            }
            chartDataSet.colors = colors
        } else {
            chartDataSet.colors = colors
        }
        
        
        let chartData = PieChartData(dataSet: chartDataSet)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        chartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        pieChart.data = chartData
    }
    
    func getEntriesFromDB() {
        let diaryEntryRef = usersRef.child(userID).child("diary_entries")
        
        //Firebase is asynchronous
//        let lastWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
//        let startOfLastWeek = lastWeekDate.startOfWeek
//        let endOfLastWeek = lastWeekDate.endOfWeek
        
//        let start = startOfLastWeek?.strippedTime(time: "00:00:00 +0000")
//        let end = endOfLastWeek?.strippedTime(time: "23:59:59 +0000")
        
//        self.titleLabel.text = (startOfLastWeek?.dateString)! + " to " + (endOfLastWeek?.dateString)!
        
        diaryEntryRef.observe(.value, with: { snapshot in
            var diaryEntries: [DiaryEntry] = []
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let childDate = snap.key.convertDateTimeStringToDate
                for snapChild in snap.children {
                    if let snapChildSnap = snapChild as? DataSnapshot,
                        let diaryEntry = DiaryEntry(date: childDate, snapshot: snapChildSnap) {
                       
                       
                            diaryEntries.append(diaryEntry)
                      //  }
                        
//                        if ((diaryEntry.date >= start!) && (diaryEntry.date <= end!)) {
//                            diaryEntries.append(diaryEntry)
//                        }
                    }
                }
            }
            self.diaryEntries = diaryEntries
            var foodEntryArray: [String] = []
            var exerciseEntryArray: [String] = []

            for entry in self.diaryEntries {
                //Assume that the entries here fall into the requested week (but we should still check (TODO))
                let entryArray = entry.entry.split(separator: ";")
                print(entryArray)
                if entry.key != "Exercise" {
                    entryArray.forEach { foodEntryArray.append(String($0)) }
                } else {
                    entryArray.forEach { exerciseEntryArray.append(String($0)) }
                }
            }
            
            print("foodEntryArray", foodEntryArray)
            print("exerciseEntryArray", exerciseEntryArray)
//            Only need to change here for new code
            
//            self.foodEntriesDict = foodEntryArray.freq()
//            self.exerEntriesDict = exerciseEntryArray.freq()
            self.newFoodDict = [String : Int]()
            self.newExerDict = [String : Int]()
            
            for foodEntry in foodEntryArray {
                let tempArr = foodEntry.split(separator: "-")
                let foodName = String(tempArr[0])
                let quantity = Int(tempArr[1])
                if let val = self.newFoodDict[foodName] {
                    self.newFoodDict[foodName] = val + quantity!
                } else {
                    self.newFoodDict[foodName] = quantity!
                }
                foodEntryArray = foodEntryArray.filter{$0 != foodEntry}
            }
            
            self.foodTableViewList = self.newFoodDict.map{ "\($0.key) \($0.value)" }
            
            for exerEntry in exerciseEntryArray {
                let tempArr = exerEntry.split(separator: "-")
                let exerName = String(tempArr[0])
                let quantity = Int(tempArr[1])
                if let val = self.newExerDict[exerName] {
                    self.newExerDict[exerName] = val + quantity!
                } else {
                    self.newExerDict[exerName] = quantity!
                }
                exerciseEntryArray = exerciseEntryArray.filter{$0 != exerEntry}
            }
            
            self.exerTableViewList = self.newExerDict.map{ "\($0.key) \($0.value)" }
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        if dietExerciseSegmentedControl.selectedSegmentIndex == 0 {
            var entryArr = foodTableViewList[indexPath.row].split(separator: " ")
            print("Entry ARR: \(entryArr)")
            let amount = entryArr.removeLast()
            let entryLabel = entryArr.joined(separator: " ")

            var suffix = FoodServingSuffix[entryLabel]
            if Int(String(amount))! > 1 {
                suffix = suffix! + "s"
            }
            cell.textLabel?.text = entryLabel.camelCapital()
            cell.detailTextLabel?.text = "\(amount) \(suffix!)"
        } else {
            var entryArr = exerTableViewList[indexPath.row].split(separator: " ")
            print("Entry ARR: \(entryArr)")
            let amount = entryArr.removeLast()
            let entryLabel = entryArr.joined(separator: " ")
            
            let suffix = "minutes"
            cell.textLabel?.text = entryLabel.camelCapital()
            cell.detailTextLabel?.text = "\(amount) \(suffix)"
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
}

func matches(for regex: String, in text: String) -> [String] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

extension Sequence where Self.Iterator.Element: Hashable {
    func freq() -> [Self.Iterator.Element: Int] {
        return reduce([:]) {
            ( accu: [Self.Iterator.Element: Int], element) in
            var accu2 = accu
            accu2[element] = (accu2[element] ?? 0) + 1
            return accu2
        }
    }
}

class SubtitleTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

