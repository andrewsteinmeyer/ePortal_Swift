//
//  Firefeed.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 8/4/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import Firebase

class Firefeed {
  
  private var root: Firebase
  
  init(rootUrl: String) {
    self.root = Firebase(url: rootUrl)
  }
  
  func loginWithToken(token: String) -> AWSTask {
    return FirefeedAuth.loginRef(self.root, withToken: token)
  }
  
}
