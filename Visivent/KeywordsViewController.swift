//
//  KeywordsViewController.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/11/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
/// keyword configuration view controller
class KeywordsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    /// alert window
    var alert: UIAlertController!
    /// lock for preventing other error notifications to open an alert window (leads to error)
    let alertLock = NSLock()
    /// keywords
    var keywords = NSMutableArray()
    /// back button title
    var backButtonTitle = ""
    /// keyword table
    @IBOutlet weak var myTableView: UITableView!
    /// keyword to add
    @IBOutlet weak var newKeywordTextField: UITextField!
    
    /// initialize notification handling, delegates and data source
    override func viewDidLoad() {
        self.alert = UIAlertController(title: "Error", message: "Error", preferredStyle: UIAlertControllerStyle.Alert)
        self.alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { alertAction in
            self.alertLock.unlock()
        }))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: LogUtil.ERROR_CATEGORY, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: LogUtil.INFO_CATEGORY, object: nil)
        self.newKeywordTextField.delegate = self
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
    }
    
    /// overwrite back button title
    override func viewWillAppear(animated: Bool) {
        let button = UIBarButtonItem(title: self.backButtonTitle, style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
        self.navigationController!.navigationBar.topItem!.backBarButtonItem = button
    }
    
    /// back navigates back to the previous view controller
    func goBack()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /// add keyword button pressed that adds keyword from the newKeywordTextField
    @IBAction func addKeywordButtonPressed(sender: UIButton) {
        if let newKeyword = newKeywordTextField.text as String? {
            if keywords.indexOfObject(newKeyword) == NSNotFound {
                keywords.addObject(newKeyword)
                self.myTableView.reloadData()
                newKeywordTextField.text = StringUtil.EmptyString
            }
        }
    }
    
    /// return number of keywords (rows)
    /// :param: tableView table view
    /// :param: section section in table (there is only one)
    /// :returns: number of rows
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.keywords.count
    }
    
    /// initializes table cell
    /// :param: tableView table view
    /// :param: indexPath row
    /// :returns: table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "KeywordTableViewCell"
        let keyword = self.keywords[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as!KeywordTableViewCell
        cell.keywordLabel.text = keyword as? String
        cell.removeKeyword.layer.setValue(indexPath.row, forKey: "index")
        cell.removeKeyword.addTarget(self, action: "removeKeyword:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    /// remove the selected keyword
    /// :param: remove button
    func removeKeyword(sender:UIButton!) {
        let pos = sender.layer.valueForKey("index") as! Int
        self.keywords.removeObjectAtIndex(pos)
        if self.myTableView != nil {
            self.myTableView.reloadData()
        }
    }
    
    /// hides text field after return
    /// textField text field
    /// :returns: true
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
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