//
//  CatZoomTransitionCoordinator.swift
//  SRZoomTransition
//
//  Created by Louis Tur on 11/8/15.
//  Copyright © 2015 Louis Tur. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  func cat_snapshot() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, UIScreen.mainScreen().scale)
    let context: CGContextRef = UIGraphicsGetCurrentContext()!
    self.layer.renderInContext(context)
    let snapshot: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return snapshot
  }
}

@objc public protocol CatZoomTransitionCoordinatorDelegate: class {
//  func boundsForViewToEnterTransition() -> CGRect
//  func boundsForViewToOccupyAfterTransition() -> CGRect
//  optional func captureSnapshotForImage() -> UIImageView
//  optional func captureSnapShotForView() -> UIView
  
  func coordinateZoomTransition(withCatZoomCoordinator coordinator: CatZoomTransitionCoordinator,
    forView view: UIView,
    relativeToView relativeView: UIView,
    fromViewController sourceVC: UIViewController,
    toViewController destinationVC: UIViewController) -> CGRect
  
  func coordinateZoomReverseTransition(withCatCoordinator coordinator: CatZoomTransitionCoordinator,
    forView view: UIView,
    relativeToView relativeView: UIView,
    fromViewController sourceVC: UIViewController,
    toViewController destinationVC: UIViewController) -> CGRect
}

public enum CatTransitionType {
  case CatTransitionPresentating
  case CatTransitionDismissing
}

public class CatZoomTransitionCoordinator: NSObject, UIViewControllerAnimatedTransitioning {
  
  public weak var delegate: CatZoomTransitionCoordinatorDelegate?
  public var targetView: UIView?
  public var transitionDuration: NSTimeInterval = 1.00
  public var transitionType: CatTransitionType = .CatTransitionPresentating
  public var fadeColor: UIColor = UIColor.whiteColor()
  
  public override required init() {
    super.init()
  }
  
  public convenience init(withTargetView view: UIView,
    transitionType: CatTransitionType,
    duration: NSTimeInterval,
    delegate: CatZoomTransitionCoordinatorDelegate) {
      self.init()
      self.targetView = view
      self.transitionDuration = duration
      self.transitionType = transitionType
      self.delegate = delegate
  }
  
  
  public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return self.transitionDuration
  }
  
  public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    let containerView = transitionContext.containerView()!
    let fromViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
    let toViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    
    let fromView: UIView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!.view
    let toView: UIView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
    
    let backgroundView: UIView = UIView(frame: containerView.bounds)
    backgroundView.backgroundColor = self.fadeColor
    containerView.addSubview(backgroundView)
    
    if let transitionDelegate: CatZoomTransitionCoordinatorDelegate = self.delegate {
      let startFrame = transitionDelegate.coordinateZoomTransition(withCatZoomCoordinator: self,
        forView: targetView!,
        relativeToView: fromView,
        fromViewController: fromViewController,
        toViewController: toViewController)
      
      let endframe = transitionDelegate.coordinateZoomReverseTransition(withCatCoordinator: self,
        forView: targetView!,
        relativeToView: toView,
        fromViewController: fromViewController,
        toViewController: toViewController)
      
    }
    
    if self.transitionType == .CatTransitionPresentating {
      
      
//      UIView *fromControllerSnapshot = [fromControllerView snapshotViewAfterScreenUpdates:NO];
//      
//      // The fade view will sit between the "from" snapshot and the target snapshot.
//      // This is what is used to create the fade effect.
//      UIView *fadeView = [[UIView alloc] initWithFrame:containerView.bounds];
//      fadeView.backgroundColor = _fadeColor;
//      fadeView.alpha = 0.0;
//      
//      // The star of the show
//      UIView *targetSnapshot = [_targetView snapshotViewAfterScreenUpdates:NO];
//      targetSnapshot.frame = startFrame;
//      
    }
    else if self.transitionType == .CatTransitionDismissing {
      
    }
    else {
      print("Unknown transition type")
    }

    
//    // here's the fucking annoying part. the UIImage has a size, however it's not the scaled size that is being displayed in the UIImageView.
//    // In order to get the accurate size of the image (and then be able to calculate its frame, and grow it appropriately), I'll need to calculate
//    // the size of the image based on the scaling type (AspectFit) and the size of the heigh of the imageView.
//    // see http://stackoverflow.com/questions/389342/how-to-get-the-size-of-a-scaled-uiimage-in-uiimageview
    
  }
  
  public func animationEnded(transitionCompleted: Bool) {
    
  }
}