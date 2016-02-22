//
//  USGSConfigViewController.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/9/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
/// View controller for configuration of USGS client
class USGSConfigViewController : AbstractConfigViewController {
    /// USGS client configuration
    var usgsConfig : USGSConfig!
    /// switch that enables/disables data collection
    @IBOutlet weak var dataCollectedSwitch: UISwitch!
    /// switch that enables/disables display on map
    @IBOutlet weak var displayedSwitch: UISwitch!
    /// text field for interval in seconds after which messages are re-read
    @IBOutlet weak var refreshIntervalTextField: UITextField!
    /// text field for start time in seconds after which messages are first read (in order to distribute load on processor/network)
    @IBOutlet weak var startTimeTextField: UITextField!
    /// text field for maximum number of hours to keep messages
    @IBOutlet weak var maxHoursTextField: UITextField!
    /// text field for minimum magnitude earthquakes to collect
    @IBOutlet weak var minMagnitudeTextField: UITextField!
    /// switch that enables/disables data collection changed
    @IBAction func dataCollectedValueChanged(sender: UISwitch) {
        self.usgsConfig.isDataCollectionEnabled = self.dataCollectedSwitch.on
    }
    /// switch that enables/disables display changed
    @IBAction func displayedValueChanged(sender: UISwitch) {
        self.usgsConfig.isDisplayed = self.displayedSwitch.on
    }
    /// editing of refresh interval did end and value is stored
    @IBAction func refreshIntervalEditingDidEnd(sender: UITextField) {
        if let refreshInterval = Int(sender.text!) {
            self.usgsConfig.refreshInterval = refreshInterval
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// editing start time did end and value is stored
    @IBAction func startTimeEditingDidEnd(sender: UITextField) {
        if let startTime = Int(startTimeTextField.text!) {
            self.usgsConfig.startTime = startTime
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// editing max hours did end and value is stored
    @IBAction func maxHoursEditingDidEnd(sender: UITextField) {
        if let maxHours = Int(sender.text!) {
            self.usgsConfig.maxHours = maxHours
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// editing min magnitude did end and value is stored
    @IBAction func minMagnitudeEditingDidEnd(sender: UITextField) {
        if let minMagnitude = Double(sender.text!) {
            self.usgsConfig.minMagnitude = minMagnitude
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// set text field and table delegates and get client configuration from app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usgsConfig = self.clientConfig.usgsConfig
        self.refreshIntervalTextField.delegate = self
        self.startTimeTextField.delegate = self
        self.maxHoursTextField.delegate = self
        self.minMagnitudeTextField.delegate = self
    }
    /// initialize switches, text fields and table
    override func viewWillAppear(animated: Bool) {
        self.dataCollectedSwitch.setOn(self.usgsConfig.isDataCollectionEnabled, animated: false)
        self.displayedSwitch.setOn(self.usgsConfig.isDisplayed, animated: false)
        self.refreshIntervalTextField.text = "\(self.usgsConfig.refreshInterval)"
        self.startTimeTextField.text = "\(self.usgsConfig.startTime)"
        self.maxHoursTextField.text = "\(self.usgsConfig.maxHours)"
        self.minMagnitudeTextField.text = "\(self.usgsConfig.minMagnitude)"
    }
}