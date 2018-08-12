//
//  SecondViewController.swift
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
    
    // MARK: Outlets
    @IBOutlet weak var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thisYear = getYear(date: Date())
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // get data for the bar chart
        if let savedSpendings = loadSpendings() {
            spendings = savedSpendings
        }

        let thisYearSpending = getSpendingByMonth()
        setChart(points: months, values: thisYearSpending)
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
            
            colors.append(values[i] > 0 ? UIColor.green : values[i] < 0 ? UIColor.red : UIColor.black)
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
}

