//
//  DatabaseManager.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 7/29/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import Firebase

/*
DatabaseManager handles calls out to AWS Lambda and Firebase
*/

final class DatabaseManager {
  
  private var _lambdaInvoker: AWSLambdaInvoker!
  private var _firefeed: Firefeed!
  
  private init() {
    self._lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
    self._firefeed = Firefeed(rootUrl: Constants.FirebaseRootUrl)
  }
  
  func generateFirebaseTokenWithId(id: String) -> AWSTask {
    // use lambda to request a login token from Firebase tied to the user's unique cognito identity
    let params = [ "identity" : id ]
    return self._lambdaInvoker.invokeFunction("generateFirebaseToken", JSONObject: params)
  }
  
  func logInWithIdentityId(id: String, providerData data: [String: String]?, completionHandler: AWSContinuationBlock) {
    self.generateFirebaseTokenWithId(id).continueWithBlock() {
      task in
      
      // get firebase token from lambda result
      let token = task.result as! String
      
      return self._firefeed.logInWithToken(token, providerData: data)
    }.continueWithBlock(completionHandler)
  }
  
  func resumeSessionWithCompletionHandler(id: String, providerData data: [String: String]?, completionHandler: AWSContinuationBlock) {
    if (self._firefeed.isAuthenticated()) {
      // already have user, initialize any user data from provider
      self._firefeed.populateProviderData(data)
      
      AWSTask(result: "resuming database session").continueWithBlock(completionHandler)
    }
    else {
     // tried to resume, but no longer authorized.
     self.logInWithIdentityId(id, providerData: data, completionHandler: completionHandler)
    }
  }
  
  //MARK: Singleton
  
  class var sharedInstance: DatabaseManager {
    struct SingletonWrapper {
      static let singleton = DatabaseManager()
    }
    return SingletonWrapper.singleton
  }

}