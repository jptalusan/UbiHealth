//
//  SuggestionsForYouController.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2018/10/24.
//  Copyright © 2018 Jose Paolo Talusan. All rights reserved.
//

import UIKit
import Firebase
import Charts

//TODO: Need to gather all data inside suggestions, for the week.
//Tally all the same data, I think i can use the same setup as the personalreport controller.
class SuggestionsForYouController: UIViewController {
    
    let usersRef = Database.database().reference(withPath: "users")
    
    var items: [String] = []
    var count: UInt = 0
    let cellId = "cellId"
    var diaryEntryType: String = ""
    
    var suggestionsDict = [String: Int]()
    var colors: [UIColor] = []
    
    fileprivate func showAlertError(title: String, _ error: String) {
        let alert = UIAlertController(title: title,
                                      message: error,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        let currentUserId = Auth.auth().currentUser!.uid
        
        self.navigationItem.title = "Friends' Suggestions"
        
        //Firebase is asynchronous
        usersRef.child(currentUserId).child("suggestions").observe(.value) { snapshot in
            self.count = snapshot.childrenCount
            print(self.count)
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let childDate = snap.key.convertDateTimeStringToDate
                for snapChild in snap.children {
                    if let snapChildSnap = snapChild as? DataSnapshot,
                        let suggestion = Suggestion(date: childDate, snapshot: snapChildSnap) {
                        print(suggestion.suggested)
                        self.usersRef.child(suggestion.key).observe(.value, with: { snapshot in
                            guard let userDict = snapshot.value as? [String: Any],
                                let _ = userDict["email"] as? String,
                                let name = userDict["name"] as? String else {
                                    return
                            }
                            print("Suggested by: " + name)
                        })
                        
                        print("At" + suggestion.time + " on: ")
                        print(suggestion.date)
                    }
                }
            }
        }
        //        TODO: Parse the data and tally it and then show pie chart
        view.addSubview(pieChart)
        setupPieChart()
        
    }
    
    func setupPieChart() {
//        pieChart.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
//        pieChart.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        pieChart.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 0))
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
//        let startAndEndDates = Date().currentWeeksStartAndEnd
//        let startDate = startAndEndDates[0]
//        let endDate = startAndEndDates[1]
//        let diaryEntryRef = usersRef.child(userID).child("diary_entries")
//
//        diaryEntryRef.observe(.value, with: { snapshot in
//            var diaryEntries: [DiaryEntry] = []
//            for child in snapshot.children {
//                let snap = child as! DataSnapshot
//                let childDate = snap.key.convertDateTimeStringToDate
//                //                TODO: only show a week's worth.
//                /*
//                 Oct 8: I check the friend's list
//                 I will be shown data from oct 1-7.
//
//                 Oct 9-13: Same behavior, show Oct 1-7
//                 OCt 14: Show Oct 8-13...
//
//                 */
//                if (childDate.compare(startDate) == ComparisonResult.orderedDescending &&
//                    childDate.compare(endDate) == ComparisonResult.orderedAscending) {
//                    for snapChild in snap.children {
//                        if let snapChildSnap = snapChild as? DataSnapshot,
//                            let diaryEntry = DiaryEntry(date: childDate, snapshot: snapChildSnap) {
//                            diaryEntries.append(diaryEntry)
//                        }
//                    }
//                }
//            }
//            self.diaryEntries = diaryEntries
//            var foodEntryArray: [String] = []
//            var exerciseEntryArray: [String] = []
//
//            for entry in self.diaryEntries {
//                //Assume that the entries here fall into the requested week (but we should still check (TODO))
//                let entryArray = entry.entry.split(separator: ";")
//                print(entryArray)
//                if entry.key != "Exercise" {
//                    entryArray.forEach { foodEntryArray.append(String($0)) }
//                } else {
//                    entryArray.forEach { exerciseEntryArray.append(String($0)) }
//                }
//            }
//            self.foodEntriesDict = foodEntryArray.freq()
//            self.exerEntriesDict = exerciseEntryArray.freq()
//
//            if self.dietExerciseSegmentedControl.selectedSegmentIndex == 0 {
//                self.fillChart(entriesDict: self.foodEntriesDict)
//            } else {
//                self.fillChart(entriesDict: self.exerEntriesDict)
//            }
//        })
    }
}
