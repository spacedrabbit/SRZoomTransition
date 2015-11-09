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
  
  public struct Params {
    static let ImageId: String = "image_id"
    static let ResponseFormat: String = "format"
    static let NumberOfResults: String = "results_per_page"
    static let ImageType: String = "type"
    static let ImageSize: String = "size"
  }
  
  public struct ElementName {
    static let Image: String = "image"
    static let Url: String = "url"
    static let Id: String = "id"
    static let SourceUrl: String = "source_url"
  }
  
  enum ResponseFormat: String {
    case xml = "xml"
    case html = "html"
    case src = "src"
  }
  
  enum ImageType: String {
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

public class CatCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSXMLParserDelegate, CatZoomTransitionCoordinatorDelegate, UIViewControllerTransitioningDelegate {
  
  
  // MARK: - Variables
  public static let CatCellIdentifier: String = "catCell"
  public var catArray: [Cat] = []
  private var numberOfImagesToFetch: Int = 20
  private var selectedCell: UICollectionViewCell?
  
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
    self.catCollectionView.backgroundColor = UIColor.redColor()
    
    self.makeCatRequest()
    self.configureConstraints()
  }
  
  public func makeCatRequest() {
    
    let params: [String : String] = [
      CatAPIUrl.Params.ResponseFormat : CatAPIUrl.ResponseFormat.xml.rawValue,
      CatAPIUrl.Params.NumberOfResults : String(numberOfImagesToFetch)
    ]
    
    Alamofire.request(.GET, CatAPIUrl.CatRequestUrl, parameters: params)
      .responseData { response in
        let xmlParser: NSXMLParser = NSXMLParser(data: response.data!)
        xmlParser.delegate = self
        xmlParser.shouldProcessNamespaces = true
        xmlParser.parse()
      }
  }
  
  
  // MARK: - Layout
  private func configureConstraints() {
    constrain( catCollectionView ) { collectionView in
      collectionView.edges == collectionView.superview!.edges
    }
  }
  
  
  // MARK: - XML Parser
  // XML Parsing is really odd, see http://themainthread.com/blog/2014/04/mapping-xml-to-objects-with-nsxmlparser.html
  // Apple Doc was slighty helpful as well https://developer.apple.com/library/ios/samplecode/SeismicXML/Introduction/Intro.html#//apple_ref/doc/uid/DTS40007323-Intro-DontLinkElementID_2

  /* Using the NSXMLParserDelegate requires that you handle each state of the XML document parse.
      Those states that are of most interest/use, are that of
      - element start
      - element characters
      - element end
  
      In the CatAPI, the xml returned for a single request looks like: 
      <response>
        <data>
          <images>
            <image>
              <url>http://29.media.tumblr.com/tumblr_m2yfbdxze71qjev1to1_250.jpg</url>
              <id>3kc</id>
              <source_url>http://thecatapi.com/?id=3kc</source_url>
            </image>
            <image>
              <url>http://24.media.tumblr.com/tumblr_m18kwh02Av1r8kxuoo1_250.jpg</url>
              <id>b0h</id>
              <source_url>http://thecatapi.com/?id=b0h</source_url>
            </image>
          </images>
        </data>
      </response>
  
    Each tag is considered an "element" and it's opening tag is the element's start. And, you guessed it, the
    closing tag is considered it's end. The characters are considered anything found following the tag, which
    ends up being a lot of newline characters + whitespace. Not terribly useful (unless you're looking to draw
    out a simple drawing of the xml mapping). 
  
    Through the delegate, you must listen for the start of the element, any following string information, and 
    then the element's closing tag. As shown in the links above, you need to anticipate and add elements/strings 
    as needed based on the delegate calls. 
  
    In the example below, I add each element encountered to an element stack. When I reach a string without a newline
    I know it is the relevant text between the tags in a child xml node. So I create a new dictionary element with
    the key being the last element on the stack and the value of the string. Because the end of this string will
    signal the closing tag of the element I'm currently going through, I know I can pop off this element from the
    top of stack.
    
    At the point of the first relevant data node, the stack looks like: 
      ["response", "data", "images", "image", "url"]
    
    At this point I take the string of "http://29.media.tumblr.com/...." and add a dictionary entry
      elementDict["url"] = "http://...."
    
    Encountering a closing take for "url" I do a simple comparison of the element's string with the last element
    in the element stack, and if they match, that element is popped off the stack. Then on the next loop, the next
    element is added, and so on and so forth..
      ["response", "data", "images", "image", "id"]
      "3kc"
      pop()
      
      ["response", "data", "images", "image", "source_url"]
      "http......"
      pop()

      ["response", "data", "images", "image"], pop()
      ["response", "data", "images"], pop()
  */
  
  var indentationLevel: Int = 0
  var elementStack: [String] = []
  var encounteredElementValue: String = String()
  var elementDictionary: [String : String] = [String : String]()
  
  public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    elementStack.append(elementName)
  }
  
  public func parser(parser: NSXMLParser, foundCharacters string: String) {
    
    let newLines: NSCharacterSet = NSCharacterSet.newlineCharacterSet()
    if let _: Range = string.rangeOfCharacterFromSet(newLines) {
      // ignores newline characters
    } else {
      encounteredElementValue = string
      if let element: String = elementStack.last {
        elementDictionary[element] = encounteredElementValue
      }
    }
  }
  
  public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if let lastElementOnStack: String = elementStack.last {
      if lastElementOnStack == elementName {
        if let closedTag:String? = elementStack.popLast() {
          if closedTag == CatAPIUrl.ElementName.Image {
            if let cat: Cat = self.generateCatObject() {
              self.catArray.append(cat)
            }
          }
        }
      }
    }
    
  }
  
  private func generateCatObject() -> Cat? {
    if elementDictionary.keys.count == 3 {
      guard let catImageId: String = elementDictionary[CatAPIUrl.ElementName.Id],
        let catImageUrl: String = elementDictionary[CatAPIUrl.ElementName.Url],
        let catSourceURL: String = elementDictionary[CatAPIUrl.ElementName.SourceUrl]
        else {
        return nil
      }
      
      elementDictionary.removeAll()
      return Cat(WithId: catImageId, url: catImageUrl, sourceUrl: catSourceURL)
    }
    return nil
  }
  
  // MARK: - UICollectionViewDataSource
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(CatCollectionViewController.CatCellIdentifier, forIndexPath: indexPath)
    
    if self.catArray.count > 0 {
      let catToDisplay: Cat = self.catArray[indexPath.row]
      if let catImageView: UIImageView = UIImageView(image: catToDisplay.catImage) {
        catImageView.frame = cell.contentView.frame
        cell.contentView.addSubview(catImageView)
      }
    }
    cell.contentView.backgroundColor = UIColor.blueColor()
    
    return cell
  }
  
  public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfImagesToFetch
  }
  
  
  // MARK: - UICollectionViewDelegate
  var transitioningViewRect: CGRect?
  var viewToSnapShot: UIView?
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    let formatString: String = "%.0f"
    if let catCollectionCell: UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) {
      
      let cellX = String(format: formatString, catCollectionCell.frame.origin.x),
        cellY = String(format: formatString, catCollectionCell.frame.origin.y),
        cellWidth = String(format: formatString, catCollectionCell.frame.size.width),
        cellHeight = String(format: formatString, catCollectionCell.frame.size.height)
      
      let cellTranslatedInView: CGRect = catCollectionCell.convertRect(catCollectionCell.bounds, toView: self.view)
      
      print("selectedCell origin: (\(cellX), \(cellY))")
      print("selectedCell size: (\(cellWidth), \(cellHeight))")
      print("selectedCell in view's coordinate space: \(cellTranslatedInView)")
      transitioningViewRect = cellTranslatedInView
      viewToSnapShot = catCollectionCell.contentView
    }
    
    if let catCollectionCell: UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) {
      self.selectedCell = catCollectionCell
    }
    
    if let catToDisplay: Cat = self.catArray[indexPath.row] {
      if let catToDisplayImage: UIImage = catToDisplay.catImage {
        let dtvc: CatFullScreenView = CatFullScreenView()
        dtvc.loadViewWithCatImage(catToDisplayImage)
        dtvc.transitioningDelegate = self
        self.presentViewController(dtvc, animated: true, completion: nil)
        //self.navigationController?.pushViewController(dtvc, animated: true)
      }
    }
  }
  
  public func coordinateZoomTransition(withCatZoomCoordinator coordinator: CatZoomTransitionCoordinator,
    forView view: UIView,
    relativeToView relativeView: UIView,
    fromViewController sourceVC: UIViewController,
    toViewController destinationVC: UIViewController) -> CGRect {
    
      if sourceVC == self { // collection view is presenting
        if let selectedCatCell: UICollectionViewCell = self.selectedCell {
          return selectedCatCell.convertRect(selectedCatCell.bounds, toView: relativeView)
        }
      } else { // collection view is ending vc
        if sourceVC is CatFullScreenView {
          let sourceCatZoomView: CatFullScreenView = sourceVC as! CatFullScreenView
          return sourceCatZoomView.imageView.convertRect(sourceCatZoomView.imageView.bounds, toView: relativeView)
        }
      }
      
      return CGRectZero
  }
  
  public func coordinateZoomReverseTransition(withCatCoordinator coordinator: CatZoomTransitionCoordinator,
    forView view: UIView,
    relativeToView relativeView: UIView,
    fromViewController sourceVC: UIViewController,
    toViewController destinationVC: UIViewController) -> CGRect {
    
      if sourceVC == self {
        if destinationVC is CatFullScreenView {
          let destinationCatVC: CatFullScreenView = destinationVC as! CatFullScreenView
          return destinationCatVC.imageView.convertRect(destinationCatVC.imageView.bounds, toView: relativeView)
        }
      }
      else if sourceVC is CatFullScreenView {
        if let selectedCatCell: UICollectionViewCell = self.selectedCell {
          return selectedCatCell.convertRect(selectedCatCell.bounds, toView: relativeView)
        }
      }

      return CGRectZero
  }
  
