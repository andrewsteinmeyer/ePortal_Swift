//
//  FirefeedAuth.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 8/5/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//


class FirefeedAuthData {
  private var _blocks: [AnyObject]
  private var _ref: Firebase
  private var _luid: Int
  private var _user: FAuthData?
  private var _authHandle: UInt?
  private var _token: String?
  
  init(ref: Firebase, authToken token: String) {
    _luid = 1
    _ref = ref
    _token = token
    _user = nil
    _blocks = []
    
    // Keep an eye on what Firebase says that our authentication is
    _authHandle = _ref.observeAuthEventWithBlock() { [weak self]
      user in
      
      if let strongSelf = self {
        // This is the new style, but there doesn't appear to be any way to tell which way the user is going, online or offline?
        if ( (user == nil) && (strongSelf._user != nil) ) {
          strongSelf.onAuthStatusError(error: nil, user: nil)
          
        }
      }
    }
  }
  
  deinit {
    if let authHandle = _authHandle {
      _ref.removeAuthEventObserverWithHandle(authHandle)
    }
  }
  
  func onAuthStatusError(#error: NSError?, user: FAuthData?) {
    if (user != nil) {
      _user = user
      println("user: \(user?.uid)")
    }
    else {
      _user = nil
    }
    
    for handle in _blocks {
      //TODO
    }
  }
  
  func login() -> AWSTask {
    var task = AWSTaskCompletionSource()
    
    _ref.authWithCustomToken(self._token) {
      err, authData in
      
      // update the auth state
      self.onAuthStatusError(error: err, user: authData)
      
      if (err != nil) {
        task.setError(err)
      }
      else {
        task.setResult(authData)
      }
    }
    
    return task.task
  }
  
}


final class FirefeedAuth {
  
  private var firebases: [String: FirefeedAuthData]
  
  private init() {
    self.firebases = [String: FirefeedAuthData]()
  }
  
  class var sharedInstance: FirefeedAuth {
    struct SingletonWrapper {
      static let singleton = FirefeedAuth()
    }
    return SingletonWrapper.singleton
  }
  
  class func loginRef(ref: Firebase, withToken token: String) -> AWSTask {
    return self.sharedInstance.loginRef(ref, withToken: token)
  }
  
  func loginRef(ref: Firebase, withToken token: String) -> AWSTask {
    let firebaseId = ref.root.description
    
    // Pass to the FirefeedAuthData object, which manages multiple auth requests against the same Firebase
    var authData = self.firebases[firebaseId] as FirefeedAuthData!
    
    if (authData == nil) {
      authData = FirefeedAuthData(ref: ref, authToken: token)
      self.firebases[firebaseId] = authData
    }
    
    return authData.login()
  }
}
