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
    //zoomScrollView.contentSize = self.view.frame.size
    zoomScrollView.delegate = self
  }
  
  
  // MARK: - Layout
  private func configureConstraints() {
    let views = [zoomScrollView, imageView]
    constrain(views) { (views) -> () in
      let scrollView = views[0]
      let imageView = views[1]
      
      scrollView.edges == scrollView.superview!.edges
      imageView.edges == scrollView.superview!.edges
    }
  }
  
  // MARK: - UIScrollViewDelegate
  public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return self.imageView
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