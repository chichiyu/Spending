//
//  SpendingTableViewController.swift
//  Spending
//
//  Created by Chi Yu on 8/3/18.
//  Copyright © 2018 Chi Yu. All rights reserved.
//

import UIKit

class SpendingTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Properties
    var spendings: [String: [String: [Spending]]] = [:]
    var thisMonth: String = ""
    var thisYear: String = ""
    var thisMonthYear: String = ""
    
    // MARK: constants
    let GREEN = UIColor(red:0.21, green:0.93, blue:0.36, alpha:1.0)
    let RED = UIColor(red:0.93, green:0.26, blue:0.21, alpha:1.0)
    let DARKBLUE = UIColor(red:0.16, green:0.36, blue:0.94, alpha:1.0)
    let BLUE = UIColor(red:0.61, green:0.80, blue:1.00, alpha:1.0)
    
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var prevMonth: UIButton!
    @IBOutlet weak var nextMonth: UIButton!
    @IBOutlet weak var income: UILabel!
    @IBOutlet weak var spent: UILabel!
    @IBOutlet weak var netChange: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style:.plain, target: self, action: #selector(editButtonTapped))

        // change navigation and tab bar color
        navigationController?.navigationBar.barTintColor = BLUE
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        
        tabBarController?.tabBar.barTintColor = BLUE
        tabBarController?.tabBar.tintColor = DARKBLUE
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.darkGray

        tableView.dataSource = self
        tableView.delegate = self

        // set the constants
        thisMonth = getDate(component: "month", date: Date())
        thisYear = getDate(component: "year", date: Date())
        thisMonthYear = getDate(component: "monthYear", date: Date())
        
        // set the title
        self.title = thisMonthYear
        
        // add the button functions
        prevMonth.addTarget(self, action: #selector(toPrevMonth), for: .touchUpInside)
        nextMonth.addTarget(self, action: #selector(toNextMonth), for: .touchUpInside)
        
        // Load the data
        if let savedSpendings = loadSpendings() {
            spendings = savedSpendings
        } else {
            loadSampleSpendings()
        }
    
        // Calculate the totals
        calculateTotal()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows")
        print(spendings[thisYear]?[thisMonth]?.count ?? 0)
        return spendings[thisYear]?[thisMonth]?.count ?? 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SpendingTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SpendingTableViewCell else {
            fatalError("The dequeued cell is not an instance of SpendingTableViewCell")
        }

        let spending = spendings[thisYear]![thisMonth]![indexPath.row]
        
        // converts the date to a string
        
        cell.dateLabel.text = getDate(component: "full", date: spending.date)
        cell.descriptionLabel.text = spending.descript
        cell.moneyLabel.text = printMoney(money: spending.money)
        cell.moneyLabel.textColor = getColor(money: spending.money)

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            spendings[thisYear]![thisMonth]!.remove(at: indexPath.row)
            saveSpendings()
            tableView.deleteRows(at: [indexPath], with: .fade)
            calculateTotal()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "ShowDetail":
            let spendingDetailViewController = segue.destination as! SpendingViewController
            let selectedSpendingCell = sender as! SpendingTableViewCell
            let indexPath = tableView.indexPath(for: selectedSpendingCell)
            
            let selectedSpending = spendings[thisYear]![thisMonth]![indexPath!.row]
            spendingDetailViewController.spending = selectedSpending
        default:
            return
        }
    }
    
    
    // MARK: Private functions
    private func loadSampleSpendings() {
        let spending1 = Spending(date: Date(), descript: "Got robbed..", money: -300, type: "Food")
        
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        let date2 = df.date(from: "2018/07/27")
        let spending2 = Spending(date: date2!, descript: "Paycheck", money: 0.01, type: "Food")
        
        _ = addSpending(spending: spending1)
        _ = addSpending(spending: spending2)
    }
    
    // calculate the total spending and income for current month
    private func calculateTotal() {
        var totalSpending = 0.0
        var totalIncome = 0.0
        var netDifference = 0.0
        
        if let _ = spendings[thisYear]?[thisMonth] {
            for spending in spendings[thisYear]![thisMonth]! {
                if (spending.money > 0)  {totalIncome += spending.money}
                else {totalSpending += spending.money}
            }
            
            netDifference = totalIncome + totalSpending
        }
        
        income.text = printMoney(money: totalIncome)
        income.textColor = getColor(money: totalIncome)
        
        spent.text = printMoney(money: totalSpending)
        spent.textColor = getColor(money: totalSpending)
        
        netChange.text = printMoney(money: netDifference)
        netChange.textColor = getColor(money: netDifference)
        
    }
    
    // print the money in proper format
    private func printMoney(money: Double) -> String {
        if money >= 0 {
            return "$" + String(format:"%.2f", money)
        } else {
            return "-$" + String(format:"%.2f", -money)
        }
    }
    
    // selects red or green based on the value of money
    private func getColor(money: Double) -> UIColor {
        if money > 0 {
            return GREEN
        } else if money < 0 {
            return RED
        } else {
            return UIColor.black
        }
    }
    
    // return components of a date as a String
    private func getDate(component: String, date: Date) -> String {
        let df = DateFormatter()
        switch component {
        case "year": df.dateFormat = "yyyy"
        case "month": df.dateFormat = "LLL"
        case "monthYear": df.dateFormat = "MMM yyyy"
        case "day": df.dateFormat = "d"
        case "full": df.dateFormat = "yyyy-MM-dd"
        default: return ""
        }

        return df.string(from: date)
    }
    
    private func inThisMonth(date: Date) -> Bool {
        return getDate(component: "monthYear", date: date) == thisMonthYear
    }
    
    // add a spending to spendings
    private func addSpending(spending: Spending) -> Int {
        let date = spending.date
        let year = getDate(component: "year", date: date)
        let month = getDate(component: "month", date: date)
        var index = -1
        
        if let _ = spendings[year]?[month] {
            
            // find the index to add using binary search
            var lo = 0
            var hi = spendings[year]![month]!.count - 1
            
            while lo <= hi {
                let mid = (lo + hi) / 2
                if spendings[year]![month]![mid].date < spending.date {
                    lo = mid + 1
                } else if spendings[year]![month]![mid].date > spending.date {
                    hi = mid - 1
                } else {
                    index = mid
                    while index < spendings[year]![month]!.count && spendings[year]![month]![index].date == spending.date {
                        index += 1
                    }
                    break
                }
            }
            
            if index == -1 {index = lo}
            spendings[year]![month]!.insert(spending, at: index)
            
        } else if let _ = spendings[year] {
            spendings[year]![month] = [spending]
            index = 0
        } else {
            spendings[year] = [month: [spending]]
            index = 0
        }

        print(spendings)
        print("New Spending:")
        print(spending.date)
        print(spending.descript)
        print(spending.money)
        
        return index
    }

    // saves spending records
    private func saveSpendings() {
        NSKeyedArchiver.archiveRootObject(spendings, toFile: Spending.ArchiveURL.path)
    }
    
    // load spending records
    private func loadSpendings() -> [String: [String:[Spending]]]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Spending.ArchiveURL.path) as? [String: [String:[Spending]]]
    }
    
    // switch in and out of edit mode
    @objc private func editButtonTapped() {
        if (self.tableView.isEditing) {
            self.tableView.isEditing = false
            self.navigationItem.leftBarButtonItem?.title = "Edit"
        } else {
            self.tableView.isEditing = true
            self.navigationItem.leftBarButtonItem?.title = "Done"
        }
    }
    
    // go to previous month
    @objc private func toPrevMonth() {
        toMonth(dir: "prev")
    }
    
    // go to the next month
    @objc private func toNextMonth() {
        toMonth(dir: "next")
    }
    
    // change month in the desired direction
    private func toMonth(dir: String) {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        let date = df.date(from: thisMonthYear)!
        
        var dc = DateComponents()
        if (dir == "prev") {dc.month = -1}
        else if (dir == "next") {dc.month = 1}
        else {dc.month = 0}
        let newDate = Calendar.current.date(byAdding: dc, to: date)!
        
        thisMonth = getDate(component: "month", date: newDate)
        thisYear = getDate(component: "year", date: newDate)
        thisMonthYear = getDate(component: "monthYear", date: newDate)
        
        tableView.reloadData()
        self.title = thisMonthYear
        calculateTotal()
    }
    
    // MARK: actions
    @IBAction func unwindToSpendingList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SpendingViewController, let spending = sourceViewController.spending {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    spendings[thisYear]![thisMonth]!.remove(at: selectedIndexPath.row)
                    tableView.deleteRows(at: [selectedIndexPath], with: .none)
                    let index = addSpending(spending: spending)
                if (inThisMonth(date: spending.date)) {
                    let newIndexPath = IndexPath(row: index, section: 0)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
                
            } else {
                let index = addSpending(spending: spending)
                if (inThisMonth(date: spending.date)) {
                    let newIndexPath = IndexPath(row: index, section: 0)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
            }
        }
        saveSpendings()
        calculateTotal()
    }
}
