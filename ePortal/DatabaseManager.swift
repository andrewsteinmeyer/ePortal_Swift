//
//  DatabaseManager.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 7/29/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import Firebase

/*
DatabaseManager handles calls out to database
*/

final class DatabaseManager {
  
  private var lambdaInvoker: AWSLambdaInvoker!
  private var firefeed: Firefeed!
  
  //MARK: Lifecycle
  
  private init() {
    self.lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
    self.firefeed = Firefeed(rootUrl: Constants.FirebaseRootUrl)
  }
  
  class var sharedInstance: DatabaseManager {
    struct SingletonWrapper {
      static let singleton = DatabaseManager()
    }
    return SingletonWrapper.singleton
  }
  
  func getIdentityId() -> String {
    return ClientManager.sharedInstance.getIdentityId()
  }
  
  func generateFirebaseToken() -> AWSTask {
    /*
    use lambda to retrieve a token from Firebase tied to the user's unique cognito identity
    */
    let params = [ "identity" : self.getIdentityId() ]
    
    return self.lambdaInvoker.invokeFunction("generateFirebaseToken", JSONObject: params)
  }
  
  func loginWithCompletionHandler(completionHandler: AWSContinuationBlock) {
    self.generateFirebaseToken().continueWithBlock() {
      task in
      
      let token = task.result as! String
      
      return self.firefeed.loginWithToken(token)
    }.continueWithBlock(completionHandler)
  }

}