//
//  Cat.swift
//  SRZoomTransition
//
//  Created by Louis Tur on 11/7/15.
//  Copyright © 2015 Louis Tur. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

public class Cat {
  public var id: String = String()
  public var url: String = String()
  public var sourceUrl: String = String()
  public var catImage: UIImage? = UIImage(named: "placeholderCat")
  
  public init() {
  }
  
  required public init(WithId id: String, url: String, sourceUrl: String) {
    self.id = id
    self.url = url
    self.sourceUrl = sourceUrl
    
    self.getImageForUrl(self.url)
  }
  
  private func getImageForUrl(catImageUrl: String) {
    Alamofire.request(.GET, catImageUrl).responseData({ (response) -> Void in
      if let catImageData: NSData = response.data {
        if let catImage: UIImage = UIImage(data: catImageData) {
          self.catImage = catImage
        }
      }
    })
  }

}