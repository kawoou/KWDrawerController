//
//  LeftViewController.m
//  KWDrawerViewController
//
//  Created by Kawoou on 2014. 5. 29..
//  Copyright (c) 2014년 Kawoou. All rights reserved.
//

#import "LeftViewController.h"

@interface LeftViewController ()

@end

@implementation LeftViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setFrame:CGRectMake(0, 0, 200, self.view.frame.size.height)];
    [self.view setBackgroundColor:[UIColor blueColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
