//
//  MapConfigViewController.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/17/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
/// Configuration for map
class MapConfigViewController : UITableViewController, UITextFieldDelegate {
    /// alert window
    var alert: UIAlertController!
    /// lock for preventing other error notifications to open an alert window (leads to error)
    let alertLock = NSLock()
    /// client configuration
    var clientConfig : ClientConfig!
    /// map configuration
    var mapConfig : MapConfig!
    /// segmented control for selecting map type (map, satellite, hybrid)
    @IBOutlet weak var mapViewTypeSegmentedControl: UISegmentedControl!
    /// segmented control for selecting map content (pins, heat map, both/hybrid)
    @IBOutlet weak var mapViewContentSegmentedControl: UISegmentedControl!
    /// text field for maximum number of hours for the slider
    @IBOutlet weak var maxHoursTextField: UITextField!
    /// text field for specifying the sliding time window size
    @IBOutlet weak var slidingTimeWindowTextField: UITextField!
    /// editing max hours did end and value is stored
    @IBAction func maxHoursEditingDidEnd(sender: UITextField) {
        if let maxHours = Int(sender.text!) {
            self.mapConfig.maxHours = maxHours
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// editing sliding time window did end and value is stored
    @IBAction func slidingTimeWindowEditingDidEnd(sender: UITextField) {
        if let slidingTimeWindow = Int(sender.text!) {
            self.mapConfig.slidingTimeWindow = slidingTimeWindow
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// map type changed
    @IBAction func mapViewTypeChanged(sender: UISegmentedControl) {
        self.mapConfig.isStandardMapView = sender.selectedSegmentIndex == 0 || sender.selectedSegmentIndex == 2
        self.mapConfig.isSatelliteMapView = sender.selectedSegmentIndex == 1 || sender.selectedSegmentIndex == 2
    }
    /// map content changed
    @IBAction func mapContentTypeChanged(sender: UISegmentedControl) {
        self.mapConfig.isPinShown = sender.selectedSegmentIndex == 0 || sender.selectedSegmentIndex == 2
        self.mapConfig.isHeatShown = sender.selectedSegmentIndex == 1 || sender.selectedSegmentIndex == 2
    }
    /// get map configuration from app delegate and textfield delegates
    override func viewDidLoad() {
        self.alert = UIAlertController(title: "Error", message: "Error", preferredStyle: UIAlertControllerStyle.Alert)
        self.alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { alertAction in
            self.alertLock.unlock()
        }))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: LogUtil.ERROR_CATEGORY, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: LogUtil.INFO_CATEGORY, object: nil)
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        self.clientConfig = appDelegate.clientConfig
        self.mapConfig = self.clientConfig.mapConfig
        self.maxHoursTextField.delegate = self
        self.slidingTimeWindowTextField.delegate = self
        super.viewDidLoad()
    }
    
    func timeWindowSliderValueChanged(timeWindowSlider: TimeWindowSlider) {
        //print("TimeWindow slider value changed: (\(timeWindowSlider.lowerValue) \(timeWindowSlider.upperValue))")
    }
    
    /// set text fields with the map configuration values
    override func viewWillAppear(animated: Bool) {
        self.maxHoursTextField.text = "\(self.mapConfig.maxHours)"
        self.slidingTimeWindowTextField.text = "\(self.mapConfig.slidingTimeWindow)"
        if self.mapConfig.isStandardMapView && !self.mapConfig.isSatelliteMapView {
            self.mapViewTypeSegmentedControl.selectedSegmentIndex = 0
        }
        else if !self.mapConfig.isStandardMapView && self.mapConfig.isSatelliteMapView {
            self.mapViewTypeSegmentedControl.selectedSegmentIndex = 1
        }
        else if self.mapConfig.isStandardMapView && self.mapConfig.isSatelliteMapView {
            self.mapViewTypeSegmentedControl.selectedSegmentIndex = 2
        }
        else {
            self.mapViewTypeSegmentedControl.selectedSegmentIndex = 0
        }

        if self.mapConfig.isPinShown && !self.mapConfig.isHeatShown {
            self.mapViewContentSegmentedControl.selectedSegmentIndex = 0
        }
        else if !self.mapConfig.isPinShown && self.mapConfig.isHeatShown {
            self.mapViewContentSegmentedControl.selectedSegmentIndex = 1
        }
        else if self.mapConfig.isPinShown && self.mapConfig.isHeatShown {
            self.mapViewContentSegmentedControl.selectedSegmentIndex = 2
        }
        else {
            self.mapViewContentSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    /// hides text field after return
    /// textField text field
    /// :returns: true
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    /// handle notification
    /// :param: notification received notification to act on
    func handleNotification(notification:NSNotification){
        dispatch_async(dispatch_get_main_queue(), {
            if notification.name == LogUtil.ERROR_CATEGORY && self.alert != nil && !self.alert.isBeingPresented() && self.alertLock.tryLock() {
                if let message = notification.object as! String? {
                    self.alert.message = message
                    self.alert.title = "Error"
                    self.presentViewController(self.alert, animated: true, completion: nil)
                }
            }
        })
    }
}