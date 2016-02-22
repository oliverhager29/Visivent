/// alert window
var alert: UIAlertController!//
//  EventMapViewController.swift
//  Visivent
//
//  Created by OLIVER HAGER on 12/6/15.
//  Copyright © 2015 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import DTMHeatmap

/// EventMapViewController - map that shows events and points of interest
class EventMapViewController: UIViewController, MKMapViewDelegate {
    /// alert window
    var alert: UIAlertController!
    /// lock for preventing other error notifications to open an alert window (leads to error)
    let alertLock = NSLock()
    /// now date (used is current time in display and animation of events)
    var now = NSDate()
    /// volcano pin image
    let volcanoPinImage = UIImage(named: "volcano_pin.png")
    /// no picture image (used in volcano location if no picture of volcano is available)
    let noPictureImage = UIImage(named: "NoPicture")
    /// webcam icon use for button linking to webcam web page
    let webcamImage = UIImage(named: "Webcam")
    /// earthquake category to map icon
    let categoryToImage = [
        MapCategory.EarthquakeCategory0Name:UIImage(named: MapCategory.EarthquakeCategory0CustomizedIconFileName),
        MapCategory.EarthquakeCategory1Name:UIImage(named: MapCategory.EarthquakeCategory1CustomizedIconFileName),
        MapCategory.EarthquakeCategory2Name:UIImage(named: MapCategory.EarthquakeCategory2CustomizedIconFileName),
        MapCategory.EarthquakeCategory3Name:UIImage(named: MapCategory.EarthquakeCategory3CustomizedIconFileName),
        MapCategory.EarthquakeCategory4Name:UIImage(named: MapCategory.EarthquakeCategory4CustomizedIconFileName),
        MapCategory.EarthquakeCategory5Name:UIImage(named: MapCategory.EarthquakeCategory5CustomizedIconFileName),
        MapCategory.EarthquakeCategory6Name:UIImage(named: MapCategory.EarthquakeCategory6CustomizedIconFileName),
        MapCategory.EarthquakeCategory7Name:UIImage(named: MapCategory.EarthquakeCategory7CustomizedIconFileName),
        MapCategory.EarthquakeCategory8Name:UIImage(named: MapCategory.EarthquakeCategory8CustomizedIconFileName),
        MapCategory.EarthquakeCategory9Name:UIImage(named: MapCategory.EarthquakeCategory9CustomizedIconFileName),
        
            MapCategory.EarthquakeCategory10Name:UIImage(named: MapCategory.EarthquakeCategory10CustomizedIconFileName)
    ]
    /// annotation re-use id for volcano location
    let volcanoLocationCategory = "volcano_location"
    /// annotation re-use identifier for point of interest / volcano location
    let poiIdentifier = "poi"
    /// annotation re-use id for events
    let eventIdentifier = "event"
    /// annotation re-use id for earthquakes
    let earthquakeIdentifier = "earthquake"
    /// one hour in seconds
    let OneHourInSeconds = 3600.0
    /// POI image width
    let poiWidth = 160
    /// POI image height
    let poiHeight = 119
    let pictureViewStr = "pictureView"
    let horizontalSpec = "H:[pictureView(160)]"
    let verticalSpec = "V:[pictureView(119)]"
    /// sliding time window
    var slidingTimeWindow : Int!
    /// offset of n hours for slider for loading atleast the last n hours (last 0 hours would not show anything)
    let hoursOffset = 0
    /// maximum last hours that can be loaded (we restrict the number of hour because the number of Pins must be limited)
    var maxHours : Int!
    /// pre-set last hours to load
    var hours = 24
    /// save last hours to load before switching into the animation mode
    var oldHours = 24
    /// number of hours the slider has to change before the label right of the slider changes
    let refreshThreshold = 3
    /// loads events from various data sources (Reuters News of various topics, USGS earthquake events, GVP volcano news, Twitter messages)
    var eventLoader: EventLoader!
    /// event repository that encapsluates database operations
    var eventRepository: EventRepository!
    /// client config i.e. configurations for the various data source clients
    var clientConfig: ClientConfig!
    /// indicates whether the map is in animation mode
    var isAnimated = false
    /// animation time (position of sliding time window)
    var time : Double = 0
    /// amount of time in hours (or fractions) the sliding time window is moved
    let step : Double = 1
    /// start of time window
    var start : NSDate!
    /// activity indicator when the map is loaded
    var activityIndicator: UIActivityIndicatorView!
    /// inidcates that the map (without annotations) has been rendered. We stop the activity indicator when the map has been rendered and the annotation have been loaded.
    var isMapRendered = false
    var annotationCounter = 0
    /// load (last hours of) events
    @IBOutlet weak var loadButton: UIBarButtonItem!
    /// start animation
    @IBOutlet weak var animateButton: UIBarButtonItem!
    /// time slider is used in the animation mode to show or adjust the position of the sliding time window. In the non-animation mode the last hours to load can be selected via the slider
    var timeWindowSlider: TimeWindowSlider!
    /// content view that contains time window slider
    @IBOutlet weak var sliderContentView: UIView!
    /// map view that shows events, points of interest and the user's location
    @IBOutlet var mapView: MKMapView!
    /// beside showing pins a heat map can be shown as map overlay
    var heatmap: DTMHeatmap!
    /// contains events that contribute to the heat map. A brdiging is needed because the heatmap library is implemented in Objective-C
    var myData: [NSObject : AnyObject]!
    /// location manager to show the user's position on the map (may be neat if you are chasing for earthquakes)
    let locationManager = CLLocationManager()
    /// region radius to maximize the initial viewing area of the map
    let regionRadius: CLLocationDistance = 9500000
    
