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
    
    var startFrame: CGRect = CGRectZero
    var endframe: CGRect = CGRectZero
    //if let transitionDelegate: CatZoomTransitionCoordinatorDelegate = self.delegate {
      startFrame = self.delegate!.coordinateZoomTransition(withCatZoomCoordinator: self,
        forView: targetView!,
        relativeToView: fromView,
        fromViewController: fromViewController,
        toViewController: toViewController)
      
      endframe = self.delegate!.coordinateZoomReverseTransition(withCatCoordinator: self,
        forView: targetView!,
        relativeToView: toView,
        fromViewController: fromViewController,
        toViewController: toViewController)
      
    //}
    
    if self.transitionType == .CatTransitionPresentating {
      
      let fromControllerSnapshot: UIView = fromView.snapshotViewAfterScreenUpdates(false)
      let fadeView: UIView = UIView(frame: containerView.bounds)
      fadeView.backgroundColor = self.fadeColor
      fadeView.alpha = 0.0
      
      // The star of the show
      let targetSnapShot: UIView = self.targetView!.snapshotViewAfterScreenUpdates(false)
      targetSnapShot.frame = startFrame
      
      // Assemble the hierarchy in the container
      containerView.addSubview(fromControllerSnapshot)
      containerView.addSubview(fadeView)
      containerView.addSubview(targetSnapShot)
      
      // Determine how much we need to scale
      let scaleFactor: CGFloat = endframe.size.width / startFrame.size.width
      
      // Calculate the ending origin point for the "from" snapshot taking into account the scale transformation
      let endPoint: CGPoint = CGPointMake((-startFrame.origin.x * scaleFactor) + endframe.origin.x, (-startFrame.origin.y * scaleFactor) + endframe.origin.y)
      
      
      // Animate presentation
      UIView.animateWithDuration(self.transitionDuration,
        delay: 0.0,
        options: UIViewAnimationOptions.CurveEaseInOut,
        animations: { () -> Void in
          // Transform and move the "from" snapshot
          fromControllerSnapshot.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
          fromControllerSnapshot.frame = CGRectMake(endPoint.x,
            endPoint.y,
            fromControllerSnapshot.frame.size.width,
            fromControllerSnapshot.frame.size.height)
          
          // Fade
          fadeView.alpha = 1.0
          
          // Move our target snapshot into position
          targetSnapShot.frame = endframe
        },
        completion: { (finished: Bool) -> Void in
          // Add "to" controller view
          containerView.addSubview(toView)
          
          // Clean up animation views
          backgroundView.removeFromSuperview()
          fromControllerSnapshot.removeFromSuperview()
          fadeView.removeFromSuperview()
          targetSnapShot.removeFromSuperview()
          
          transitionContext.completeTransition(finished)
      })
    }
    else if self.transitionType == .CatTransitionDismissing {
      print("the other type")
    }
    else {
      print("Unknown transition type")
    }
  }
  
  public func animationEnded(transitionCompleted: Bool) {
    
  }
}