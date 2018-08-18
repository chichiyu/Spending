//
//  SpendingViewController.swift
//  Spending
//
//  Created by Chi Yu on 8/5/18.
//  Copyright © 2018 Chi Yu. All rights reserved.
//

import UIKit

// add a way to find first responder
extension UIView {
    var firstResponder: UIView? {
        guard !isFirstResponder else {return self}
        
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        
        return nil
    }
}
// adds a toolbar to some of the textview and textfield
extension UITextView {
    func addDoneToolbar(onDone: (target: Any, action: Selector)? = nil) {
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar = UIToolbar()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),  UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action),
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonTapped() { self.resignFirstResponder()}}

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
        if let nextField = self.superview?.superview?.viewWithTag(self.tag + 1) as? UITextField ?? self.superview?.superview?.viewWithTag(self.tag + 1) as? UITextView {
            nextField.becomeFirstResponder()
        } else {
            self.resignFirstResponder()
        }
    }
}

class SpendingViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    var spending: Spending?
    var isSpending = true
    
    // MARK: Data constants
    let spendingData = [String](arrayLiteral: "Entertainment", "Food", "Fuel", "Shopping", "Sports", "Travel", "Other")
    let incomeData = [String](arrayLiteral: "Gift", "Salary", "Other")
    let LIGHTGRAY = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
    let RED = UIColor(red:1.00, green:0.4, blue:0.4, alpha:1.0)
    let GREEN = UIColor(red:0.21, green:0.93, blue:0.36, alpha:1.0)
    
    // MARK: UIPickerDelegation
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return isSpending ? spendingData.count : incomeData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return isSpending ? spendingData[row] : incomeData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        type.text = isSpending ? spendingData[row] : incomeData[row]
    }
    
    
    // MARK: Properties
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var type: UITextField!
    @IBOutlet weak var descript: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var incomeButton: UIButton!
    @IBOutlet weak var spendingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // change navigation and tab bar color
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.darkGray

        // set up text fields
        date.delegate = self
        type.delegate = self
        amount.delegate = self
        descript.delegate = self
        
        // make placeholder for descript
        descript.text = "Description"
        descript.textColor = LIGHTGRAY
        descript.layer.borderWidth = 1
        descript.layer.borderColor = LIGHTGRAY.cgColor
        descript.layer.cornerRadius = 10
        
        date.tag = 1
        type.tag = 2
        amount.tag = 3
        descript.tag = 4
        
        date.addDoneNextToolbar()
        amount.addDoneNextToolbar()
        type.addDoneNextToolbar()
        descript.addDoneToolbar()
        
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
        
        // see if a spending already exists
        if let spending = spending {
            navigationItem.title = spending.descript
            date.text = dateToString(date: spending.date)
            amount.text = String(format:"%.2f", spending.money >= 0 ? spending.money : -spending.money)
            type.text = spending.type
            descript.text = spending.descript
            descript.textColor = UIColor.black
            
            let typeIndex = spending.money >= 0 ? incomeData.index(of: type.text!) ?? -1 : spendingData.index(of: type.text!) ?? -1
            if typeIndex >= 0 {typePicker.selectRow(typeIndex, inComponent: 0, animated: true)}
            datePicker.setDate(spending.date, animated: true)
            
            isSpending = spending.money < 0
        }
        
        incomeButton.addTarget(self, action: #selector(incomePressed), for: .touchUpInside)
        spendingButton.addTarget(self, action: #selector(spendingPressed), for: .touchUpInside)
        
        updateSaveButtonState()
        updateButtonState()
    }
    
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddMode = presentingViewController is UITabBarController
        print(isPresentingInAddMode)
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        let selectedDate = stringToDate(string: date.text ?? "")
        let typeText = type.text!
        let descriptText = descript.text
        let amountValue = isSpending ? -(Double(amount.text!) ?? 0) : Double(amount.text!) ?? 0
        spending = Spending(date: selectedDate, descript: descriptText, money: amountValue, type: typeText)
    }
    
    // MARK: UITextFieldDelegate
    // Hide keyboard when finished editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // only check for type
        if textField.tag == 2 {
            if textField.text == "" {
                textField.text = isSpending ? spendingData[0] : incomeData[0]
            }
        }
    }
    
    // update save button and title when finisehd editing
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    // limits the input to be 2 decimal points for amount
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // only check text for amount
        if textField.tag != 3 {
            return true
        }
        
        if string.isEmpty {
            return true
        }
        
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if (replacementText == ".") {
            return true
        }
        
        return isValidDouble(text: replacementText, maxDecimal: 2)
    }

    // UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Description") {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
        navigationItem.title = descript.text == "" ? "New Spending" : descript.text
        textView.resignFirstResponder()
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
    
    @objc private func incomePressed() {
        isSpending = false
        if !incomeData.contains(type.text!) {
            type.text = ""
        }
        updateSaveButtonState()
        updateButtonState()
    }
    
    @objc private func spendingPressed() {
        isSpending = true
        if !spendingData.contains(type.text!) {
            type.text = ""
        }
        updateSaveButtonState()
        updateButtonState()
    }
    
    private func updateButtonState() {
        if isSpending {
            spendingButton.backgroundColor = RED
            spendingButton.setTitleColor(UIColor.black, for: .normal)
            incomeButton.backgroundColor = UIColor.black
            incomeButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            spendingButton.backgroundColor = UIColor.black
            spendingButton.setTitleColor(UIColor.white, for: .normal)
            incomeButton.backgroundColor = GREEN
            incomeButton.setTitleColor(UIColor.black, for: .normal)
        }
    }
    
    // move screen if necessary
    @objc func keyboardWillShow(notification: NSNotification) {
        if view.window?.firstResponder as? UITextView != nil {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    let offset = keyboardSize.height
                    self.view.frame.origin.y -= offset
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // check if a double is a valid max n decimal-place double
    private func isValidDouble(text: String, maxDecimal: Int) -> Bool {
        let nf = NumberFormatter()
        let separator = nf.decimalSeparator ?? "."
        
        if let num = nf.number(from: text) {
            if num.doubleValue < 0 {return false}
            let split = text.components(separatedBy: separator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            return digits.count <= maxDecimal
        }
        
        return false
    }
}
