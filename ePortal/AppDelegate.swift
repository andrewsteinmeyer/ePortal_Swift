//
//  AppDelegate.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 7/20/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    initializeDependencies()
    
    let viewControllerId: String
    
    if ClientManager.sharedInstance.isLoggedIn() {
      viewControllerId = Constants.mainTabBarVC
      ClientManager.sharedInstance.resumeSessionWithCompletionHandler() { task in
        println("resumed in AppDelegate so skipping login page")
        return nil
      }
    }
    else {
      viewControllerId = Constants.loginVC
    }
    
    self.window!.rootViewController = self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier(viewControllerId) as? UIViewController
    
    return true
  }
  
  func initializeDependencies() {
    Fabric.with([Twitter()])
  }




}

