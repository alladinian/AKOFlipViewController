//
//  AKOFlipTransitionAnimator.m
//  Pods
//
//  Created by Vasilis Akoinoglou on 7/13/14.
//
//

@interface UIView (AKOFlipSplitting)
- (UIView *)leftHalf;
- (UIView *)rightHalf;
- (UIView *)topHalf;
- (UIView *)bottomHalf;
- (UIView *)shadowView;
@end
@implementation UIView (AKOFlipSplitting)
- (UIView *)leftHalf
{
    CGRect snapRect = CGRectMake(0, 0, CGRectGetMidX(self.bounds), self.frame.size.height);
    UIView *snapshot = [self resizableSnapshotViewFromRect:snapRect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    
    [snapshot addShadowView];
    
    snapshot.userInteractionEnabled = NO;
    return snapshot;
}

- (UIView *)rightHalf
{
    CGRect snapRect = CGRectMake(CGRectGetMidX(self.bounds), 0, CGRectGetMidX(self.bounds), self.frame.size.height);
    UIView *snapshot = [self resizableSnapshotViewFromRect:snapRect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    
    [snapshot addShadowView];
    
    CGRect newFrame = CGRectOffset(snapshot.frame, snapshot.bounds.size.width, 0);
    snapshot.frame = newFrame;
    
    snapshot.userInteractionEnabled = NO;
    return snapshot;
}

- (UIView *)topHalf
{
    CGRect snapRect = CGRectMake(0, 0, self.frame.size.width, CGRectGetMidY(self.bounds));
    UIView *snapshot = [self resizableSnapshotViewFromRect:snapRect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    
    [snapshot addShadowView];
    
    snapshot.userInteractionEnabled = NO;
    return snapshot;
}

- (UIView *)bottomHalf
{
    CGRect snapRect = CGRectMake(0, CGRectGetMidY(self.bounds), self.frame.size.width, CGRectGetMidY(self.bounds));
    UIView *snapshot = [self resizableSnapshotViewFromRect:snapRect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    
    [snapshot addShadowView];
    
    CGRect newFrame = CGRectOffset(snapshot.frame, 0, snapshot.bounds.size.height);
    snapshot.frame = newFrame;
    
    snapshot.userInteractionEnabled = NO;
    return snapshot;
}

- (void)addShadowView
{
    UIView *shadowView = [[UIView alloc] initWithFrame:self.bounds];
    shadowView.backgroundColor = [UIColor blackColor];
    shadowView.alpha = 0.0f;
    shadowView.tag = 999;
    [self addSubview:shadowView];
}

- (UIView *)shadowView
{
    return [self viewWithTag:999];
}
@end

const CGFloat perspectiveDepth = (1.0f / -2000.0f);

#import "AKOFlipTransitionAnimator.h"

@implementation AKOFlipTransitionAnimator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _transitionDuration = 0.45f;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _transitionDuration;
}

- (CATransform3D)makeRotationAndPerspectiveTransform:(CGFloat)angle
{
    //Apply transformation to the PLANE
    CATransform3D t = CATransform3DIdentity;
    //Add the perspective!!!
    t.m34 = perspectiveDepth;
    if (self.transitionDirection == AKOFlipTransitionDirectionVertical) {
        t = CATransform3DRotate(t, angle, 1, 0, 0);
    } else {
        t = CATransform3DRotate(t, angle, 0, 1, 0);
    }
    return t;
}

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
}

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    BOOL isVertical = (self.transitionDirection == AKOFlipTransitionDirectionVertical);
    
    UIViewController *sourceVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *destinationVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    UIView *sourceView = sourceVC.view;
    UIView *destinationView = destinationVC.view;
    
    UIView *sourceSnapshot = [sourceView snapshotViewAfterScreenUpdates:NO];
    UIView *destinationSnapshot = [destinationView snapshotViewAfterScreenUpdates:YES];
    
    CGFloat w = CGRectGetWidth(sourceSnapshot.frame);
    CGFloat h = CGRectGetHeight(sourceSnapshot.frame) / 2.0f;
    
    UIView *sourceLeadingView = isVertical ? [sourceSnapshot topHalf] : [sourceSnapshot leftHalf];
    UIView *sourceTrailingView = isVertical ? [sourceSnapshot bottomHalf] : [sourceSnapshot rightHalf];
    
    UIView *destinationLeadingView = isVertical ? [destinationSnapshot topHalf] : [destinationSnapshot leftHalf];
    UIView *destinationTrailingView = isVertical ? [destinationSnapshot bottomHalf] : [destinationSnapshot rightHalf];

    
    CGFloat midShadow = 0.2f;
    CGFloat maxShadow = 0.7f;
    
    [containerView addSubview:sourceLeadingView];
    [containerView addSubview:sourceTrailingView];
    
    
    if (self.presenting) {
        // PUSH
        
        [containerView insertSubview:destinationVC.view belowSubview:sourceLeadingView];
        
        [containerView addSubview:destinationLeadingView];
        [containerView insertSubview:destinationTrailingView aboveSubview:destinationVC.view];
        
        sourceTrailingView.layer.anchorPoint = isVertical ? CGPointMake(0.5, 0.0) : CGPointMake(0.0, 0.5);
        destinationLeadingView.layer.anchorPoint = isVertical ? CGPointMake(0.5, 1.0) : CGPointMake(1.0, 0.5);

         // Make it already halfway rotated
        destinationLeadingView.layer.transform = isVertical ? CATransform3DMakeRotation(-M_PI/2.0f, 1, 0, 0) : CATransform3DMakeRotation(M_PI/2.0f, 0, 1, 0);

        CGRect newFrame = sourceTrailingView.frame;
        newFrame.origin = isVertical ? CGPointMake(0, CGRectGetHeight(sourceTrailingView.frame)) : CGPointMake(CGRectGetWidth(sourceTrailingView.frame), 0);
        
        sourceTrailingView.frame = newFrame;
        destinationLeadingView.frame = sourceLeadingView.frame;
        
        
        [destinationLeadingView shadowView].alpha = midShadow;
        [destinationTrailingView shadowView].alpha = maxShadow;
        
        [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                       delay:0
                                     options:0
                                  animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0.0
                                                              relativeDuration:0.5
                                                                    animations:
                                       ^{
                                           CGFloat angle = DegreesToRadians( isVertical ? 90 : -90);
                                           sourceTrailingView.layer.transform = [self makeRotationAndPerspectiveTransform:angle];
                                           [sourceTrailingView shadowView].alpha = midShadow;
                                           [destinationTrailingView shadowView].alpha = 0;
                                       }];
                                      
                                      [UIView addKeyframeWithRelativeStartTime:0.5
                                                              relativeDuration:0.5
                                                                    animations:
                                       ^{
                                           CGFloat angle = DegreesToRadians(0);
                                           destinationLeadingView.layer.transform = [self makeRotationAndPerspectiveTransform:angle];
                                           [sourceLeadingView shadowView].alpha = maxShadow;
                                           [destinationLeadingView shadowView].alpha = 0;
                                       }];
                                  }
                                  completion:^(BOOL finished){
                                      [sourceTrailingView removeFromSuperview];
                                      [sourceLeadingView removeFromSuperview];
                                      [destinationLeadingView removeFromSuperview];
                                      [destinationTrailingView removeFromSuperview];
                                      
                                      BOOL completed = ![transitionContext transitionWasCancelled];
                                      [transitionContext completeTransition:completed];
                                  }
         ];
        
    }else{
        // POP
        
        [containerView addSubview:destinationTrailingView];
        
        [destinationTrailingView setFrame:CGRectMake(0, h, w, 0)];
        
        [containerView insertSubview:destinationVC.view belowSubview:sourceLeadingView];
        [containerView insertSubview:destinationLeadingView aboveSubview:destinationVC.view];
        
        
        sourceLeadingView.layer.anchorPoint = isVertical ? CGPointMake(0.5, 1.0) : CGPointMake(1.0, 0.5);
        destinationTrailingView.layer.anchorPoint = isVertical ? CGPointMake(0.5, 0.0) : CGPointMake(0.0, 0.5);
        
        // Make it already halfway rotated
        destinationTrailingView.layer.transform = isVertical ? CATransform3DMakeRotation(M_PI/2.0f, 1, 0, 0) : CATransform3DMakeRotation(-M_PI/2.0f, 0, 1, 0);
        
        sourceLeadingView.frame = CGRectMake(0, 0, sourceLeadingView.frame.size.width, sourceLeadingView.frame.size.height);
        destinationTrailingView.frame = sourceTrailingView.frame;
        
        [destinationLeadingView shadowView].alpha = maxShadow;
        [destinationTrailingView shadowView].alpha = midShadow;
        
        [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                       delay:0
                                     options:0
                                  animations:^{
        
                                      [UIView addKeyframeWithRelativeStartTime:0.0
                                                              relativeDuration:0.5
                                                                    animations:
                                       ^{
                                           CGFloat angle = DegreesToRadians(isVertical ? -90 : 90);
                                           sourceLeadingView.layer.transform = [self makeRotationAndPerspectiveTransform:angle];
                                           [destinationLeadingView shadowView].alpha = 0;
                                           [sourceLeadingView shadowView].alpha = midShadow;
                                       }];
                                      
                                      
                                      [UIView addKeyframeWithRelativeStartTime:0.5
                                                              relativeDuration:0.5
                                                                    animations:
                                       ^{
                                           CGFloat angle = DegreesToRadians(0);
                                           destinationTrailingView.layer.transform = [self makeRotationAndPerspectiveTransform:angle];
                                           [sourceTrailingView shadowView].alpha = maxShadow;
                                           [destinationTrailingView shadowView].alpha = 0;
                                       }];
                                  }
                                  completion:^(BOOL finished){
                                      [sourceTrailingView removeFromSuperview];
                                      [sourceLeadingView removeFromSuperview];
                                      [destinationLeadingView removeFromSuperview];
                                      [destinationTrailingView removeFromSuperview];
                                      
                                      BOOL completed = ![transitionContext transitionWasCancelled];
                                      [transitionContext completeTransition:completed];
                                  }
         ];
        
    }
}

@end
