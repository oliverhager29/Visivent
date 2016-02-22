//
//  GVPConfigViewController.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/25/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
/// GVP client configuration view controller
class GVPConfigViewController : AbstractConfigViewController {
    /// GVP client configuration
    var gvpConfig : GVPConfig!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    /// switch that enables/disables data collection
    @IBOutlet weak var dataCollectedSwitch: UISwitch!
    /// switch that enables/disables display of volcanic activity (event)
    @IBOutlet weak var activityDisplayedSwitch: UISwitch!
    /// switch that enables/disables display of volcano locations (point of interest)
    @IBOutlet weak var locationDisplayedSwitch: UISwitch!
    /// text field for interval in seconds after which messages are re-read
    @IBOutlet weak var refreshIntervalTextField: UITextField!
    /// text field for start time in seconds after which activities are first read (in order to distribute load on processor/network)
    @IBOutlet weak var startTimeTextField: UITextField!
    /// text field for maximum number of hours to keep messages
    @IBOutlet weak var maxHoursTextField: UITextField!
    /// switch that enables/disables data collection changed
    @IBAction func dataCollectedValueChanged(sender: UISwitch) {
        self.gvpConfig.isDataCollectionEnabled = self.dataCollectedSwitch.on
    }
    /// switch that enables/disables activity display changed
    @IBAction func actvityDisplayedValueChanged(sender: UISwitch) {
        self.gvpConfig.isActivityDisplayed = self.activityDisplayedSwitch.on
    }
    /// switch that enables/disables location display changed
    @IBAction func locationDisplayedValueChanged(sender: UISwitch) {
        self.gvpConfig.isLocationDisplayed = self.locationDisplayedSwitch.on
    }
    /// editing of refresh interval did end and value is stored
    @IBAction func refreshIntervalEditingDidEnd(sender: UITextField) {
        if let refreshInterval = Int(sender.text!) {
            self.gvpConfig.refreshInterval = refreshInterval
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// editing start time did end and value is stored
    @IBAction func startTimeEditingDidEnd(sender: UITextField) {
        if let startTime = Int(startTimeTextField.text!) {
            self.gvpConfig.startTime = startTime
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// editing max hours did end and value is stored
    @IBAction func maxHoursEditingDidEnd(sender: UITextField) {
        if let maxHours = Int(sender.text!) {
            self.gvpConfig.maxHours = maxHours
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    
    /// seed volcano locations button pressed that triggers load of volcano locations (points of interest)
    /// :param: sender button
    @IBAction func seedButtonPressed(sender: UIButton) {
        self.activityIndicator.startAnimating()
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2),
            target: self, selector: "loadVolcanoes", userInfo: nil, repeats: false)
    }
    
    @objc func loadVolcanoes() {
        let volcanoLoader = VolcanoLoader()
        volcanoLoader.loadVolcanoes(({
            dispatch_async(dispatch_get_main_queue(), {
                //print("Finished loading volcano locations")
                self.activityIndicator.stopAnimating()
            })
        }))
    }
    /// set table delegates and get client configuration from app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gvpConfig = self.clientConfig.gvpConfig
        self.refreshIntervalTextField.delegate = self
        self.startTimeTextField.delegate = self
        self.maxHoursTextField.delegate = self
    }
    /// initialize switches and text fields
    override func viewWillAppear(animated: Bool) {
        self.dataCollectedSwitch.setOn(self.gvpConfig.isDataCollectionEnabled, animated: false)
        self.activityDisplayedSwitch.setOn(self.gvpConfig.isActivityDisplayed, animated: false)
        locationDisplayedSwitch.setOn(self.gvpConfig.isLocationDisplayed, animated: false)
        self.refreshIntervalTextField.text = "\(self.gvpConfig.refreshInterval)"
        self.startTimeTextField.text = "\(self.gvpConfig.startTime)"
        self.maxHoursTextField.text = "\(self.gvpConfig.maxHours)"
    }
}