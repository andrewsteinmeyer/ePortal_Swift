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
        self.populateSearchIndicesForUser(authData)
        task.setResult(authData)
        
      }
    }
    
    return task.task
  }
  
  func populateSearchIndicesForUser(user: FAuthData) {
    /*
     For each user, we list them in the search index twice. Once by first name and once by last name.
     We include the id at the end to guarantee uniqueness.
    */
    
    let firstNameRef = _ref.root.childByAppendingPath("search/firstName")
    let lastNameRef = _ref.root.childByAppendingPath("search/lastName")
    
    let firstName = getFirstName()
    let lastName = getLastName()
    let firstNameKey = String(format: "%@_%@_%@", firstName!, lastName!, user.uid).lowercaseString
    let lastNameKey = String(format: "%@_%@_%@", lastName!, firstName!, user.uid).lowercaseString
    
    println("firstname: \(firstName)")
    println("lastname: \(lastName)")
    
    firstNameRef.childByAppendingPath(firstNameKey).setValue(user.uid)
    lastNameRef.childByAppendingPath(lastNameKey).setValue(user.uid)
  }
  
  func getFirstName() -> String? {
    if let fullName = ClientManager.sharedInstance.getUserName() {
      let fullNameArr = fullName.componentsSeparatedByString(" ")
      let firstName: String = fullNameArr[0]
      return firstName
    }
    
    return nil
  }

  func getLastName() -> String? {
    if let fullName = ClientManager.sharedInstance.getUserName() {
      let fullNameArr = fullName.componentsSeparatedByString(" ")
      let lastName: String? = fullNameArr[1]
      return lastName
    }
    
    return nil
  }
  
  /*
  
  - (void) populateSearchIndicesForUser:(FAuthData *)user {
  // For each user, we list them in the search index twice. Once by first name and once by last name. We include the id at the end to guarantee uniqueness
  Firebase* firstNameRef = [_ref.root childByAppendingPath:@"search/firstName"];
  Firebase* lastNameRef = [_ref.root childByAppendingPath:@"search/lastName"];
  
  NSString* firstName = [user.providerData objectForKey:@"first_name"];
  NSString* lastName = [user.providerData objectForKey:@"last_name"];
  NSString* firstNameKey = [[NSString stringWithFormat:@"%@_%@_%@", firstName, lastName, user.uid] lowercaseString];
  NSString* lastNameKey = [[NSString stringWithFormat:@"%@_%@_%@", lastName, firstName, user.uid] lowercaseString];
  
  [[firstNameRef childByAppendingPath:firstNameKey] setValue:user.uid];
  [[lastNameRef childByAppendingPath:lastNameKey] setValue:user.uid];
  }
  */
  
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
