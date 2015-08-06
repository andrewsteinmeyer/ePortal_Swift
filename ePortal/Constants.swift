//
//  Constants.swift
//
//  Created by Andrew Steinmeyer on 4/23/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import Foundation

struct Constants {
  // AWS Configuration
  static let CognitoRegionType = AWSRegionType.USEast1
  static let DefaultServiceRegionType = AWSRegionType.USEast1
  static let CognitoIdentityPoolId = "us-east-1:e40dbc7f-9b3c-4535-9145-52e5e797dcee"
  
  // Firebase Configuration
  static let FirebaseRootUrl = "https://eportal.firebaseio.com"
  
  // NSUserDefault Keys
  static let DeviceTokenKey = "DeviceToken"
  static let CognitoDeviceTokenKey = "CognitoDeviceTokenKey"
  static let CognitoPushNotification = "CognitoPushNotification"
  
  //Providers
  static let TwitterProvider = "Twitter"
  
  //ViewControllers
  static let loginVC = "LoginViewController"
  static let mainTabBarVC = "MainTabBarController"
  static let broadcastVC = "BroadcastViewController"
  static let detailVC = "DetailViewController"
}
