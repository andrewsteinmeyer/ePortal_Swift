//
//  DatabaseManager.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 7/29/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//


/*
DatabaseManager handles calls out to database
*/

final class DatabaseManager {
  
  private var lambdaInvoker: AWSLambdaInvoker!
  
  //MARK: Lifecycle
  
  private init() {
     lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
  }
  
  class var sharedInstance: DatabaseManager {
    struct SingletonWrapper {
      static let singleton = DatabaseManager()
    }
    return SingletonWrapper.singleton
  }
  
  func login() -> AWSTask {
    /*
     use lambda to retrieve login token from Firebase
     using the user's unique cognito identity
     */
    
    let params = [ "identity" : self.getIdentityId() ]
    
    return self.lambdaInvoker.invokeFunction("generateFirebaseToken", JSONObject: params).continueWithBlock() {
      task in
      
      var token = ""
      
      if (task.error != nil) {
        println("Error: \(task.error)")
      }
      if (task.exception != nil) {
        println("Exception: \(task.exception)")
      }
      if (task.result != nil) {
        //println("Result: \(task.result)")
        
        let json = JSON(task.result)
        
        if let loginToken = json["token"].string {
          token = loginToken
          println("Firebase token: \(token)")
        }
        
      }
      
      return token
    }
  }
  
    
  func getIdentityId() -> String {
    return ClientManager.sharedInstance.getIdentityId()
  }
}