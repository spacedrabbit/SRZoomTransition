//
//  CatFullScreenView.swift
//  SRZoomTransition
//
//  Created by Louis Tur on 11/7/15.
//  Copyright © 2015 Louis Tur. All rights reserved.
//

import Foundation
import UIKit
import Cartography

public class CatFullScreenView: UIViewController, UIScrollViewDelegate {
  private var image: UIImage?
  private var minimumZoomScale: CGFloat = 1.00
  private var maximumZoomScale: CGFloat = 5.00
  
  // MARK: - Initialization
  public override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  public func loadViewWithCatImage(catImage: UIImage) {
    self.view.backgroundColor = UIColor.redColor()
    self.zoomScrollView.backgroundColor = UIColor.yellowColor()
    self.image = catImage
    self.imageView.image = catImage
    self.imageView.contentMode = .ScaleAspectFit
    
    self.view.addSubview(self.zoomScrollView)
    self.zoomScrollView.addSubview(self.imageView)
    
    self.configureConstraints()
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    zoomScrollView.minimumZoomScale = 1.00
    zoomScrollView.maximumZoomScale = 2.50
    zoomScrollView.alwaysBounceHorizontal = true
    zoomScrollView.alwaysBounceVertical = true
    zoomScrollView.delegate = self
    
    self.configureConstraints()
  }
  
  
  // MARK: - Layout
  private func configureConstraints() {
    let views = [zoomScrollView, imageView]
    constrain(views) { (views) -> () in
      let scrollView = views[0]
      let imageView = views[1]
      
      scrollView.edges == scrollView.superview!.edges
      
      imageView.left == imageView.superview!.left
      imageView.width == scrollView.superview!.width // scrollview.superview here for the correct device width
      imageView.top == imageView.superview!.top
      imageView.bottom == imageView.superview!.bottom
      imageView.centerY == imageView.superview!.centerY
      // for whatever reason, it seems like setting centerY after call for the top/bottom constraints
      // resolves having unequal margins between the top of the image and bottom
      
    }
  }
  
  // MARK: - UIScrollViewDelegate
  public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return self.imageView
  }
  
  //some local vars used in scrollViewDidZoom
  var scrollViewSizeWidth: String?, scrollViewSizeHeight: String?
  let formatString: String = "%.0f"
  var callCount: Int = 0
  var diagnosticPrints: Bool = false
  public func scrollViewDidZoom(scrollView: UIScrollView) {
    if diagnosticPrints {
      // i only want this printed once
      if scrollViewSizeWidth == nil && scrollViewSizeHeight == nil {
        scrollViewSizeWidth = String(format: formatString, scrollView.bounds.size.width)
        scrollViewSizeHeight = String(format: formatString, scrollView.bounds.size.height)
        print("scrollView size: (\(scrollViewSizeWidth), \(scrollViewSizeHeight))")
      }
        // only print again if this changes
      else if scrollViewSizeHeight != String(format: formatString, scrollView.bounds.size.height) &&
        scrollViewSizeWidth != String(format: formatString, scrollView.bounds.size.width) {
          print("scrollView size: (\(scrollViewSizeWidth), \(scrollViewSizeHeight))")
      }
      
      let originX: String = String(format: formatString, scrollView.bounds.origin.x)
      let originY: String = String(format: formatString, scrollView.bounds.origin.y)
      let contentWidth: String = String(format: formatString, scrollView.contentSize.width)
      let contentHeight: String = String(format: formatString, scrollView.contentSize.height)
      
      let imageOriginX: String = String(format: formatString, imageView.frame.origin.x)
      let imageOriginY: String = String(format: formatString, imageView.frame.origin.y)
      let imageContentWidth: String = String(format: formatString, imageView.frame.width)
      let imageContentHeight: String = String(format: formatString, imageView.frame.height)
      
      print("------------------  CALL COUNT: \(callCount++)  ---------------------------------")
      print("scrollView content size: (\(contentWidth), \(contentHeight)")
      print("scrollView origin: (\(originX), \(originY)\n")
      print("image frame size: (\(imageContentWidth), \(imageContentHeight)")
      print("image origin: (\(imageOriginX), \(imageOriginY)")
      print("---------------------------------------------------------------------------------\n")
    }
  }
  
  // MARK: - Lazy Loaders
  lazy public var zoomScrollView: UIScrollView = {
    let scrollView: UIScrollView = UIScrollView()
    return scrollView
  }()
  
  lazy public var imageView: UIImageView = {
    let imageView: UIImageView = UIImageView()
    return imageView
  }()
}