//
//  RightViewController.m
//  KWDrawerViewController
//
//  Created by Kawoou on 2014. 5. 29..
//  Copyright (c) 2014년 Kawoou. All rights reserved.
//

#import "RightViewController.h"

@interface RightViewController ()

@end

@implementation RightViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        //[self.view setFrame:CGRectMake(0, 0, 280, self.view.frame.size.height)];
        [self.view setBackgroundColor:[UIColor redColor]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 0, 0)];
    [label setText:@"Right View Controller"];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label sizeToFit];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarAnimation)statusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (BOOL)statusBarHidden
{
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