    /// center the map between Europe and America and maximize the viewing area of the map
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
 
    /// load button has been pressed and the specified last hours of events are loaded
    /// :param: sender load button
    @IBAction func loadButtonPressed(sender: UIBarButtonItem) {
        self.isAnimated = false
        now = NSDate()
        let value = 1.0 - (Double(self.hours) - Double(self.hoursOffset)) / Double(Int(round(Double(self.maxHours-self.hoursOffset))))
        self.timeWindowSlider.lowerValue = value
        let hoursAgo = now.dateByAddingTimeInterval(-Double(hours) * OneHourInSeconds)
        self.loadButton.title = "Load \(hours)h ago (\(self.slidingTimeWindow)h)"
        self.activityIndicator.startAnimating()
        let maxDate = self.start.dateByAddingTimeInterval(NSTimeInterval(self.time * 60.0 * 60.0 + Double(self.slidingTimeWindow) * 60.0 * 60.0))
        loadMap(hoursAgo, maxDate: maxDate, isHeatMapShown: self.clientConfig.mapConfig.isHeatShown, isPinShown: self.clientConfig.mapConfig.isPinShown)
        // overlay shows up usually immediatly and may not even rendering of the map so activity indicator would not stop the animation
        if self.clientConfig.mapConfig.isHeatShown && !self.clientConfig.mapConfig.isPinShown {
            self.activityIndicator.stopAnimating()
        }
    }
    
