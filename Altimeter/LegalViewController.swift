//
//  LegalViewController.swift
//  Altimeter
//
//  Created by Zane Swafford on 8/24/15.
//  Copyright (c) 2015 Zane Swafford. All rights reserved.
//

import UIKit

class LegalViewController: UIViewController {
    @IBOutlet weak var legalTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName:  UIFont.applicationFontWithSize(19)]
        legalTextView.scrollRangeToVisible(NSRange(location:0, length:0))
    }

}