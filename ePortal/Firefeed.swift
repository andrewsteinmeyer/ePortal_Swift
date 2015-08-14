//
//  Firefeed.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 8/4/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import Firebase

class Firefeed {
  
  private var _root: Firebase
  private var _userRef: Firebase?
  private var _loggedInUser: FirefeedUser?
  private var _feeds: [String: String]
  private var _users: [String: String]
  private var _broadcasts: [String: String]
  private var _providerData: [String: String]?
  
  init(rootUrl: String) {
    _root = Firebase(url: rootUrl)
    
    _feeds = [:]
    _users = [:]
    _broadcasts = [:]
    
    // Auth handled via a global singleton. Prevents modules squashing each other
    FirefeedAuth.watchAuthForRef(self._root, withBlock: { [weak self]
      (error: NSError?, user: FAuthData?) in
      
      if let strongSelf = self {
        if (error != nil) {
          //self.delegate.loginAttemptDidFail()
        } else {
          strongSelf.onAuthStatus(user)
        }
      }
    })
    
  }
  
  func logInWithToken(token: String, providerData data: [String: String]?) -> AWSTask {
    // initialize any user data from provider
    self.populateProviderData(data)
    
    return FirefeedAuth.loginRef(self._root, withToken: token, providerData: data)
  }
  
  func onAuthStatus(user: FAuthData?) {
    if let userData = user {
      var initData: [String: String] = [ "userId": userData.uid ]
      if var providerData = self._providerData {
          initData.unionInPlace(providerData)
      }
      
      self._userRef = self._root.childByAppendingPath("users").childByAppendingPath(userData.uid)
      // populate user with updated information from Firebase and set up observers
      self._loggedInUser = FirefeedUser.loadFromRoot(self._root, withUserData: initData) {
        user in
        
        //TODO: notify delegate of user update
        
        user.updateFromRoot(self._root)
      }
    }
  }
  
  func isAuthenticated() -> Bool {
    if (_root.authData != nil) {
      return true
    }
    
    return false
  }
  
  func populateProviderData(data: [String:String]?) {
    if let data = data {
      _providerData = data
    }
  }
  
  
}

