//
//  AKOFlipTransitionAnimator.m
//  Pods
//
//  Created by Vasilis Akoinoglou on 7/13/14.
//
//

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
    t = CATransform3DRotate(t, angle, 1, 0, 0);
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

- (UIView *)shadowViewForView:(UIView *)view
{
    return [view viewWithTag:999];
}

- (UIView *)createUpperHalf:(UIView *)view
{
    CGRect snapRect = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height / 2);
    UIView *topHalf = [view resizableSnapshotViewFromRect:snapRect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    
    UIView *shadowView = [[UIView alloc] initWithFrame:topHalf.bounds];
    shadowView.backgroundColor = [UIColor blackColor];
    shadowView.alpha = 0.0f;
    shadowView.tag = 999;
    [topHalf addSubview:shadowView];
    
    topHalf.userInteractionEnabled = NO;
    return topHalf;
}

- (UIView *)createBottomHalf:(UIView *)view
{
    CGRect snapRect = CGRectMake(0, CGRectGetMidY(view.frame), view.frame.size.width, view.frame.size.height / 2);
    UIView *bottomHalf = [view resizableSnapshotViewFromRect:snapRect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    
    UIView *shadowView = [[UIView alloc] initWithFrame:bottomHalf.bounds];
    shadowView.backgroundColor = [UIColor blackColor];
    shadowView.alpha = 0.0f;
    shadowView.tag = 999;
    [bottomHalf addSubview:shadowView];
    
    CGRect newFrame = CGRectOffset(bottomHalf.frame, 0, bottomHalf.bounds.size.height);
    bottomHalf.frame = newFrame;
    
    bottomHalf.userInteractionEnabled = NO;
    return bottomHalf;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    UIViewController *sourceVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *destinationVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
    UIView *sourceView = sourceVC.view;
    UIView *destinationView = destinationVC.view;
    
    UIView *sourceSnapshot = [sourceView snapshotViewAfterScreenUpdates:NO];
    
    UIView *containerView = [transitionContext containerView];
    
    UIView *destinationSnapshot = [destinationView snapshotViewAfterScreenUpdates:YES];
    
    CGFloat w = CGRectGetWidth(sourceSnapshot.frame);
    CGFloat h = CGRectGetHeight(sourceSnapshot.frame) / 2.0f;
    
    UIView *sourceUpperView = [self createUpperHalf:sourceSnapshot];
    UIView *sourceBottomView = [self createBottomHalf:sourceSnapshot];
    
    UIView *destinationUpperView = [self createUpperHalf:destinationSnapshot];
    UIView *destinationBottomView = [self createBottomHalf:destinationSnapshot];
    
    CGFloat midShadow = 0.2f;
    CGFloat maxShadow = 0.7f;
    
    [containerView addSubview:sourceUpperView];
    [containerView addSubview:sourceBottomView];
    
    
    
    if (self.presenting) {
        // PUSH
        
        [containerView insertSubview:destinationVC.view belowSubview:sourceUpperView];
        
        [containerView addSubview:destinationUpperView];
        [containerView insertSubview:destinationBottomView aboveSubview:destinationVC.view];
        
        
        
        sourceBottomView.layer.anchorPoint = CGPointMake(0.5, 0.0);
        destinationUpperView.layer.anchorPoint = CGPointMake(0.5, 1.0);
        
        destinationUpperView.layer.transform = CATransform3DMakeRotation(-M_PI/2.0f, 1, 0, 0); // Make it already halfway rotated
        
        sourceBottomView.frame = CGRectMake(0, sourceUpperView.frame.size.height,
                                            sourceBottomView.frame.size.width,
                                            sourceBottomView.frame.size.height);
        destinationUpperView.frame = sourceUpperView.frame;
        
        
        [self shadowViewForView:destinationUpperView].alpha = midShadow;
        [self shadowViewForView:destinationBottomView].alpha = maxShadow;
        
        
        //切れ目がないアニメーション
        [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                       delay:0
                                     options:0
                                  animations:^{
                                      [UIView addKeyframeWithRelativeStartTime:0.0
                                                              relativeDuration:0.5
                                                                    animations:
                                       ^{
                                           CGFloat angle = DegreesToRadians(90);
                                           sourceBottomView.layer.transform = [self makeRotationAndPerspectiveTransform:angle];
                                           [self shadowViewForView:sourceBottomView].alpha = midShadow;
                                           [self shadowViewForView:destinationBottomView].alpha = 0;
                                       }];
                                      
                                      [UIView addKeyframeWithRelativeStartTime:0.5
                                                              relativeDuration:0.5
                                                                    animations:
                                       ^{
                                           CGFloat angle = DegreesToRadians(0);
                                           destinationUpperView.layer.transform = [self makeRotationAndPerspectiveTransform:angle];
                                           [self shadowViewForView:sourceUpperView].alpha = maxShadow;
                                           [self shadowViewForView:destinationUpperView].alpha = 0;
                                       }];
                                  }
                                  completion:^(BOOL finished){
                                      [sourceBottomView removeFromSuperview];
                                      [sourceUpperView removeFromSuperview];
                                      [destinationUpperView removeFromSuperview];
                                      [destinationBottomView removeFromSuperview];
                                      
                                      BOOL completed = ![transitionContext transitionWasCancelled];
                                      [transitionContext completeTransition:completed];
                                  }
         ];
        
    }else{
        // POP
        
        [containerView addSubview:destinationBottomView];
        
        [destinationBottomView setFrame:CGRectMake(0, h, w, 0)];
        
        [containerView insertSubview:destinationVC.view belowSubview:sourceUpperView];
        [containerView insertSubview:destinationUpperView aboveSubview:destinationVC.view];
        
        
        sourceUpperView.layer.anchorPoint = CGPointMake(0.5, 1.0);
        destinationBottomView.layer.anchorPoint = CGPointMake(0.5, 0.0);
        
        destinationBottomView.layer.transform = CATransform3DMakeRotation(M_PI/2.0f, 1, 0, 0); // Make it already halfway rotated
        
        
        sourceUpperView.frame = CGRectMake(0, 0, sourceUpperView.frame.size.width, sourceUpperView.frame.size.height);
        destinationBottomView.frame = sourceBottomView.frame;
        
        [self shadowViewForView:destinationUpperView].alpha = maxShadow;
        [self shadowViewForView:destinationBottomView].alpha = midShadow;
        
        [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                       delay:0
                                     options:0
                                  animations:^{
        
                                      [UIView addKeyframeWithRelativeStartTime:0.0
                                                              relativeDuration:0.5
                                                                    animations:
                                       ^{
                                           CGFloat angle = DegreesToRadians(-90);
                                           sourceUpperView.layer.transform = [self makeRotationAndPerspectiveTransform:angle];
                                           [self shadowViewForView:destinationUpperView].alpha = 0;
                                           [self shadowViewForView:sourceUpperView].alpha = midShadow;
                                       }];
                                      
                                      
                                      [UIView addKeyframeWithRelativeStartTime:0.5
                                                              relativeDuration:0.5
                                                                    animations:
                                       ^{
                                           CGFloat angle = DegreesToRadians(0);
                                           destinationBottomView.layer.transform = [self makeRotationAndPerspectiveTransform:angle];
                                           [self shadowViewForView:sourceBottomView].alpha = maxShadow;
                                           [self shadowViewForView:destinationBottomView].alpha = 0;
                                       }];
                                  }
                                  completion:^(BOOL finished){
                                      [sourceBottomView removeFromSuperview];
                                      [sourceUpperView removeFromSuperview];
                                      [destinationUpperView removeFromSuperview];
                                      [destinationBottomView removeFromSuperview];
                                      
                                      BOOL completed = ![transitionContext transitionWasCancelled];
                                      [transitionContext completeTransition:completed];
                                  }
         ];
        
    }
    

}

@end
