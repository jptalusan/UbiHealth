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
    var suggestions: [Suggestion] = []
    
    fileprivate func showAlertError(title: String, _ error: String) {
        let alert = UIAlertController(title: title,
                                      message: error,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        //        label.backgroundColor = UIColor(r: 80, g: 101, b:161)
//        label.text = "Week"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        let currentUserId = Auth.auth().currentUser!.uid
        
        self.navigationItem.title = "Friends' Suggestions"
        //Firebase is asynchronous
        let lastWeekDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!
        let startOfLastWeek = lastWeekDate.startOfWeek
        let endOfLastWeek = lastWeekDate.endOfWeek
        
        let start = startOfLastWeek?.strippedTime(time: "00:00:00 +0000")
        let end = endOfLastWeek?.strippedTime(time: "23:59:59 +0000")
        
        self.titleLabel.text = (startOfLastWeek?.dateString)! + " to " + (endOfLastWeek?.dateString)!
        
        usersRef.child(currentUserId).child("suggestions").observe(.value) { snapshot in
            self.count = snapshot.childrenCount
            var newSuggestions: [Suggestion] = []
//            print(self.count)
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let childDate = snap.key.convertDateTimeStringToDate
                //TODO: Check if the suggestions fall within the previous week.
                for snapChild in snap.children {
                    if let snapChildSnap = snapChild as? DataSnapshot,
                        let suggestion = Suggestion(date: childDate, snapshot: snapChildSnap) {
//                        print(suggestion.date)
//                        print(start as Any)
//                        print(end as Any)
                        if ((suggestion.date >= start!) && (suggestion.date <= end!)) {
//                            print("Yes it is within this week!")
//                            print(suggestion.suggested)
                            newSuggestions.append(suggestion)
                        }
                    }
                }
            }
            self.suggestions = newSuggestions
            var suggestedArray: [String] = []
            for suggestion in self.suggestions {
                let suggestionArray = suggestion.suggested.split(separator: ";")
                print(suggestionArray)
                suggestionArray.forEach { suggestedArray.append(String($0)) }
            }
            self.suggestionsDict = suggestedArray.freq()
            self.fillChart(entriesDict: self.suggestionsDict)
        }
        //        TODO: Parse the data and tally it and then show pie chart
        view.addSubview(titleLabel)
        view.addSubview(pieChart)
        setupPieChart()
        setupTitleLabel()
    }
    
    func setupTitleLabel() {
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: pieChart.topAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 50))
    }
    
    func setupPieChart() {
        pieChart.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        pieChart.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        pieChart.anchor(top: titleLabel.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 0))
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
}