//  public func boundsForViewToEnterTransition() -> CGRect {
//    if let viewRect: CGRect =  transitioningViewRect {
//      return viewRect
//    }
//    return CGRectZero
//  }
//  
//  public func boundsForViewToOccupyAfterTransition() -> CGRect {
//    if let viewRect: CGRect =  transitioningViewRect {
//      return viewRect
//    }
//    return CGRectZero
//  }
//  
//  public func captureSnapShotForView() -> UIView {
//    if let view: UIView = viewToSnapShot {
//      return view
//    }
//    return UIView()
//  }
//  
  public func animationControllerForPresentedController(
    presented: UIViewController,
    presentingController presenting: UIViewController,
    sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      
      var animationController: CatZoomTransitionCoordinator?
      
      if let selectedCatCell: UICollectionViewCell = self.selectedCell {
        let transitionType: CatTransitionType = (presenting == self) ? .CatTransitionPresentating : .CatTransitionDismissing
        animationController = CatZoomTransitionCoordinator(withTargetView: selectedCatCell, transitionType: transitionType, duration: 2.00, delegate: self)
        animationController!.delegate = self
      }
      
      return animationController
  }
  
  
  // MARK: - UICollectionViewDelegateFlowLayout
  public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return CGSizeMake(100.0, 100.0)
  }
  
  private func reloadCatCollection() {
    self.catCollectionView.reloadData()
  }
  
  // MARK: - Lazy UI Loaders
  public lazy var catCollectionView: UICollectionView = {
    let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
    flowLayout.estimatedItemSize = CGSizeZero // use this to implement autolayout
    flowLayout.minimumLineSpacing = 10.0
    flowLayout.minimumInteritemSpacing = 10.0
    
    
    let collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: CatCollectionViewController.CatCellIdentifier)
    return collectionView
  }()
}