    /// animate button pressed that starts animation of the map with events within a sliding time window
    /// :param: sender animate button
    @IBAction func animateButtonPressed(sender: UIBarButtonItem) {
        self.isAnimated = true
        self.time = Double(self.maxHours)
        // calculate start of time window
        now = NSDate()
        self.start = now.dateByAddingTimeInterval(NSTimeInterval(-1.0 * Float(self.maxHours) * 60.0 * 60.0))
        // schedule load of events for sliding time window
            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0),
            target: self, selector: "animate", userInfo: nil, repeats: false)
        //self.slidingTimeWindow = clientConfig.mapConfig.slidingTimeWindow
    }

    /// load events for sliding time window and schedule to slide time window further
    func animate() {
        if self.isAnimated {
            let diff = self.timeWindowSlider.upperValue - self.timeWindowSlider.lowerValue
            let lowerVal = 1.0 - Double(Double(self.time) / Double(self.maxHours))
            let upperVal = lowerVal  + diff
            if upperVal < 1 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.timeWindowSlider.lowerValue = lowerVal;
                    self.timeWindowSlider.upperValue = upperVal
                    self.loadButton.title = "Load \(Int((1.0 - self.timeWindowSlider.lowerValue) * Double(self.maxHours)))h ago (\(self.slidingTimeWindow)h)"
                    self.timeWindowSlider.updateUI()
                }
                // begin of sliding time window
                let minDate = self.start.dateByAddingTimeInterval(NSTimeInterval(self.time * 60.0 * 60.0))
                // end of sliding time window
                let maxDate = self.start.dateByAddingTimeInterval(NSTimeInterval(self.time * 60.0 * 60.0 + Double(self.slidingTimeWindow) * 60.0 * 60.0))
                // load events within sliding time window
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadMap(minDate, maxDate: maxDate, isHeatMapShown: true, isPinShown: false)
                }
                // slide time window by configurable time step
                self.time -= self.step
                // schedule next slide
                NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1),
                    target: self, selector: "animate", userInfo: nil, repeats: false)
            }
            // slide time window to the beginning i.e. loop from left to right
            else {
                self.time = Double(self.maxHours)
                self.start = now.dateByAddingTimeInterval(NSTimeInterval(-1.0 * Float(self.maxHours) * 60.0 * 60.0))
                NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0),
                    target: self, selector: "animate", userInfo: nil, repeats: false)
            }
        }
    }
    
    /// load events in the specified time interval (minDate/maxDate)
    /// :param: minDate start of interval
    /// :param: maxDate end of interval
    /// :param: isHeatMapShown heat map is shown in animation (best performance)
    /// :param: isPinShown pins are showns (performance may be slow if many pins displayed)
    func loadMap(minDate : NSDate, maxDate : NSDate, isHeatMapShown : Bool, isPinShown : Bool) {
        // clear all anotations
        clearAnnotations()
        // show events from the configured data sources in the specified time interval
        var dataSourceIds : [Int] = []
        if self.clientConfig.twitterConfig.isDisplayed {
            dataSourceIds.append(DataSource.TwitterDataSourceId)
        }
        if self.clientConfig.usgsConfig.isDisplayed {
            dataSourceIds.append(DataSource.USGSDataSourceId)
        }
        if self.clientConfig.gvpConfig.isActivityDisplayed {
            dataSourceIds.append(DataSource.GVPDataSourceId)
        }
        if self.clientConfig.rssConfig.isDisplayed {
            dataSourceIds.append(DataSource.ReutersDataSourceId)
        }
        // load events from the database
        let events = EventRepository.findEvents(EventRepository.sharedContext, dataSourceIds: dataSourceIds, fromDate: minDate, toDate: maxDate, hasLocation: true)
        // add annotations for the newly loaded events
        if isPinShown {
            addAnnotations(self.mapView, events: events)
        }
        // remove heatmap overlay
        if self.heatmap != nil {
            self.mapView.removeOverlay(self.heatmap)
        }
        // re-calculate heatmap for the newly loaded events
        if isHeatMapShown {
            let bridge: BridgeToDTMHeatmap = BridgeToDTMHeatmap()
            myData = bridge.convertEventArray(events)
            self.heatmap = DTMHeatmap()
            self.heatmap.setData(myData)
            self.mapView.addOverlay(self.heatmap)
        }
        // show points of interest if configured
        if self.clientConfig.gvpConfig.isLocationDisplayed {
            let pois = PointOfInterestRepository.findAllPointOfInterests()
            if isPinShown {
                addAnnotations(self.mapView, pois: pois)
            }
        }
    }
    
    /// clear all annotations from the map
    func clearAnnotations() {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    /// initialize the map
    /// :param: animated true if animated, false otheriwse
    override func viewWillAppear(animated: Bool) {
        var sliderWidth = self.view.frame.width
        if sliderWidth > self.view.frame.height {
            sliderWidth = self.view.frame.height
        }
        self.timeWindowSlider = TimeWindowSlider(frame: CGRectMake(0, 0, sliderWidth-30, 30))
        self.timeWindowSlider.addTarget(self, action: "timeWindowSliderValueChanged:", forControlEvents: .ValueChanged)
        self.sliderContentView.addSubview(self.timeWindowSlider)
        super.viewWillAppear(animated)
        //print("frame: width=\(self.view.frame.size.width)  height=\(self.view.frame.size.height)")
        //print("mapView.center: x=\(mapView.center.x)  y=\(mapView.center.y)")
        if self.view.frame.height > self.view.frame.width {
            self.activityIndicator.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        }
        else {
            self.activityIndicator.center = CGPoint(x: self.view.frame.height/2, y: self.view.frame.width/2)
        }
        self.activityIndicator.startAnimating()
        maxHours = self.clientConfig.mapConfig.maxHours
        let tmpHours = Double(round(Double(self.maxHours-self.hoursOffset)))
        self.mapView.delegate = self
        let maxVal : Double = (Double(self.hours) - Double(self.hoursOffset)) / tmpHours
        self.timeWindowSlider.lowerValue = Double(1.0) - maxVal
        self.timeWindowSlider.upperValue = self.timeWindowSlider.lowerValue + (Double(self.clientConfig.mapConfig.slidingTimeWindow) / Double(self.maxHours))
        self.loadButton.title = "Load \(hours)h ago (\(self.slidingTimeWindow)h)"
        self.timeWindowSlider.updateUI()
        if self.clientConfig.mapConfig.isStandardMapView && !self.clientConfig.mapConfig.isSatelliteMapView {
            self.mapView.mapType = MKMapType.Standard
        }
        else if !self.clientConfig.mapConfig.isStandardMapView && self.clientConfig.mapConfig.isSatelliteMapView {
            self.mapView.mapType = MKMapType.Satellite
        }
        else if self.clientConfig.mapConfig.isStandardMapView && self.clientConfig.mapConfig.isSatelliteMapView {
            self.mapView.mapType = MKMapType.Hybrid
        }
        else {
            self.mapView.mapType = MKMapType.Standard
        }
        self.slidingTimeWindow = self.clientConfig.mapConfig.slidingTimeWindow
        now = NSDate()
        let hoursAgo = now.dateByAddingTimeInterval(-Double(hours) * OneHourInSeconds)
        self.time = Double(self.maxHours)
        self.start = now.dateByAddingTimeInterval(NSTimeInterval(-1.0 * Float(self.maxHours) * 60.0 * 60.0))
        let maxDate = self.start.dateByAddingTimeInterval(NSTimeInterval(self.time * 60.0 * 60.0 + Double(self.slidingTimeWindow) * 60.0 * 60.0))
        loadMap(hoursAgo, maxDate: maxDate, isHeatMapShown: clientConfig.mapConfig.isHeatShown, isPinShown: self.clientConfig.mapConfig.isPinShown)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.timeWindowSlider.removeFromSuperview()
    }
    
    func timeWindowSliderValueChanged(timeWindowSlider: TimeWindowSlider) {
        //print("TimeWindow slider value changed: (\(timeWindowSlider.lowerValue) \(timeWindowSlider.upperValue))")
        //print("Sliding time window: \(self.slidingTimeWindow) hours")
        let oldIsAnimated = self.isAnimated
        // if in animation mode the position of the sliding time window is manually changed (e.g. to fast forward)
        if(timeWindowSlider.isTouched) {
            self.slidingTimeWindow = Int(round((timeWindowSlider.upperValue - timeWindowSlider.lowerValue) * Double(self.maxHours)))
            if self.isAnimated {
                self.time = Double(timeWindowSlider.lowerValue) * Double(self.maxHours)
            }
        }
        // pause animation if someone manually changed the slider
        self.isAnimated = false
        // calculate last hours to load
        let hoursFactor = 1.0 - Double(timeWindowSlider.lowerValue)
        self.hours = self.hoursOffset + Int(round(Double(self.maxHours-self.hoursOffset) * hoursFactor))
        // update the time label (time button used for it because label widget cannot be added to navigation bar)
        if ((hours - oldHours) >= refreshThreshold) || ((oldHours - hours) >= refreshThreshold) {
            self.loadButton.title = "Load \(hours)h ago (\(self.slidingTimeWindow)h)"
        }
        // resume animation (if before in animation mode)
        self.isAnimated = oldIsAnimated
    }
    
    /// initialize notification handling, request user's location, initialize event/POI loaders, set map delegate and initialize map
    override func viewDidLoad() {
        self.alert = UIAlertController(title: "Error", message: "Error", preferredStyle: UIAlertControllerStyle.Alert)
        self.alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { alertAction in
            self.alertLock.unlock()
        }))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: LogUtil.ERROR_CATEGORY, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotification:", name: LogUtil.INFO_CATEGORY, object: nil)
        self.locationManager.requestWhenInUseAuthorization()
        eventRepository = EventRepository.sharedInstance
        eventLoader = EventLoader()
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        self.clientConfig = appDelegate.clientConfig
        maxHours = self.clientConfig.mapConfig.maxHours
        
        
        self.slidingTimeWindow = clientConfig.mapConfig.slidingTimeWindow
        
        
        
        
        self.mapView.delegate = self
        centerMapOnLocation(CLLocationCoordinate2D(latitude: 30.0, longitude: -40.0))
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        //print("frame: width=\(self.view.frame.size.width)  height=\(self.view.frame.size.height)")
        //print("mapView.center: x=\(mapView.center.x)  y=\(mapView.center.y)")
        if self.view.frame.height > self.view.frame.width {
            self.activityIndicator.center = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
            //self.activityIndicator.center = self.mapView.center
        }
        else {
           self.activityIndicator.center = CGPoint(x: self.view.frame.height/2, y: self.view.frame.width/2)
        }
        self.activityIndicator.startAnimating()
        self.mapView.addSubview(self.activityIndicator)
        self.mapView.bringSubviewToFront(self.activityIndicator)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// create/retrieve view with pin for an annotation (event/POI) in the map
    /// - parameter mapView: map
    /// :param annotation annotation for the location
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapLocation {
            var identifier : String!
            let mapLocation = annotation as MapLocation
            // volcano location
            if mapLocation.category == volcanoLocationCategory {
                identifier = poiIdentifier
                var view: MKAnnotationView
                // re-use annotation view
                if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                    as MKAnnotationView? {
                        dequeuedView.annotation = annotation
                        dequeuedView.image = volcanoPinImage
                        dequeuedView.centerOffset = CGPointMake(0, -volcanoPinImage!.size.height / 2);
                            let imageView = dequeuedView.detailCalloutAccessoryView?.subviews[0] as! UIImageView
                            // image of POI
                            if mapLocation.mediaURL != StringUtil.EmptyString {
                                GVPClient.sharedInstance().getImageByUrl(mapLocation.mediaURL) {
                                    result, error in
                                    if error != nil {
                                        //print("Error downloading image with URL \(mapLocation.mediaURL): \(error)")
                                        LogUtil.alert(LogUtil.ERROR, title: "Network error", message:   "Image with URL \(mapLocation.mediaURL) not found")
                                    }
                                    else {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            imageView.image = result
                                        }
                                    }
                                }
                            }
                                // place holder image if no image available
                            else {
                                imageView.image = noPictureImage
                            }
                            // if a secondary media URL is set add webcam button open a Web browser to that URL
                            if mapLocation.secondaryMediaURL != StringUtil.EmptyString {
                                let uiButton = UIButton(type: .DetailDisclosure)
                                let image = webcamImage
                                uiButton.setImage(image, forState: UIControlState.Normal)
                                uiButton.imageView?.image = image
                                dequeuedView.leftCalloutAccessoryView = uiButton as UIView
                            }
                        view = dequeuedView
                }
                // create custom annotation view
                else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    // Pin is colored based on the category
                    view.canShowCallout = true
                    view.calloutOffset = CGPoint(x: -5, y: 5)
                    // Add information button showing a detailed textual description of the event/POI
                    view.image = volcanoPinImage
                    view.centerOffset = CGPointMake(0, -volcanoPinImage!.size.height / 2);
                    view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                    // if a secondary media URL is set add webcam button open a Web browser to that URL
                    if mapLocation.secondaryMediaURL != StringUtil.EmptyString {
                        let uiButton = UIButton(type: .DetailDisclosure)
                        let image = webcamImage
                        uiButton.setImage(image, forState: UIControlState.Normal)
                        uiButton.imageView?.image = image
                        view.leftCalloutAccessoryView = uiButton as UIView
                    }
                    // POI with image
                        let pictureView = UIView()
                        let views = [pictureViewStr: pictureView]
                        pictureView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(horizontalSpec, options: [], metrics: nil, views: views))
                        pictureView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(verticalSpec, options: [], metrics: nil, views: views))
                        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: poiWidth, height: poiHeight))
                        // has image
                        if mapLocation.mediaURL != StringUtil.EmptyString {
                            // download image (if not already cached)
                            GVPClient.sharedInstance().getImageByUrl(mapLocation.mediaURL) {
                                result, error in
                                if error != nil {
                                    //print("Error downloading image with URL \(mapLocation.mediaURL): \(error)")
                                    LogUtil.alert(LogUtil.ERROR, title: "Network error", message:   "Image with URL \(mapLocation.mediaURL) not found")
                                }
                                else {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        imageView.image = result
                                    }
                                }
                            }
                        }
                        // no image available
                        else {
                            // show place holder image if no image for the POI available
                            imageView.image = noPictureImage
                        }
                        pictureView.addSubview(imageView)
                        view.detailCalloutAccessoryView = pictureView
                }
                return view
            }
            // earthquake
            if mapLocation.category.containsString(earthquakeIdentifier) {
                identifier = earthquakeIdentifier
                var view: MKAnnotationView
                // re-use annotation view
                if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                    as MKAnnotationView? {
                        dequeuedView.annotation = annotation
                        dequeuedView.image = categoryToImage[mapLocation.category]!
                        dequeuedView.centerOffset = CGPointMake(0, -categoryToImage[mapLocation.category]!!.size.height / 2);
                        view = dequeuedView
                }
                    // create custom annotation view
                else {
                    view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    // Pin is colored based on the category
                    view.canShowCallout = true
                    view.calloutOffset = CGPoint(x: -5, y: 5)
                    // Add information button showing a detailed textual description of the event/POI
                    view.image = categoryToImage[mapLocation.category]!
                    view.centerOffset = CGPointMake(0, -categoryToImage[mapLocation.category]!!.size.height / 2);
                    view.canShowCallout = true
                    view.calloutOffset = CGPoint(x: -5, y: 5)
                    // Add information button showing a detailed textual description of the event/POI
                    view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                }
                return view
            }
            // event
            else {
                identifier = eventIdentifier
                var view: MKPinAnnotationView
                // re-use pin annotation view
                if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                    as? MKPinAnnotationView {
                        dequeuedView.annotation = annotation
                        dequeuedView.pinTintColor = annotation.getColor()
                        view = dequeuedView
                }
                // create pin annotation view
                else {
                    view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    // Pin is colored based on the category
                    view.pinTintColor = annotation.getColor()
                    view.canShowCallout = true
                    view.calloutOffset = CGPoint(x: -5, y: 5)
                    // Add information button showing a detailed textual description of the event/POI
                    view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                }
                return view
            }
        }
        return nil
    }
    
    /// the left/right accesory view in the annotation has been pressed and the webcam link (left button) or the detailed information is shown (right button)
    /// - parameter mapView: map
    /// - parameter annotationView: annotation view
    /// - parameter calloutAccessoryControlTapped: control
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
        if let mapLocation = view.annotation as? MapLocation {
            // right button -> open detailed textual information
            if control == view.rightCalloutAccessoryView {
                    if mapLocation.description != StringUtil.EmptyString {
                        var descriptionAlert: UIAlertController!
                        descriptionAlert = UIAlertController(title: mapLocation.title, message: mapLocation.subtitle, preferredStyle: UIAlertControllerStyle.Alert)
                        descriptionAlert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(descriptionAlert, animated: true, completion: nil)
                    }
            }
            // left button -> open webcam in Web browser
            else if control == view.leftCalloutAccessoryView && mapLocation.secondaryMediaURL !=  StringUtil.EmptyString  {
                UIApplication.sharedApplication().openURL(NSURL(string: mapLocation.secondaryMediaURL)!)
            }
        }
    }
    
    /// add annotations for events to map
    /// :param: mapView map view
    /// :param: events events for which annotations are created
    func addAnnotations(mapView: MKMapView!, events: [Event]) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd hh:mm"
        for event in events {
            let dateString = dateFormatter.stringFromDate(event.timestamp)
            let mapLocation = MapLocation(title: event.location+StringUtil.BlankString+dateString, subtitle: event.summary,
                locationName: event.location, category:  event.category.name,
                mediaURL: event.id, secondaryMediaURL: StringUtil.EmptyString,
                coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))
            mapView.addAnnotation(mapLocation)
        }
        if self.isMapRendered {
            //self.activityIndicator.stopAnimating()
        }
    }
 
    /// add annotations to map
    /// :param: mapView map view
    /// :param: POIs for which annotations are created
    func addAnnotations(mapView: MKMapView!, pois: [PointOfInterest]) {
        for poi in pois {
            let mapLocation = MapLocation(title: poi.name, subtitle: poi.summary,
                locationName: poi.name, category: poi.category.name,
                mediaURL: poi.imageUrl, secondaryMediaURL: poi.webcamUrl,
                coordinate: CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude))
            mapView.addAnnotation(mapLocation)
        }
    }
    
    /// render heat map overlay
    /// :param: mapView map view
    /// :param: overlay overlay
    /// :returns: overlay renderer
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        return DTMHeatmapRenderer(overlay: overlay)
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        self.isMapRendered = true
        self.activityIndicator.stopAnimating()
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if self.isMapRendered {
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillTransitionToSize(_ size: CGSize,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            //print("frame: width=\(size.width)  height=\(size.height)")
            //print("mapView.center: x=\(mapView.center.x)  y=\(mapView.center.y)")
            // portrait
            if size.height > size.width {
                self.activityIndicator.center = CGPoint(x: size.width/2, y: size.height/2)
                self.mapView.reloadInputViews()
            }
            // landscape
            else {
                self.activityIndicator.center = CGPoint(x: size.height/2, y: size.width/2)
                self.mapView.reloadInputViews()
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