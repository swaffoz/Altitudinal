//
//  AltimeterViewController.swift
//  Altimeter
//
//  Created by Zane Swafford on 8/22/15.
//  Copyright (c) 2015 Zane Swafford. All rights reserved.
//

import Charts
import UIKit
import CoreLocation

let UPDATE_FREQUENCY:Double = 3
let MAX_RECORDED_ALTITUDES:Int = Int(floor(60.0 * 60.0 / UPDATE_FREQUENCY))

class AltimeterViewController: UIViewController, CLLocationManagerDelegate, ChartViewDelegate {
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var marginOfErrorLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var accessoryLabel: UILabel!
    
    @IBOutlet weak var errorTitleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var errorButton: UIButton!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet var dataViewCenterYAlignment: NSLayoutConstraint!
    @IBOutlet var dataViewVerticalLeadingSpace: NSLayoutConstraint!
    
    @IBOutlet var chartViewTrailingSpace: NSLayoutConstraint!
    @IBOutlet var chartViewLeadingSpace: NSLayoutConstraint!
    
    @IBOutlet var chartViewVerticalTrailingSpace: NSLayoutConstraint!
    
    
    @IBOutlet weak var dataView: UIView!
    
    let locationManager = CLLocationManager()
    var recordedAltitudes:[Double] = []
    var units = Units.Feet
    var showGraph = true
    var showLabels = true
    var graphColor = UIColor.applicationBrightGreenColor()
    var hasBlurEnabled = false
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        setBackgroundImageAtRandom()
        
        if self.errorTitleLabel.hidden {
            loadPreviousState()
        }
            
        if !hasBlurEnabled {
            enableBackgroundBlur()
            hasBlurEnabled = true
        }
        
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.applicationFontWithSize(19)]
        let backButton = UIBarButtonItem(title: "back", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName:  UIFont.applicationFontWithSize(17)], forState: .Normal)
        
        navigationItem.backBarButtonItem = backButton
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareChartView()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 3
        locationManager.delegate = self
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(UPDATE_FREQUENCY,
                                                   target: self,
                                                 selector: Selector("startUpdatingLocation"),
                                                 userInfo: nil,
                                                  repeats: true)
        triggerLocationServices()
        updateDataViewConstraintsAnimated(false)
    }
    
    func updateDataViewConstraintsAnimated(isAnimated: Bool) {
        if !chartView.hidden {
            self.dataLabel.font = UIFont.applicationFontWithSize(64)
            self.unitLabel.font =  UIFont.applicationFontWithSize(24)
            self.marginOfErrorLabel.font = UIFont.applicationFontWithSize(13)
            
            self.dataViewVerticalLeadingSpace.active = true
            self.dataViewCenterYAlignment.active = false
        } else {
            self.dataLabel.font =  UIFont.applicationFontWithSize(80)
            self.unitLabel.font =  UIFont.applicationFontWithSize(32)
            self.marginOfErrorLabel.font =  UIFont.applicationFontWithSize(18)
            
            self.dataViewVerticalLeadingSpace.active = false
            self.dataViewCenterYAlignment.active = true
        }
        
        if chartView.rightAxis.enabled {
            self.chartViewTrailingSpace.constant = 0
            self.chartViewVerticalTrailingSpace.constant = 0
            self.chartViewLeadingSpace.constant = -8
        } else {
            self.chartViewTrailingSpace.constant = -10
            self.chartViewVerticalTrailingSpace.constant = -10
            self.chartViewLeadingSpace.constant = -10
        }
        
        if isAnimated {
            UIView.animateWithDuration(0.3, animations: { _ in
                self.view.updateConstraints()
                self.view.layoutIfNeeded()
                self.chartView.layoutIfNeeded()
            })
        } else {
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
            self.chartView.layoutIfNeeded()
        }
    }
    
    func setBackgroundImageAtRandom() {
        let imageNumber = Int(arc4random_uniform(5)) + 1
        let img = UIImage(named: "bg\(imageNumber)")
        backgroundImageView.image = img
    }
    
    func enableBackgroundBlur() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.gradientView.backgroundColor = UIColor.clearColor()
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = gradientView.frame
            blurEffectView.autoresizingMask = (UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight)
            
            self.gradientView.addSubview(blurEffectView)
        } else {
            self.gradientView.backgroundColor = UIColor.clearColor()
            var gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = view.bounds
            gradient.colors = [UIColor.applicationPurpleColor().CGColor, UIColor.applicationBlueColor().CGColor]
            gradient.opacity = 0.9
    
            gradientView.layer.insertSublayer(gradient, atIndex: 0)
        }
        self.view.sendSubviewToBack(gradientView)
        self.view.sendSubviewToBack(backgroundImageView)
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func triggerLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                locationManager.requestWhenInUseAuthorization()
            } else {
                startUpdatingLocation()
            }
        }
    }

