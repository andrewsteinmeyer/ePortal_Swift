//
//  Utils.swift
//  Expo
//
//  Created by Andrew Steinmeyer on 4/15/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import Foundation
import Accounts

var GlobalMainQueue: dispatch_queue_t {
  return dispatch_get_main_queue()
}

var GlobalUserInteractiveQueue: dispatch_queue_t {
  return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
}

var GlobalUserInitiatedQueue: dispatch_queue_t {
  return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)
}

var GlobalUtilityQueue: dispatch_queue_t {
  return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
}

var GlobalBackgroundQueue: dispatch_queue_t {
  return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)
}

func afterDelay(seconds: Double, closure: () -> ()) {
  let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
  
  //schedule closure to call after time has expired
  //add closure to dispatch main queue
  dispatch_after(when, dispatch_get_main_queue(), closure)
}

//MARK: Dictionary merge extension

extension Dictionary {
  mutating func unionInPlace(
    dictionary: Dictionary<Key, Value>) {
      for (key, value) in dictionary {
        self[key] = value
      }
  }
}
