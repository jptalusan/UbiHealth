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

class PersonalReportController: UIViewController {

//    let ref = Database.database().reference(withPath: "diarychoices")
    let usersRef = Database.database().reference(withPath: "users")
    var userID: String = ""
    let surveyData = ["cat": 20, "dog": 30, "both": 5, "neither": 45]
    var diaryEntries: [DiaryEntry] = []
    var foodEntriesDict = [String: Int]()
    var exerEntriesDict = [String: Int]()
    
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
    
    @objc
    func handleDietExerciseChange() {
        print(dietExerciseSegmentedControl.selectedSegmentIndex)
//        pieChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
        if dietExerciseSegmentedControl.selectedSegmentIndex == 0 {
            self.fillChart(entriesDict: self.foodEntriesDict)
        } else {
            self.fillChart(entriesDict: self.exerEntriesDict)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        userID = Auth.auth().currentUser!.uid
        
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
        view.addSubview(pieChart)
        view.addSubview(dietExerciseSegmentedControl)
        setupPieChart()
        setupDietExerciseSegmentedControl()
        setupTitleLabel()
        getEntriesFromDB()
        
        let diaryEntryRef = usersRef.child(userID).child("diary_entries")
        
        diaryEntryRef.observe(.value, with: { snapshot in
            self.getEntriesFromDB()
        })
    }
    
    func setupTitleLabel() {
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -100, right: 0), size: .init(width: 0, height: 0))
    }
    
    func setupPieChart() {
        pieChart.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        pieChart.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        pieChart.anchor(top: titleLabel.bottomAnchor, leading: view.leadingAnchor, bottom: dietExerciseSegmentedControl.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -8, right: 0))
    }
    
    func setupDietExerciseSegmentedControl() {
        dietExerciseSegmentedControl.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 8, left: 8, bottom: -8, right: -8), size: .init(width: 0, height: 50))
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
        chartDataSet.valueTextColor = .black
        var colors: [UIColor] = []
        for _ in 0..<entriesDict.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)

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
        let startAndEndDates = Date().currentWeeksStartAndEnd
        let startDate = startAndEndDates[0]
        let endDate = startAndEndDates[1]
        let diaryEntryRef = usersRef.child(userID).child("diary_entries")
        
        diaryEntryRef.observe(.value, with: { snapshot in
            var diaryEntries: [DiaryEntry] = []
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let childDate = snap.key.convertDateTimeStringToDate
                if (childDate.compare(startDate) == ComparisonResult.orderedDescending &&
                    childDate.compare(endDate) == ComparisonResult.orderedAscending) {
                    for snapChild in snap.children {
                        if let snapChildSnap = snapChild as? DataSnapshot,
                            let diaryEntry = DiaryEntry(date: childDate, snapshot: snapChildSnap) {
                            diaryEntries.append(diaryEntry)
                        }
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
            self.foodEntriesDict = foodEntryArray.freq()
            self.exerEntriesDict = exerciseEntryArray.freq()
            
            if self.dietExerciseSegmentedControl.selectedSegmentIndex == 0 {
                self.fillChart(entriesDict: self.foodEntriesDict)
            } else {
                self.fillChart(entriesDict: self.exerEntriesDict)
            }
        })
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
