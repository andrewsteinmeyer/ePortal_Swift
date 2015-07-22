//
//  LoginViewController.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 6/16/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {

  @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var loginButton: DesignableButton!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupLoginButton()
    
    resumeSession()
  }

  
  func loginButtonPressedDown() {
    highlightBorder()
  }
  
  func loginButtonDidPress() {
    unhighlightBorder()
    
    toggleLoginButton()
    loginUser()
    
  }
  
  //MARK: - Alerts and indicators
  
  func toggleLoginButton() {
    if (loginButton.hidden != true) {
      loginActivityIndicator.startAnimating()
      loginButton.hidden = true
    } else {
      loginActivityIndicator.stopAnimating()
      loginButton.hidden = false
    }
  }
  
  func alertWithTitle(title: String, message: String) {
    var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  //MARK: - Appearance
  
  func setupLoginButton() {
    loginButton.layer.borderColor = UIColor.whiteColor().CGColor
    loginButton.layer.borderWidth = 0.75
    loginButton.layer.cornerRadius = 17
    loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
    
    loginButton.addTarget(self, action: "loginButtonPressedDown", forControlEvents: UIControlEvents.TouchDown)
    loginButton.addTarget(self, action: "loginButtonDidPress", forControlEvents: UIControlEvents.TouchUpInside)
  }
  
  func highlightBorder() {
    loginButton.layer.borderColor = UIColor.yellowColor().CGColor
  }
  
  func unhighlightBorder() {
    loginButton.layer.borderColor = UIColor.whiteColor().CGColor
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}

extension LoginViewController {
  
  //MARK: User Login
  
  func loginUser() {
    
    ClientManager.sharedInstance.loginWithCompletionHandler() { task in
      
      if (task.error == nil) {
        println("hooray logged in and back in LoginViewController")
        self.performSegueWithIdentifier("ShowMainTabBarController", sender: nil)
      }
      else {
        self.alertWithTitle("Error with Twitter session", message: "Sorry, could not login. Darn it")
        
        afterDelay(0.6) {
          self.toggleLoginButton()
        }
      }
      
      return nil
    }
  }
  
  func resumeSession() {
    ClientManager.sharedInstance.resumeSessionWithCompletionHandler() { task in
      
      if (task.error == nil) {
        println("back to Login controller we resumed the session")
      }
      else {
        self.alertWithTitle("Error resuming AWS session", message: "Sorry, could not login. Darn it")
      }
      
      return nil
    }
  }
  
}

