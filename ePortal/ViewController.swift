//
//  ViewController.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 7/20/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated
  }
  
  @IBAction func logoutUser(sender: AnyObject) {
    if ClientManager.sharedInstance.isLoggedIn() {
      ClientManager.sharedInstance.logoutWithCompletionHandler() {
        task in
        
        dispatch_async(GlobalMainQueue) {
          println("completing logout")
          let navVC = UIApplication.sharedApplication().keyWindow?.rootViewController as! UINavigationController
          
          navVC.popToRootViewControllerAnimated(true)
          
        }
        
        return nil
      }
    }
  }


}

