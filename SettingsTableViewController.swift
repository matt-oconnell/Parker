//
//  SettingsTableViewController.swift
//  Parker
//
//  Created by Matt O'Connell on 4/29/17.
//  Copyright © 2017 Matt O'Connell. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Constants: Settings Keys
    fileprivate struct SettingsKeys {
        static let AlertTime = "alertTime"
        static let AlertsOn = "alertsOn"
        static let ReminderDayIndex = "reminderDayIndex"
    }

    
    // MARK: - Variables
    var notificationDays: [String] = ["1 day before", "Day of"]
    
    
    // MARK: - Outlets
    @IBOutlet weak var alertsToggle: UISwitch!
    @IBOutlet weak var notificationDay: UIPickerView!
    @IBOutlet weak var datePickerOutlet: UIDatePicker!
    
    
    // MARK: - Actions
    @IBAction func datePickerAction(_ sender: AnyObject) {
        UserDefaults.standard.set(datePickerOutlet.date, forKey: SettingsKeys.AlertTime)
    }
    
    @IBAction func toggleAlerts(_ sender: UISwitch) {
        UserDefaults.standard.set(alertsToggle.isOn, forKey: SettingsKeys.AlertsOn)
    }

    
    // MARK - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationDay.delegate = self
        self.notificationDay.dataSource = self
        
        notificationDay.selectRow(UserDefaults.standard.integer(forKey: SettingsKeys.ReminderDayIndex), inComponent: 0, animated: true)
        
        alertsToggle.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.AlertsOn)
        guard let loadedTime = UserDefaults.standard.object(forKey: SettingsKeys.AlertTime) as? Date else { return }
        datePickerOutlet.date = loadedTime
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK - UIPicker Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return notificationDays.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return notificationDays[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserDefaults.standard.set(row, forKey: SettingsKeys.ReminderDayIndex)
    }
}
