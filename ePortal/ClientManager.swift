//
//  ClientManager.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 7/20/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import KeychainAccess
import TwitterKit
import Fabric

final class ClientManager {

  private var credentialsProvider: AWSCognitoCredentialsProvider!
  private var completionHandler: AWSContinuationBlock!
  private var keychain: Keychain

  //MARK: Lifecycle

  private init() {
    keychain = Keychain(service: String(format: "%@.%@", NSBundle.mainBundle().bundleIdentifier!, "ClientManager"))
  }

  class var sharedInstance: ClientManager {
    struct SingletonWrapper {
      static let singleton = ClientManager()
    }
    return SingletonWrapper.singleton
  }
  
  //MARK: Login Helpers
  
  func initializeCredentials() -> AWSTask {
    // Setup AWS Credentials
    self.credentialsProvider = AWSCognitoCredentialsProvider(regionType: Constants.CognitoRegionType,
                                                             identityPoolId: Constants.CognitoIdentityPoolId)
    
    let configuration = AWSServiceConfiguration(region: Constants.DefaultServiceRegionType,
                                                credentialsProvider: self.credentialsProvider)
    
    AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    
    return self.credentialsProvider.getIdentityId()
  }
  
  func completeLogin(logins: [NSObject: AnyObject]?) {
    var task: AWSTask
    
    if (self.credentialsProvider == nil) {
      task = self.initializeCredentials()
    }
    else {
      if (self.credentialsProvider.logins != nil) {
        var merge = NSMutableDictionary(dictionary: self.credentialsProvider.logins)
        merge.addEntriesFromDictionary(logins!)
      
        self.credentialsProvider.logins = merge as [NSObject: AnyObject]
      }
      else {
        if let logins = logins {
          self.credentialsProvider.logins = logins
        }
      }
      
      //Force refresh of credentials to see if we need to merge identities
      //Currently only supporting Twitter as login provider, but could add more later (Facebook, etc)
      task = self.credentialsProvider.refresh()
    }
    
    task.continueWithBlock {
      task in
      
      if (task.error == nil) {
        println("setup AWS credentials")
        
        //TODO: Set Current Device Token stuff for Cognito sync
        
      }
      return task
      
    }.continueWithBlock(completionHandler)
    
  }
  
  func resumeSessionWithCompletionHandler(completionHandler: AWSContinuationBlock) {
    self.completionHandler = completionHandler
    
    if ((self.keychain[Constants.TwitterProvider]) != nil) {
      loginWithTwitter()
    }
    
    if (self.credentialsProvider == nil) {
      self.completeLogin(nil)
    }
  }
  
  func loginWithCompletionHandler(completionHandler: AWSContinuationBlock) {
    self.completionHandler = completionHandler
    
    self.loginWithTwitter()
  }
  
  func logoutWithCompletionHandler(completionHandler: AWSContinuationBlock) {
    if (self.isLoggedInWithTwitter()) {
      self.logoutTwitter()
    }
    
    self.wipeAll()
    
    AWSTask(result: nil).continueWithBlock(completionHandler)
  }
  
  func wipeAll() {
    self.credentialsProvider.logins = nil
    self.credentialsProvider.clearKeychain()
  }
  
  func isLoggedIn() -> Bool {
    return self.isLoggedInWithTwitter()
  }

  //MARK: Twitter/Digits
  
  func isLoggedInWithTwitter() -> Bool {
    var loggedIn = Twitter.sharedInstance().session() != nil;
    return self.keychain[Constants.TwitterProvider] != nil && loggedIn
  }
  
  func loginWithTwitter() {
    Twitter.sharedInstance().logInWithCompletion { session, error in
      if (session != nil) {
        println("signed in as \(session.userName)")
        println("authToken: \(session.authToken)")
        println("authSecret: \(session.authTokenSecret)")
        
        self.completeTwitterLogin()
      }
      else {
        println("error logging in with Twitter: \(error.localizedDescription)")
      }
    }
  }
  
  func completeTwitterLogin() {
    self.keychain[Constants.TwitterProvider] = "YES"
    self.completeLogin( ["api.twitter.com": self.loginForTwitterSession( Twitter.sharedInstance().session() )])
    
  }
  
  func loginForTwitterSession(session: TWTRAuthSession) -> String {
    return String(format: "%@;%@", session.authToken, session.authTokenSecret)
  }
  
  func logoutTwitter() {
    if (Twitter.sharedInstance().session() != nil) {
      Twitter.sharedInstance().logOut()
      self.keychain[Constants.TwitterProvider] = nil
    }
  }
  
}