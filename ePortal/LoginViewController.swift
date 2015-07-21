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
  }

  
  func loginButtonPressedDown() {
    highlightBorder()
  }
  
  func loginButtonDidPress() {
    unhighlightBorder()
    
    toggleLoginButton()
    logInUser()
    
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
  
  func logInUser() {
    
    Twitter.sharedInstance().logInWithCompletion { session, error in
      if (session != nil) {
        println("signed in as \(session.userName)")
        println("authToken: \(session.authToken)")
        println("authSecret: \(session.authTokenSecret)")
        var value = session.authToken + ";" + session.authTokenSecret
        // Note: This overrides any existing logins
        
        // Override point for customization after application launch.
        let credentialProvider = AWSCognitoCredentialsProvider(
          regionType: Constants.CognitoRegionType,
          identityPoolId: Constants.CognitoIdentityPoolId)
        credentialProvider.logins = ["api.twitter.com": value]
        
        let configuration = AWSServiceConfiguration(
          region: Constants.DefaultServiceRegionType,
          credentialsProvider: credentialProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        
      } else {
        self.alertWithTitle("Error loggin in with Twitter", message: error.localizedDescription ?? "Sorry, could not login. Darn it")
        println("error: \(error.localizedDescription)")
        
        afterDelay(0.6) {
          self.toggleLoginButton()
        }
      }
    }
  }
}

