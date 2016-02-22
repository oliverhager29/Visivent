//
//  TwitterConfigViewController.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/9/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

/// View controller for configuration of Twitter client
class TwitterConfigViewController : AbstractConfigViewController, UITableViewDelegate, UITableViewDataSource {
    /// Twitter client configuration
    var twitterConfig : TwitterConfig!
    /// table view for keywords (only messages containing atleast one keyword are only collected, all messages are considered if no keywords are collected
    @IBOutlet weak var twitterTableView: UITableView!
    /// switch that enables/disables data collection
    @IBOutlet weak var dataCollectedSwitch: UISwitch!
    /// text field for interval in seconds after which messages are re-read
    @IBOutlet weak var refreshIntervalTextField: UITextField!
    /// text field for start time in seconds after which messages are first read (in order to distribute load on processor/network)
    @IBOutlet weak var startTimeTextField: UITextField!
    /// switch that enables/disables display on map
    @IBOutlet weak var displayedSwitch: UISwitch!
    /// text field for Twitter consumer key (register as developer)
    @IBOutlet weak var consumerKeyTextField: UITextField!
    /// text field for Twitter consumer secret (register as developer)
    @IBOutlet weak var consumerSecretTextField: UITextField!
    /// text field for maximum number of hours to keep messages
    @IBOutlet weak var maxHours: UITextField!
    /// switch that enables/disables data collection changed
    @IBAction func dataCollectedSwitchValueChanged(sender: UISwitch) {
        self.twitterConfig.isDataCollectionEnabled = sender.on
    }
    /// switch that enables/disables display changed
    @IBAction func displayedValueChanged(sender: UISwitch) {
        self.twitterConfig.isDisplayed = sender.on
    }
    /// change keywords key pressed (leads to new page that allows adding and removing keywords)
    @IBAction func changeKeywordsPressed(sender: UIButton) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("KeywordsViewController") as! KeywordsViewController
        performSegueWithIdentifier("changeKeywordsSegueTwitter", sender: controller)
    }
    /// prepage segue for navigatingto keyword page
    /// :param: segue segue
    /// :param: sender sender
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "changeKeywordsSegueTwitter") {
            let controller = segue.destinationViewController as! KeywordsViewController
            /// pass Twitter keywords
            controller.keywords = self.twitterConfig.keywords
            controller.backButtonTitle = "Twitter"
        }
    }
    /// editing of Twitter consumer key did end and value is stored
    /// :param: sender text field
    @IBAction func consumerKeyEditingDidEnd(sender: UITextField) {
        self.twitterConfig.consumerKey = sender.text!
    }
    /// editing of Twitter consumer secret did end and value is stored
    @IBAction func consumerSecretEditingDidEnd(sender: UITextField) {
        self.twitterConfig.consumerSecret = sender.text!
    }
    /// editing of refresh interval did end and value is stored
    @IBAction func refreshIntervalEditingDidEnd(sender: UITextField) {
        if let refreshInterval = Int(sender.text!) {
            self.twitterConfig.refreshInterval = refreshInterval
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// editing start time did end and value is stored
    @IBAction func startTimeEditingDidEnd(sender: UITextField) {
        if let startTime = Int(sender.text!) {
            self.twitterConfig.startTime = startTime
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// editing max hours did end and value is stored
    @IBAction func maxHoursEditingDidEnd(sender: UITextField) {
        if let maxHours = Int(sender.text!) {
            self.twitterConfig.maxHours = maxHours
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// set text field and table delegates and get client configuration from app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.consumerKeyTextField.delegate = self
        self.consumerSecretTextField.delegate = self
        self.refreshIntervalTextField.delegate = self
        self.startTimeTextField.delegate = self
        self.maxHours.delegate = self
        self.twitterConfig = self.clientConfig.twitterConfig
        self.twitterTableView.delegate = self
        self.twitterTableView.dataSource = self
    }
    /// initialize switches, text fields and table and overwrite back button title
    override func viewWillAppear(animated: Bool) {
        let button = UIBarButtonItem(title: "Data sources", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
        self.navigationController!.navigationBar.topItem!.backBarButtonItem = button
        
        self.dataCollectedSwitch.setOn(self.twitterConfig.isDataCollectionEnabled, animated: false)
        self.displayedSwitch.setOn(self.twitterConfig.isDisplayed, animated: false)
        self.consumerKeyTextField.text = self.twitterConfig.consumerKey
        self.consumerSecretTextField.text = self.twitterConfig.consumerSecret
        self.refreshIntervalTextField.text = "\(self.twitterConfig.refreshInterval)"
        self.startTimeTextField.text = "\(self.twitterConfig.startTime)"
        self.maxHours.text = "\(self.twitterConfig.maxHours)"
        self.twitterTableView.reloadData()
    }
    
    /// back navigates back to the previous view controller
    func goBack()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /// return number of keywords (rows)
    /// :param: tableView table view
    /// :param: section section in table (there is only one)
    /// :returns: number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.twitterConfig.keywords.count
    }
    
    /// initializes table cell
    /// :param: tableView table view
    /// :param: indexPath row
    /// :returns: table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "TwitterTableViewCell"
        let keyword = self.twitterConfig.keywords[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        cell!.textLabel!.text = keyword as? String
        return cell!
    }
}