//
//  AKOFlipTransitionAnimator.h
//  Pods
//
//  Created by Vasilis Akoinoglou on 7/13/14.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AKOFlipTransitionDirection){
    AKOFlipTransitionDirectionVertical,
    AKOFlipTransitionDirectionHorizontal
};

@interface AKOFlipTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) NSTimeInterval transitionDuration;
@property (nonatomic, assign) AKOFlipTransitionDirection transitionDirection;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@end
