//
//  TopicsViewController.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/24/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//
import Foundation
/// topics view controller
class TopicsViewController : UITableViewController {
    /// alert window
    var alert: UIAlertController!
    /// lock for preventing other error notifications to open an alert window (leads to error)
    let alertLock = NSLock()
    /// back button title
    var backButtonTitle = ""
    /// client configuration
    var clientConfig : ClientConfig!
    /// Reuter News client configuration
    var rssConfig : RSSConfig!
    /// topics
    var topics = NSMutableArray()
    /// initialize with client configuration from the app delegate
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
        self.rssConfig = self.clientConfig.rssConfig
    }
    /// set selected topics from the client configuration and overwrite back button title
    override func viewWillAppear(animated: Bool) {
        let button = UIBarButtonItem(title: self.backButtonTitle, style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
        self.navigationController!.navigationBar.topItem!.backBarButtonItem = button
        
        for(var i=0; i<RSSClient.Constants.Topics.count; i++) {
            let topic = RSSClient.Constants.Topics[i]
            if self.topics.containsObject(topic) {
                self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
            }
        }
    }
    
    /// back navigates back to the previous view controller
    func goBack()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    /// return number of topics (rows)
    /// :param: tableView table view
    /// :param: section section in table (there is only one)
    /// :returns: number of rows
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RSSClient.Constants.Topics.count
    }
    
    /// initializes table cell
    /// :param: tableView table view
    /// :param: indexPath row
    /// :returns: table view cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /* Get cell type */
        let cellReuseIdentifier = "TopicTableViewCell"
        let topic = RSSClient.Constants.Topics[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! TopicTableViewCell
        cell.topicLabel.text = topic as String
        return cell
    }
    /// row selected
    /// :param: tableView table view
    /// :param: indexPath index of selected row
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let topic = RSSClient.Constants.Topics[indexPath.row]
        if !self.topics.containsObject(topic) {
            self.topics.addObject(topic)
        }
    }
    /// row deselected
    /// :param: tableView table view
    /// :param: indexPath index of deselected row
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let topic = RSSClient.Constants.Topics[indexPath.row]
        if self.topics.containsObject(topic) {
            self.topics.removeObject(topic)
        }
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