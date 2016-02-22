//
//  ClientConfig.swift
//  Visivent
//
//  Created by OLIVER HAGER on 1/9/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation

/// All clinet configurations
class ClientConfig {
    var mapQuestConfig : MapQuestConfig
    var twitterConfig : TwitterConfig
    var usgsConfig : USGSConfig
    var gvpConfig : GVPConfig
    var rssConfig : RSSConfig
    var mapConfig : MapConfig

    /// initalize all client configurations
    init() {
        if let mapQuestConfig = MapQuestConfig.unarchivedInstance(){
            self.mapQuestConfig = mapQuestConfig
        }
        else {
            self.mapQuestConfig = MapQuestConfig()
        }
        if let twitterConfig = TwitterConfig.unarchivedInstance() {
            self.twitterConfig = twitterConfig
        }
        else {
            self.twitterConfig = TwitterConfig()
        }
        if let usgsConfig = USGSConfig.unarchivedInstance() {
            self.usgsConfig = usgsConfig
        }
        else {
            self.usgsConfig = USGSConfig()
        }
        if let gvpConfig = GVPConfig.unarchivedInstance() {
            self.gvpConfig = gvpConfig
        }
        else {
            self.gvpConfig = GVPConfig()
        }
        if let rssConfig = RSSConfig.unarchivedInstance() {
            self.rssConfig = rssConfig
        }
        else {
            self.rssConfig =  RSSConfig()
        }
        if let mapConfig = MapConfig.unarchivedInstance() {
            self.mapConfig = mapConfig
        }
        else {
            self.mapConfig = MapConfig()
        }
    }
    
    /// serialize all client configurations
    func archive() {
        self.mapQuestConfig.save()
        self.twitterConfig.save()
        self.usgsConfig.save()
        self.rssConfig.save()
        self.mapConfig.save()
        self.gvpConfig.save()
    }
    
    /// deserialize all client configurations
    static func unarchive() -> ClientConfig {
        return ClientConfig()
    }
}