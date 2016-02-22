//
//  AbstractConfigViewController.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/9/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

/// Abstract configuration view controller
class AbstractConfigViewController : UIViewController, UITextFieldDelegate {
    /// alert window
    var alert: UIAlertController!
    /// lock for preventing other error notifications to open an alert window (leads to error)
    let alertLock = NSLock()
    /// client configuration
    var clientConfig : ClientConfig!
    
    /// get client configuration from app delegate (is persisted in file)
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
    }
    
    /// hides text field after return (so parts of configruation form are not hidden after editing one field)
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
