//
//  CatCollectionViewController.swift
//  SRZoomTransition
//
//  Created by Louis Tur on 11/1/15.
//  Copyright © 2015 Louis Tur. All rights reserved.
//

import Foundation
import UIKit
import Cartography
import Alamofire

public struct CatAPIUrl {
  static let BaseUrl: String = "http://thecatapi.com/api"
  static let CatRequestUrl: String = CatAPIUrl.BaseUrl + "/images/get"
  
  public struct CatAPIParam {
    static let ImageId: String = "image_id"
    static let ImageFormat: String = "format"
    static let NumberOfResults: String = "results_per_page"
    static let ImageType: String = "type"
    static let ImageSize: String = "size"
  }
  
  enum CatImageType: String {
    case jpg = "jpg"
    case png = "png"
    case gif = "gif"
  }
  
  enum CatImageSize: String {
    case Small = "small" // 250
    case Medium = "med" // 500
    case Full = "full" // original
  }
}

public class CatCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  
  // MARK: - Variables
  public static let CatCellIdentifier: String = "catCell"
  private var numberOfImagesToFetch: Int = 20
  
  
  // MARK: - Lifecycle
  public override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  convenience public init(WithPreloadedCatImages numberOfImages: Int) {
    self.init()
    if numberOfImages > 0 { self.numberOfImagesToFetch = numberOfImages }
    
    self.view.addSubview(self.catCollectionView)
    self.catCollectionView.delegate = self
    self.catCollectionView.dataSource = self
    
    self.configureConstraints()
  }
  
  private func makeCatRequest() {
    Alamofire.request(.GET, CatAPIUrl.CatRequestUrl)
      .responseString { response in
        print("Success: \(response.result.isSuccess)")
        print("Response String: \(response.result.value)")
      }
  }
  
  
  // MARK: - Layout
  private func configureConstraints() {
    
    constrain( catCollectionView ) { collectionView in
      collectionView.edges == collectionView.superview!.edges
    }
  }
  
  
  // MARK: - UICollectionViewDataSource
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(CatCollectionViewController.CatCellIdentifier, forIndexPath: indexPath)
    
    return cell
  }
  
  public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.numberOfImagesToFetch
  }
  
  
  // MARK: - UICollectionViewDelegate
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
  }
  
  
  // MARK: - UICollectionViewDelegateFlowLayout
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(20.0, 20.0)
  }
  
  
  // MARK: - Lazy UI Loaders
  public lazy var catCollectionView: UICollectionView = {
    let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
    flowLayout.estimatedItemSize = CGSizeZero
    
    let collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: CatCollectionViewController.CatCellIdentifier)
    return collectionView
  }()
}