//
//  MapQuestConfigViewController.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/9/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

/// View controller for configuration of MapQuest client
class MapQuestConfigViewController : AbstractConfigViewController {
    var mapQuestConfig : MapQuestConfig!
    
    /// Mapquest API key text field
    @IBOutlet weak var apiKeyTextField: UITextField!
 
    /// activity indicator (shown while seeding city to coordinates mapping in the database)
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// editing of API key ended
    @IBAction func apiKeyEditingDidEnd(sender: UITextField) {
        if let value = sender.text as String? {
            self.mapQuestConfig.apiKey = value
        }

    }

    /// start seeding of city to coordinates mapping in the database
    @IBAction func seedLocationDBPressed(sender: UIButton) {
        self.activityIndicator.startAnimating()
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2),
            target: self, selector: "loadCityCoordinates", userInfo: nil, repeats: false)
    }
    
    func loadCityCoordinates() {
        LocationLoader.sharedInstance().loadCityCoordinates(({
        error in
            dispatch_async(dispatch_get_main_queue(), {
                //print("Finished loading city to coordinate mapping")
                self.activityIndicator.stopAnimating()
            })
        }))
    }
    
    /// get Mapquest configuration out of client configuration
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapQuestConfig = self.clientConfig.mapQuestConfig
    }
    
    /// update fields with current configuration values
    override func viewWillAppear(animated: Bool) {
        self.apiKeyTextField.delegate = self
        self.apiKeyTextField.text = mapQuestConfig.apiKey
    }
}