// MARK: - ChartView
    func prepareChartView() {
        chartView.descriptionText = " "
        chartView.noDataText = " "
        chartView.noDataTextDescription = " "
        
        chartView.rightAxis.labelFont = UIFont.applicationFontWithSize(12)
        
        chartView.userInteractionEnabled = false
        chartView.dragEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        
        chartView.drawGridBackgroundEnabled = false
        chartView.drawMarkers = false
        
        chartView.xAxis.enabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = showLabels
        chartView.legend.enabled = false
        
        chartView.highlightEnabled = false
        chartView.highlightPerDragEnabled = false
        chartView.rightAxis.startAtZeroEnabled = false
        chartView.leftAxis.startAtZeroEnabled = false
        
        chartView.rightAxis.gridColor = UIColor.whiteColor()
        chartView.rightAxis.labelTextColor = UIColor.whiteColor()
        chartView.rightAxis.gridLineDashLengths = [2.0]
        chartView.rightAxis.gridLineDashPhase = 2.0

        chartView.backgroundColor = UIColor.clearColor()
    }
    
    func presentLocationAuthError() {
        self.unitLabel.text = ""
        self.marginOfErrorLabel.text = ""
        self.dataLabel.text = ""
        self.accessoryLabel.text = ""
        self.chartView.hidden = true
        
        self.errorTitleLabel.hidden = false
        self.errorMessageLabel.hidden = false
        self.errorButton.hidden = false
    }
    
    func hideLocationAuthError() {
        loadPreviousState()
        
        self.errorTitleLabel.hidden = true
        self.errorMessageLabel.hidden = true
        self.errorButton.hidden = true
    }
    
// MARK: IBAction
    @IBAction func didTouchUpInsideErrorButton(sender: UIButton) {
         UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
    }
    
// MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse || status == CLAuthorizationStatus.AuthorizedAlways {
            if !self.errorTitleLabel.hidden {
                hideLocationAuthError()
            }
            startUpdatingLocation()
        } else if status == CLAuthorizationStatus.NotDetermined {
            return
        } else {
            presentLocationAuthError()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let lastLocation = locations.last as? CLLocation {
            let newestAltitude:Double
            
            if units == .Feet {
                unitLabel.text = "FT"
                newestAltitude = floor(Conversions.metersToFeet(lastLocation.altitude))
                marginOfErrorLabel.text = String(format: "±%.0f", (floor(Conversions.metersToFeet(lastLocation.horizontalAccuracy))))
            } else {
                unitLabel.text = "M"
                newestAltitude = floor((lastLocation.altitude))
                marginOfErrorLabel.text = String(format: "±%.0f", (floor(lastLocation.horizontalAccuracy)))
            }
            
            // If Recorded Altitudes goes over max count, remove first
            if (recordedAltitudes.count >= MAX_RECORDED_ALTITUDES) {
                recordedAltitudes.removeAtIndex(0)
            }
            recordedAltitudes.append(newestAltitude)
            
            // Update Labels
            dataLabel.text = String(format: "%.0f", newestAltitude)
            if newestAltitude > 0 {
                accessoryLabel.text = "above sea level"
                graphColor = UIColor.applicationBrightGreenColor()
            } else {
                accessoryLabel.text = "below sea level"
                graphColor = UIColor.applicationBlueColor()
            }
            // Generate New Chart Data
            var dataEntries:[ChartDataEntry] = []
            
            for i in 0..<recordedAltitudes.count {
                let dataEntry = ChartDataEntry(value: recordedAltitudes[i], xIndex: i)
                dataEntries.append(dataEntry)
            }
            
            var chartDataSet = LineChartDataSet(yVals: dataEntries)
            chartDataSet.drawCirclesEnabled = false
            chartDataSet.drawCubicEnabled = true
            chartDataSet.drawFilledEnabled = true
            chartDataSet.drawValuesEnabled = false
            chartDataSet.valueTextColor = UIColor.whiteColor()
            chartDataSet.colors = [graphColor]
            chartDataSet.fillColor = graphColor
            let chartData = LineChartData(xVals: [String?](count:recordedAltitudes.count, repeatedValue: ""), dataSet: chartDataSet)
            
            // Update Chart with new data
            chartView.data = chartData
            chartView.moveViewToX(recordedAltitudes.count-1)
            chartView.notifyDataSetChanged()
        }
        
        manager.stopUpdatingLocation()
    }
    
    func loadPreviousState() {
        let oldUnits = units
        if NSUserDefaults.standardUserDefaults().objectForKey("units") == nil {
            // If app has not been launched check for measurement preference.
            var locale = NSLocale.currentLocale()
            if let isMetric = locale.objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
                self.units = (isMetric ? Units.Meters : Units.Feet)
            }
            return
        } else {
            units = Units(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("units"))!
            showGraph = NSUserDefaults.standardUserDefaults().boolForKey("showGraph")
            showLabels = NSUserDefaults.standardUserDefaults().boolForKey("showLabels")
        }
        
        
        if showGraph && chartView.hidden {
            self.chartView.alpha = 0.0
            self.chartView.hidden = false
        }
        
        UIView.animateWithDuration(0.4, animations: { _ in
                self.chartView.alpha = (self.showGraph ? 1.0 : 0.0)
            }, completion: {finished in
                self.chartView.hidden = !self.showGraph
                self.chartView.rightAxis.enabled = self.showLabels
                self.updateDataViewConstraintsAnimated(true)
        })
        
        if (units == .Feet) {
            unitLabel.text = "FT"
        } else {
            unitLabel.text = "M"
        }
        
        if oldUnits != units && oldUnits == .Feet {
            var convertedAltitudes:[Double] = []
            for altitude in recordedAltitudes {
                convertedAltitudes.append(Conversions.feetToMeters(altitude))
            }
            recordedAltitudes = convertedAltitudes
        } else if oldUnits != units && oldUnits == .Meters {
            var convertedAltitudes:[Double] = []
            for altitude in recordedAltitudes {
                convertedAltitudes.append(Conversions.metersToFeet(altitude))
            }
            recordedAltitudes = convertedAltitudes
        }
        
        if let newestAltitude = recordedAltitudes.last {
            dataLabel.text = String(format: "%.0f", newestAltitude)
            
            marginOfErrorLabel.text = "±0"
            
            if newestAltitude > 0 {
                accessoryLabel.text = "above sea level"
                graphColor = UIColor.applicationBrightGreenColor()
            } else {
                accessoryLabel.text = "below sea level"
                graphColor = UIColor.applicationBlueColor()
            }
            
            // Generate New Chart Data
            var dataEntries:[ChartDataEntry] = []
            
            for i in 0..<recordedAltitudes.count {
                let dataEntry = ChartDataEntry(value: recordedAltitudes[i], xIndex: i)
                dataEntries.append(dataEntry)
            }
            
            var chartDataSet = LineChartDataSet(yVals: dataEntries)
            chartDataSet.drawCirclesEnabled = false
            chartDataSet.drawCubicEnabled = true
            chartDataSet.drawFilledEnabled = true
            chartDataSet.drawValuesEnabled = false
            chartDataSet.valueTextColor = UIColor.whiteColor()
            
            chartDataSet.colors = [graphColor]
            chartDataSet.fillColor = graphColor
            
            let chartData = LineChartData(xVals: [String?](count:recordedAltitudes.count, repeatedValue: ""), dataSet: chartDataSet)
            
            // Update Chart with new data
            chartView.data = chartData
            chartView.moveViewToX(recordedAltitudes.count-1)
            chartView.notifyDataSetChanged()
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        updateDataViewConstraintsAnimated(true)
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        updateDataViewConstraintsAnimated(true)
    }
    
}