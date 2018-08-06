//
//  SpendingViewController.swift
//  Spending
//
//  Created by Chi Yu on 8/5/18.
//  Copyright © 2018 Chi Yu. All rights reserved.
//

import UIKit

class SpendingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var spending: Spending?
    
    // MARK: Data constants
    let typePickerData = [String](arrayLiteral: "Food", "Travel")
    
    // MARK: UIPickerDelegation
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typePickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type.text = typePickerData[row]
    }
    
    
    // MARK: Properties
    @IBOutlet weak var day: UITextField!
    @IBOutlet weak var month: UITextField!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var type: UITextField!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set up the pickers
        let datePicker = UIDatePicker()
        let typePicker = UIPickerView()
        
        day.inputView = datePicker
        month.inputView = datePicker
        year.inputView = datePicker
        type.inputView = typePicker

        typePicker.delegate = self
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(SpendingViewController.onDidChange(sender:)), for: .valueChanged)
    }
    
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        let yearText = year.text ?? ""
        let monthText = month.text ?? ""
        let dayText = day.text ?? ""
        // let typeText = type.text
        let descriptText = descript.text
        let amountValue = Double(amount.text!)!
        let dateValue = getDate(year: yearText, month: monthText, day: dayText)
        spending = Spending(date: dateValue, descript: descriptText, money: amountValue)
    }
    
    // MARK: private functions
    // return a date object from its components
    private func getDate(year: String, month: String, day: String) -> Date {
        let newMonth = month.count == 1 ? "0" + month : month
        let newDay = day.count == 1 ? "0" + day : day
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: year + "-" + newMonth + "-" + newDay)!
    }
    
    @objc private func onDidChange(sender: UIDatePicker){
        day.text = getComponent(component: "day", date: sender.date)
        month.text = getComponent(component: "month", date: sender.date)
        year.text = getComponent(component: "year", date: sender.date)
    }
    
    private func getComponent(component: String, date: Date) -> String {
        let df = DateFormatter()
        switch component {
        case "day": df.dateFormat = "dd"
        case "month": df.dateFormat = "LL"
        case "year": df.dateFormat = "yyyy"
        default: return ""
        }
        return df.string(from: date)
    }
    

}
