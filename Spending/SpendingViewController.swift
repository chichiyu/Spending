//
//  SpendingViewController.swift
//  Spending
//
//  Created by Chi Yu on 8/5/18.
//  Copyright © 2018 Chi Yu. All rights reserved.
//

import UIKit


// adds a toolbar to some of the textfields
extension UITextField {
    func addDoneNextToolbar(onDone: (target: Any, action: Selector)? = nil, onNext: (target: Any, action:Selector)? = nil) {
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        let onNext = onNext ?? (target: self, action: #selector(nextButtonTapped))
        
        let toolbar = UIToolbar()
        toolbar.items = [
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Next", style: .plain, target: onNext.target, action: onNext.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() { self.resignFirstResponder()}
    @objc func nextButtonTapped() {
        if let nextField = self.superview?.superview?.viewWithTag(self.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            self.resignFirstResponder()
        }
    }
}

class SpendingViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
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
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var type: UITextField!
    @IBOutlet weak var descript: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up text fields
        date.delegate = self
        type.delegate = self
        amount.delegate = self
        descript.delegate = self
        
        date.tag = 0
        type.tag = 1
        amount.tag = 2
        descript.tag = 3
        
        date.addDoneNextToolbar()
        amount.addDoneNextToolbar()
        type.addDoneNextToolbar()
        
        amount.keyboardType = UIKeyboardType.decimalPad
        
        // set up the pickers
        let datePicker = UIDatePicker()
        let typePicker = UIPickerView()
        
        date.inputView = datePicker
        type.inputView = typePicker

        typePicker.delegate = self
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(SpendingViewController.onDidChange(sender:)), for: .valueChanged)
        
        // default date to today's date
        date.text = dateToString(date: Date())
        
        saveButton.isEnabled = false
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
        
        let selectedDate = stringToDate(string: date.text ?? "")
        // let typeText = type.text
        let descriptText = descript.text
        let amountValue = Double(amount.text!)!
        spending = Spending(date: selectedDate, descript: descriptText, money: amountValue)
    }
    
    // MARK: UITextFieldDelegate
    // Hide keyboard when finished editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // update save button and title when finisehd editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        navigationItem.title = descript.text ?? "New Spending"
        updateSaveButtonState()
    }
    
    // limits the input to be 2 decimal points for amount
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // only check text for amount
        if textField.tag != 2 {
            return true
        }
        
        if string.isEmpty {
            return true
        }
        
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return isValidDouble(text: replacementText, maxDecimal: 2)
    }

    // MARK: private functions
    // return a date type from a string
    private func dateToString(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df.string(from: date)
    }
    
    // return a string from a date type
    private func stringToDate(string: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        return df.date(from: string)!
    }
    
    // when a new date is selected from the datePicker
    @objc private func onDidChange(sender: UIDatePicker){
        date.text = dateToString(date: sender.date)
    }
    
    // update save button state
    private func updateSaveButtonState() {
        // Disable save button if type or amount is empty
        let amountText = amount.text ?? ""
        let typeText = type.text ?? ""
        saveButton.isEnabled = !(amountText.isEmpty || typeText.isEmpty)
    }
    
    // check if a double is a valid max n decimal-place double
    private func isValidDouble(text: String, maxDecimal: Int) -> Bool {
        let nf = NumberFormatter()
        let separator = nf.decimalSeparator ?? "."
        
        if nf.number(from: text) != nil {
            let split = text.components(separatedBy: separator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            return digits.count <= maxDecimal
        }
        
        return false
    }
}
