//
//  StatisticsController.swift
//  Spending
//
//  Created by Chi Yu on 7/25/18.
//  Copyright © 2018 Chi Yu. All rights reserved.
//

import UIKit
import Charts

class SecondViewController: UIViewController {
    // MARK: Properties
    var spendings: [String: [String: [Spending]]] = [:]
    var thisYear: String = ""
    
    // MARK: Constant
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let GREEN = UIColor(red:0.21, green:0.93, blue:0.36, alpha:1.0)
    let RED = UIColor(red:1.00 , green:0.41, blue:0.41, alpha:1.0)
    
    // MARK: Outlets
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var prevButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thisYear = getYear(date: Date())
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = thisYear
        
        // change navigation and tab bar color
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black

        tabBarController?.tabBar.barTintColor = UIColor.white
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.darkGray
        
        // add the button functions
        prevButton.target = self
        prevButton.action = #selector(toPrevYear)
        nextButton.target = self
        nextButton.action = #selector(toNextYear)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChart()
    }


    // load spending records
    private func loadSpendings() -> [String: [String:[Spending]]]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Spending.ArchiveURL.path) as? [String: [String:[Spending]]]
    }
    
    // get year from a date
    private func getYear(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        return df.string(from: date)
    }
    
    // get spending by month
    private func getSpendingByMonth() -> [Double] {
        var spendingArray = [Double](repeating: 0.0, count: 12)
        
        for (index, month) in months.enumerated() {
            if let _ = spendings[thisYear]?[month] {
                for spending in spendings[thisYear]![month]! {
                    spendingArray[index] += spending.money
                }
            }
        }
        return spendingArray
    }
    
    // set the chart
    private func setChart(points: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        var colors: [UIColor] = []
        
        for i in 0..<points.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
            
            colors.append(values[i] > 0 ? GREEN : values[i] < 0 ? RED : UIColor.black)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Net Income ($)")
        chartDataSet.colors = colors
        
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        // add a line at 0
        let ll = ChartLimitLine(limit: 0.0)
        ll.lineColor = UIColor.black
        ll.lineWidth = 1
        barChartView.leftAxis.addLimitLine(ll)
        
        /* chart format */
        barChartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.5, easingOption: .easeInQuad)
        
        // x-axis
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        barChartView.xAxis.granularity = 1
        
        // y-axis
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = true
        
        // others
        barChartView.chartDescription?.enabled = false
    }
    
    // update the data points for the chart
    private func updateChart() {
        if let savedSpendings = loadSpendings() {
            spendings = savedSpendings
        }
        let thisYearSpending = getSpendingByMonth()
        setChart(points: months, values: thisYearSpending)
    }
    
    // go to previous month
    @objc private func toPrevYear() {
        toYear(dir: "prev")
    }
    
    // go to the next month
    @objc private func toNextYear() {
        toYear(dir: "next")
    }
    
    // change month in the desired direction
    private func toYear(dir: String) {
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        let date = df.date(from: thisYear)!
        
        var dc = DateComponents()
        if (dir == "prev") {dc.year = -1}
        else if (dir == "next") {dc.year = 1}
        else {dc.year = 0}
        let newDate = Calendar.current.date(byAdding: dc, to: date)!

        thisYear = getYear(date: newDate)
        
        updateChart()
        self.navigationItem.title = thisYear
    }}

