//
//  AKOViewController.m
//  AKOFlipViewController
//
//  Created by Vasilis Akoinoglou on 07/13/2014.
//  Copyright (c) 2014 Vasilis Akoinoglou. All rights reserved.
//

#import "AKOViewController.h"
#import "AKODetailViewController.h"

@interface AKOViewController ()

@end

@implementation AKOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfControllersInFlipController:(AKOFlipViewController *)flipController
{
    return 5;
}

- (UIViewController *)flipViewController:(AKOFlipViewController *)flipViewController viewControllerAtIndex:(NSUInteger)index
{
    AKODetailViewController *detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailController.image = [UIImage imageNamed:[[@(index) stringValue] stringByAppendingString:@".jpg"]];
    return detailController;
}

@end
