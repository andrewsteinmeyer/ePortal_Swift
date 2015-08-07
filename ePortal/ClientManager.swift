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

/*
 ClientManager handles login details for the client using AWS Cognito
 */

final class ClientManager {

  private var credentialsProvider: AWSCognitoCredentialsProvider!
  private var completionHandler: AWSContinuationBlock!
  private var keychain: Keychain!

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
  
  func initializeCredentials(logins: [NSObject: AnyObject]?) -> AWSTask {
    // Setup AWS Credentials
    self.credentialsProvider = AWSCognitoCredentialsProvider(regionType: Constants.CognitoRegionType,
                                                             identityPoolId: Constants.CognitoIdentityPoolId)
    
    if let logins = logins {
      self.credentialsProvider.logins = logins
    }
    
    let configuration = AWSServiceConfiguration(region: Constants.DefaultServiceRegionType,
                                                credentialsProvider: self.credentialsProvider)
    
    AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
    
    return self.credentialsProvider.getIdentityId()
  }
  
  func completeLogin(logins: [NSObject: AnyObject]?) {
    var task: AWSTask
    
    if (self.credentialsProvider == nil) {
      task = self.initializeCredentials(logins)
    }
    else {
      if (self.credentialsProvider.logins != nil) {
        //should not get into this block until we add more login providers
        var merge = NSMutableDictionary(dictionary: self.credentialsProvider.logins)
        merge.addEntriesFromDictionary(logins!)
      
        self.credentialsProvider.logins = merge as [NSObject: AnyObject]
      }
      else {
        if let logins = logins {
          self.credentialsProvider.logins = logins
        }
      }
      
      //Force refresh of credentials to see if we need to merge identities.
      //User is initially unauthorized.  If they login with Twitter, the new authorized identity
      //needs to be merged with the previous unauthorized identity to retain the cognito identity id.
      //Currently only supporting Twitter as login provider, but could add more later (Digits, Facebook, Amazon, etc)
      task = self.credentialsProvider.refresh()
    }
    
    task.continueWithBlock {
      task in
      
      if (task.error == nil) {
        println("received AWS credentials")
        
        //TODO: Set Current Device Token stuff for Cognito sync
        println("Cognito id: \(task.result)")
        
      }
      return task
      
    }.continueWithBlock(self.completionHandler)
    
  }
  
  func resumeSessionWithCompletionHandler(completionHandler: AWSContinuationBlock) {
    self.completionHandler = completionHandler
    
    if ((self.keychain[Constants.TwitterProvider]) != nil) {
      println("logging in with twitter")
      loginWithTwitter()
    }
    else if (self.credentialsProvider == nil) {
      println("no login info yet, just setting up aws credentials")
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
    
    //TODO: Does wiping the credential Provider keychain reset the user's cognito id?
    //      Or is it remembered when the user logs back in?
    //      If it gets wiped, we don't want to clearKeyChain in wipeAll() function
    
    self.wipeAll()
    
    AWSTask(result: nil).continueWithBlock(completionHandler)
  }
  
  func wipeAll() {
    println("wiping credentials")
    self.credentialsProvider.logins = nil
    self.credentialsProvider.clearKeychain()
  }
  
  func isLoggedIn() -> Bool {
    return self.isLoggedInWithTwitter()
  }
  
  func getIdentityId() -> String {
    return self.credentialsProvider.identityId
  }

  //MARK: Twitter
  
  func isLoggedInWithTwitter() -> Bool {
    var loggedIn = Twitter.sharedInstance().session() != nil;
    return self.keychain[Constants.TwitterProvider] != nil && loggedIn
  }
  
  func loginWithTwitter() {
    Twitter.sharedInstance().logInWithCompletion { session, error in
      if (session != nil) {
        println("Signed in as \(session.userName)")
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
  
  func initializeDependencies() {
    Fabric.with([Twitter()])
  }
  
}