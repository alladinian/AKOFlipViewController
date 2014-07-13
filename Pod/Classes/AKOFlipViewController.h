//
//  AKOFlipViewController.h
//  AKOFlipViewController
//
//  Created by Vasilis Akoinoglou on 7/13/14.
//  Copyright (c) 2014 Vasilis Akoinoglou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKOFlipTransitionAnimator.h"
#import "AKOFlipInteractiveTransition.h"

@class AKOFlipViewController;

@protocol AKOFlipViewControllerDatasource <NSObject>
@required
- (NSUInteger)numberOfControllersInFlipController:(AKOFlipViewController *)flipController;
- (UIViewController *)flipViewController:(AKOFlipViewController *)flipViewController
                   viewControllerAtIndex:(NSUInteger)index;
@end

#pragma mark -

@interface AKOFlipViewController : UIViewController <AKOFlipViewControllerDatasource>
@property (nonatomic, weak) id <AKOFlipViewControllerDatasource> datasource;
@property (nonatomic, assign) AKOFlipTransitionDirection transitionDirection;
@end
