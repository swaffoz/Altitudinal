//
//  SettingsViewController.swift
//  Altimeter
//
//  Created by Zane Swafford on 8/24/15.
//  Copyright (c) 2015 Zane Swafford. All rights reserved.
//

import UIKit

enum Units: Int {
    case Feet, Meters
}

class SettingsViewController: UITableViewController {
    @IBOutlet weak var heartTableViewCell: UITableViewCell!
    @IBOutlet weak var showLabelsTableViewCell: UITableViewCell!
    @IBOutlet weak var unitsButton: UnitsButton!
    @IBOutlet weak var showGraphSwitch: UISwitch!
    @IBOutlet weak var showLabelsSwitch: UISwitch!
    var units = Units.Feet
    var showGraph = true
    var showLabels = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPreviousState()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"saveCurrentState", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName:  UIFont.applicationFontWithSize(19)]
        let backButton = UIBarButtonItem(title: "settings", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        backButton.setTitleTextAttributes([NSFontAttributeName:  UIFont.applicationFontWithSize(17)], forState: UIControlState.Normal)
        navigationItem.backBarButtonItem = backButton
    }
    
    override func viewDidAppear(animated: Bool) {
        if showGraph {
            showLabelsTableViewCell.userInteractionEnabled = true
            showLabelsTableViewCell.alpha = 1.0
        } else {
            showLabelsTableViewCell.userInteractionEnabled = false
            showLabelsTableViewCell.alpha = 0.4
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveCurrentState()
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell == heartTableViewCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.contentView.backgroundColor = UIColor.clearColor()
        } else {
            cell.backgroundColor = UIColor.applicationGrayColor()
        }
    }
    
//MARK: IBActions
    @IBAction func didChangeShowGraphSwitch(sender: UISwitch) {
        showGraph = showGraphSwitch.on
        
        if showGraph {
            showLabelsTableViewCell.userInteractionEnabled = true
            UIView.transitionWithView(sender,
                duration: 0.3,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { _ in
                    self.showLabelsTableViewCell.alpha = 1.0},
                completion: nil
            )
        } else {
            showLabelsTableViewCell.userInteractionEnabled = false
            UIView.transitionWithView(sender,
                duration: 0.3,
                options: UIViewAnimationOptions.CurveEaseInOut,
                animations: { _ in
                    self.showLabelsTableViewCell.alpha = 0.4},
                completion: nil
            )
        }
        
    }
    
    @IBAction func didChangeShowLabelsSwitch(sender: UISwitch) {
        showLabels = showLabelsSwitch.on
    }
    
    @IBAction func didTouchUpInsideUnitsButton(sender: UnitsButton) {
        var newText = ""
        
        if sender.titleLabel?.text == "meters" {
            newText = "feet"
            units = .Feet
        } else {
            newText = "meters"
            units = .Meters
        }
        
        UIView.transitionWithView(sender,
            duration: 0.4,
            options: (.CurveEaseInOut | .TransitionFlipFromTop),
            animations: { _ in
                sender.titleLabel?.alpha = 0
                sender.setTitle(newText,
                    forState: UIControlState.allZeros)
                sender.titleLabel?.alpha = 1},
            completion: { _ in
                UIView.animateWithDuration(0.3,
                    animations: { _ in
                        sender.titleLabel?.alpha = 1
                    }
                )
            }
        )
    }
    
//MARK: Memento Pattern
    func saveCurrentState() {
        NSUserDefaults.standardUserDefaults().setBool(showGraph, forKey: "showGraph")
        NSUserDefaults.standardUserDefaults().setBool(showLabels, forKey: "showLabels")
        NSUserDefaults.standardUserDefaults().setInteger(units.rawValue, forKey: "units")
    }
    
    func loadPreviousState() {
        if NSUserDefaults.standardUserDefaults().objectForKey("units") == nil {
            // If app has not been launched check for measurement preference.
            var locale = NSLocale.currentLocale()
            if let isMetric = locale.objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
                self.units = (isMetric ? Units.Meters : Units.Feet)
                unitsButton.setTitle((isMetric ? "meters" : "feet"), forState: .allZeros)
            }
            return
        }
        
        units = Units(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("units"))!
        showGraph = NSUserDefaults.standardUserDefaults().boolForKey("showGraph")
        showLabels = NSUserDefaults.standardUserDefaults().boolForKey("showLabels")
        if units == .Feet {
            unitsButton.setTitle("feet", forState: .allZeros)
        } else {
            unitsButton.setTitle("meters", forState: .allZeros)
        }
        
        showGraphSwitch.setOn(showGraph, animated: false)
        
        showLabelsSwitch.setOn(showLabels, animated: false)
    }
}