//
//  FirefeedAuth.swift
//  ePortal
//
//  Created by Andrew Steinmeyer on 8/5/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

/*

- (void) onAuthStatusError:(NSError *)error user:(FAuthData *)user {
  if (user) {
    _user = user;
    NSLog(@"user %@", user);
  } else {
    _user = nil;
  }
  
  for (NSNumber* handle in _blocks) {
    // tell everyone who's listening
    ffbt_void_nserror_user block = [_blocks objectForKey:handle];
    block(error, user);
  }
}
*/

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
  
  /*
  - (void) loginRef:(Firebase *)ref toFacebookAppWithId:(NSString *)appId {
  
  NSString* firebaseId = ref.root.description;
  
  // Pass to the FirefeedAuthData object, which manages multiple auth requests against the same Firebase
  FirefeedAuthData* authData = [self.firebases objectForKey:firebaseId];
  if (!authData) {
  authData = [[FirefeedAuthData alloc] initWithRef:ref.root];
  [self.firebases setObject:authData forKey:firebaseId];
  }
  [authData loginToAppWithId:appId];
  }
  */
}
