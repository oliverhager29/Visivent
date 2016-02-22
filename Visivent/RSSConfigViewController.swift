//
//  RSSConfigViewController.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/9/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
/// View controller for configuration of Twitter client
class RSSConfigViewController : AbstractConfigViewController, UITableViewDelegate, UITableViewDataSource {
    /// Reuters News client configuration
    var rssConfig : RSSConfig!
    /// table view for keywords (only news containing atleast one keyword are only collected, all news are considered if no keywords are collected
    @IBOutlet weak var rssTableView: UITableView!
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
    /// switch that enables/disables data collection changed
    @IBAction func dataCollectedValueChanged(sender: UISwitch) {
        self.rssConfig.isDataCollectionEnabled = self.dataCollectedSwitch.on
    }
    /// switch that enables/disables display changed
    @IBAction func displayedValueChange(sender: UISwitch) {
        self.rssConfig.isDisplayed = self.displayedSwitch.on
    }
    /// editing of refresh interval did end and value is stored
    @IBAction func refreshIntervalEditingDidEnd(sender: UITextField) {
        if let refreshInterval = Int(sender.text!) {
            self.rssConfig.refreshInterval = refreshInterval
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// editing start time did end and value is stored
    @IBAction func startTimeEditingDidEnd(sender: UITextField) {
        if let startTime = Int(sender.text!) {
            self.rssConfig.startTime = startTime
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// editing max hours did end and value is stored
    @IBAction func maxHoursEditingDidEnd(sender: UITextField) {
        if let maxHours = Int(sender.text!) {
            self.rssConfig.maxHours = maxHours
            sender.backgroundColor = UIColor.whiteColor()
        }
        else {
            sender.backgroundColor = UIColor.redColor()
        }
    }
    /// change topics button pressed that leads into another page where news topics can be selected
    @IBAction func changeTopicsPressed(sender: UIButton) {
        performSegueWithIdentifier("changeTopicsSegueRSS", sender: self)
    }
    /// change keywords key pressed (leads to new page that allows adding and removing keywords)
    @IBAction func changeKeywordsPressed(sender: UIButton) {

        performSegueWithIdentifier("changeKeywordsSegueRSS", sender: self)
    }
    /// prepage segue for navigatingto keyword and topic page
    /// :param: segue segue
    /// :param: sender sender
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "changeKeywordsSegueRSS") {
            let controller = segue.destinationViewController as! KeywordsViewController
            controller.backButtonTitle = "Reuters News"
            controller.keywords = self.rssConfig.keywords
        }
        else if(segue.identifier == "changeTopicsSegueRSS") {
            let controller = segue.destinationViewController as! TopicsViewController
            controller.topics = self.rssConfig.topics
            controller.backButtonTitle = "Reuters News"
        }
    }
    /// set text field and table delegates and get client configuration from app delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.maxHoursTextField.delegate = self
        self.refreshIntervalTextField.delegate = self
        self.startTimeTextField.delegate = self
        self.rssConfig = self.clientConfig.rssConfig
        self.rssTableView.delegate = self
        self.rssTableView.dataSource = self
    }
    /// initialize switches, text fields and table and overwrite back button title
    override func viewWillAppear(animated: Bool) {
//        let customTitleView = UILabel(frame: CGRectZero)
//        customTitleView.text = "Xyz"
//        customTitleView.font = UIFont.boldSystemFontOfSize(20)
//        customTitleView.backgroundColor = UIColor.clearColor()
//        customTitleView.textColor = UIColor.whiteColor()
//        customTitleView.shadowColor = UIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
//        customTitleView.shadowOffset = CGSizeMake(0, -1)
//        customTitleView.sizeToFit()
//        self.navigationItem.titleView = customTitleView
        
        let button = UIBarButtonItem(title: "Data sources", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
        self.navigationController!.navigationBar.topItem!.backBarButtonItem = button
        
        self.dataCollectedSwitch.setOn(self.rssConfig.isDataCollectionEnabled, animated: false)
        self.displayedSwitch.setOn(self.rssConfig.isDisplayed, animated: false)
        self.maxHoursTextField.text = "\(self.rssConfig.maxHours)"
        self.refreshIntervalTextField.text = "\(self.rssConfig.refreshInterval)"
        self.startTimeTextField.text = "\(self.rssConfig.startTime)"
        self.rssTableView.reloadData()
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
        return self.rssConfig.keywords.count
    }

    /// initializes table cell
    /// :param: tableView table view
    /// :param: indexPath row
    /// :returns: table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "RSSTableViewCell"
        let keyword = self.rssConfig.keywords[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        cell!.textLabel!.text = keyword as? String
        return cell!
    }
}