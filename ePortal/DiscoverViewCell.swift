//
//  DiscoverViewCell.swift
//  DetailPage
//
//  Created by Andrew Steinmeyer on 6/20/15.
//  Copyright (c) 2015 Andrew Steinmeyer. All rights reserved.
//

import UIKit

class DiscoverViewCell: UICollectionViewCell {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupAppearance()
    
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    setupAppearance()
  }
  
  func setupAppearance() {
    //contentView.layer.cornerRadius = 5
  }
  
}
