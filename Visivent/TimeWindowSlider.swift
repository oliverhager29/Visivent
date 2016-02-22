//
//  TimeWindowSlider.swift
//  Visivent
//
//  Created by OLIVER HAGER on 2/8/16.
//  Copyright © 2016 OLIVER HAGER. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

/// Time window slider
class TimeWindowSlider: UIControl {
    /// minimum value (left of slider)
    var minimumValue = 0.0
    /// maximum value (right of slider)
    var maximumValue = 1.0
    /// lower (left) slider value
    var lowerValue = 0.2
    /// upper (right) slider value
    var upperValue = 0.8
    /// previous location
    var previousLocation = CGPoint()
    /// slider is currently touched
    var isTouched = false
    /// minumum distance between lower and upper thumb
    let minimumDistanceBetweenThumbs = 5.0
    /// track layer
    let trackLayer = CALayer()
    /// time windows distance layer
    let distanceLayer = CALayer()
    /// hours ago start layer
    let startLayer = CALayer()
    /// lower slider thumb layer
    let lowerThumbLayer = TimeWindowSliderThumbLayer()
    /// upper slider thumb layer
    let upperThumbLayer = TimeWindowSliderThumbLayer()
    /// width of slider thumb
    var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    /// height of slider thumb
    var thumbHeight: CGFloat {
        return CGFloat(bounds.height)
    }
    /// initialize timw window slider
    /// :param: frame rectangle in which slider is drawn
    override init(frame: CGRect) {
        super.init(frame: frame)
        lowerThumbLayer.timeWindowSlider = self
        upperThumbLayer.timeWindowSlider = self
        // blue slide
        trackLayer.backgroundColor = UIColor.blueColor().CGColor
        layer.addSublayer(trackLayer)
        // red time window distance slide
        distanceLayer.backgroundColor = UIColor.redColor().CGColor
        layer.addSublayer(distanceLayer)
        // green hours ago start slide
        startLayer.backgroundColor = UIColor.greenColor().CGColor
        layer.addSublayer(startLayer)
        // green thumb
        lowerThumbLayer.backgroundColor = UIColor.greenColor().CGColor
        layer.addSublayer(lowerThumbLayer)
        // red thumb
        upperThumbLayer.backgroundColor = UIColor.redColor().CGColor
        layer.addSublayer(upperThumbLayer)
        // update slider with thumbs
        updateLayerFrames()
    }
    
    /// initializes slider
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    /// update layer frames
    func updateLayerFrames() {
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        
        distanceLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: bounds.height / 3,
            width: CGFloat(positionForValue(upperValue - lowerValue)), height: CGFloat(bounds.height / 3))
        distanceLayer.setNeedsDisplay()
        
        startLayer.frame = CGRect(x: 0.0, y: bounds.height / 3,
            width: CGFloat(lowerThumbCenter - thumbWidth / 2.0), height: CGFloat(bounds.height / 3))
        startLayer.setNeedsDisplay()
        
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: 0.0,
            width: thumbWidth, height: thumbHeight)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        upperThumbLayer.frame = CGRect(x: upperThumbCenter, y: 0.0,
            width: thumbWidth, height: thumbHeight)
        upperThumbLayer.setNeedsDisplay()
    }
    
    /// thumb center position for value
    /// :param: value thumb value
    /// :returns: thumb center position on slider
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    /// frame in which slider is drawn
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    /// begin touching thumb in slider
    /// :param: touch UI touch
    /// :param: event UI event
    /// :returns: true if thumb was touched, false otherwise
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        isTouched = true
        previousLocation = touch.locationInView(self)
        if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
            upperThumbLayer.highlighted = true
        }
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    /// return value within slider interval (or min/max value if left/right of interval)
    /// :param: value value
    /// :param: lowerValue minimum value of slider interval
    /// :param: upperValue maximum value of slider interval
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    /// thumb is still touched and slided
    /// :param: touch UI touch
    /// :param: event UI event
    /// :returns: true if slider is still touched, false otherwise
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        // how much the thumbs have been slided
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth)
        previousLocation = location
        // update lower/upper values
        if lowerThumbLayer.highlighted {
            let newLowerValue = lowerValue + deltaValue
            if (positionForValue(upperValue) - positionForValue(newLowerValue)) >= minimumDistanceBetweenThumbs {
                lowerValue = newLowerValue
                lowerValue = boundValue(lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
            }
        } else if upperThumbLayer.highlighted {
            let newUpperValue = upperValue + deltaValue
            if (positionForValue(newUpperValue) - positionForValue(lowerValue)) >= minimumDistanceBetweenThumbs {
                upperValue = newUpperValue
                upperValue = boundValue(upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
            }
        }
        // update UI
        updateUI()
        return true
    }

    /// update UI changes to slider
    func updateUI() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateLayerFrames()
        CATransaction.commit()
        sendActionsForControlEvents(.ValueChanged)
    }
    
    /// touch of thumb ended
    /// :param: touch UI touch
    /// :param: event UI event
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
        isTouched = false
    }
}