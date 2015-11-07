//
//  Cat.swift
//  SRZoomTransition
//
//  Created by Louis Tur on 11/7/15.
//  Copyright © 2015 Louis Tur. All rights reserved.
//

import Foundation

public class Cat {
  public var id: String = String()
  public var url: String = String()
  public var sourceUrl: String = String()
  
  public init() {
  }
  
  required public init(WithId id: String, url: String, sourceUrl: String) {
    self.id = id
    self.url = url
    self.sourceUrl = sourceUrl
  }
  
}