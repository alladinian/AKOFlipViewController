//
//  AKOFlipInteractiveTransition.m
//  Pods
//
//  Created by Vasilis Akoinoglou on 7/13/14.
//
//

#import "AKOFlipInteractiveTransition.h"

@interface AKOPanGestureRecognizer : UIPanGestureRecognizer
@end
@implementation AKOPanGestureRecognizer
@end

@implementation AKOFlipInteractiveTransition

- (void)setView:(UIView *)view
{
    _view = view;
    for (UIPanGestureRecognizer *r in view.gestureRecognizers) {
        if ([r isKindOfClass:[AKOPanGestureRecognizer class]]) {
            [view removeGestureRecognizer:r];
        }
    }
    UIPanGestureRecognizer *gesture = [[AKOPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:gesture];
}

- (void)handlePan:(AKOPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            //NSLog(@"Gesture began...");
            
//            CGPoint nowPoint = [gesture locationInView:self.view];
//            CGFloat boundary = CGRectGetMidY(self.view.frame);
            CGPoint velocity = [gesture velocityInView:self.view];
            
            BOOL isDownwards = (velocity.y > 0);
            
            if (isDownwards) {
                //NSLog(@"Downwards...");
            } else {
                //NSLog(@"Upwards...");
            }
            
            
            //NSLog(@"Point: %@ | Boundary: %@", NSStringFromCGPoint(nowPoint), @(boundary));
            self.presenting = !isDownwards;
            
            if (self.isPresenting) {
                [self.delegate presentInteractive];
            } else {
                [self.delegate dismissInteractive];
            }
            
            //NSLog(@"MODE: %@", self.isPushMode ? @"PUSH" : @"POP");
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGRect viewRect = self.view.bounds;
            CGPoint translation = [gesture translationInView:self.view];
            CGFloat percent = translation.y / viewRect.size.height;
            percent = fabsf(percent);
            percent = MIN(1.0, MAX(0.0, percent));
            [self updateInteractiveTransition:percent];
            
            //NSLog(@"Gesture changed...");
            //NSLog(@"Translation: %@ | Percent: %@", NSStringFromCGPoint(translation), @(percent));
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            CGPoint nowPoint = [gesture locationInView:self.view];
            CGFloat boundary = (self.view.frame.origin.y + (self.view.frame.size.height / 2));
            if (self.isPresenting){
                if (boundary > nowPoint.y) {
                    [self finishInteractiveTransition];
                } else {
                    [self cancelInteractiveTransition];
                }
            } else {
                if (boundary < nowPoint.y) {
                    [self finishInteractiveTransition];
                    [self.delegate completePopTransition];
                }else{
                    [self cancelInteractiveTransition];
                }
            }
            break;
        }
        default:
            break;
    }
}

@end
