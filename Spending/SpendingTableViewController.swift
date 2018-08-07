//
//  SpendingTableViewController.swift
//  Spending
//
//  Created by Chi Yu on 8/3/18.
//  Copyright © 2018 Chi Yu. All rights reserved.
//

import UIKit

class SpendingTableViewController: UITableViewController {
    // MARK: Properties
    var spendings: [String: [String: [Spending]]] = [:]
    
    // MARK: Constants
    var thisMonth: String = ""
    var thisYear: String = ""
    
        
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = editButtonItem

        // set the constants
        thisMonth = getComponent(component: "month", date: Date())
        thisYear = getComponent(component: "year", date: Date())
        
        // set the title
        self.title = thisMonth + " " + thisYear
        
        // Load the data
        if let savedSpendings = loadSpendings() {
            spendings = savedSpendings
        } else {
            loadSampleSpendings()
        }
        print(spendings)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows")
        print(spendings[thisYear]?[thisMonth]?.count ?? 0)
        return spendings[thisYear]?[thisMonth]?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SpendingTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SpendingTableViewCell else {
            fatalError("The dequeued cell is not an instance of SpendingTableViewCell")
        }

        let spending = spendings[thisYear]![thisMonth]![indexPath.row]
        
        // converts the date to a string
        
        cell.dateLabel.text = getComponent(component: "full", date: spending.date)
        cell.descriptionLabel.text = spending.descript
        cell.moneyLabel.text = printMoney(money: spending.money)
        cell.moneyLabel.textColor = getColor(money: spending.money)

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            spendings[thisYear]![thisMonth]!.remove(at: indexPath.row)
            saveSpendings()
            tableView.deleteRows(at: [indexPath], with: .fade)
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
        
        addSpending(spending: spending1)
        addSpending(spending: spending2)
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
            return UIColor.green
        } else if money < 0 {
            return UIColor.red
        } else {
            return UIColor.black
        }
    }
    
    // return components of a date as a String
    private func getComponent(component: String, date: Date) -> String {
        let df = DateFormatter()
        switch component {
        case "year": df.dateFormat = "yyyy"
        case "month": df.dateFormat = "LLL"
        case "day": df.dateFormat = "d"
        case "full": df.dateFormat = "yyyy-MM-dd"
        default: return ""
        }

        return df.string(from: date)
    }
    
    private func inThisMonth(date: Date) -> Bool {
        return getComponent(component: "year", date: date) == thisYear && getComponent(component: "month", date: date) == thisMonth
    }
    
    // add a spending to spendings
    private func addSpending(spending: Spending) {
        let date = spending.date
        let year = getComponent(component: "year", date: date)
        let month = getComponent(component: "month", date: date)
        
        if let _ = spendings[year]?[month] {
            spendings[year]![month]! += [spending]
        } else if let _ = spendings[year] {
            spendings[year]![month] = [spending]
        } else {
            spendings[year] = [month: [spending]]
        }

        print(spendings)
        print("New Spending:")
        print(spending.date)
        print(spending.descript)
        print(spending.money)
    }
    
    // saves spending records
    private func saveSpendings() {
        NSKeyedArchiver.archiveRootObject(spendings, toFile: Spending.ArchiveURL.path)
    }
    
    // load spending records
    private func loadSpendings() -> [String: [String:[Spending]]]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Spending.ArchiveURL.path) as? [String: [String:[Spending]]]
    }
    
    // MARK: actions
    @IBAction func unwindToSpendingList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SpendingViewController, let spending = sourceViewController.spending {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if (inThisMonth(date: spending.date)) {
                    spendings[thisYear]![thisMonth]![selectedIndexPath.row] = spending
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                } else {
                    spendings[thisYear]![thisMonth]!.remove(at: selectedIndexPath.row)
                    tableView.deleteRows(at: [selectedIndexPath], with: .none)
                    addSpending(spending: spending)
                }
            } else {
                addSpending(spending: spending)
                if (inThisMonth(date: spending.date)) {
                    let newIndexPath = IndexPath(row: spendings[thisYear]![thisMonth]!.count - 1, section: 0)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
            }
        }
        saveSpendings()
    }
}
