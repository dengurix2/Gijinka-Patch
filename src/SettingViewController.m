//
//  SettingViewController.m
//  
//
//  Created by hrt on 13/06/16.
//  Copyright (c) 2013年 takahirohirata.com. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setModeButtonPressed:(id)sender {
  
  [[OALSimpleAudio sharedInstance] stopAllEffects];
  
  UIButton *btn = (UIButton*)sender;
  
  ModelManager *mm = [ModelManager sharedManager];
  
  mm.mode = btn.tag;
  NSLog(@"btn.tag:%d", btn.tag);
  
  NSString *str = [NSString stringWithFormat:@"voice%d_1.wav", btn.tag+1];
  NSLog(@"str:%@", str);
  
  [[OALSimpleAudio sharedInstance] playEffect:str];
}

- (IBAction)okButtonPressed:(id)sender {
  
  [[OALSimpleAudio sharedInstance] stopAllEffects];
  
  ModelManager *mm = [ModelManager sharedManager];
  mm.isPlay = YES;
  
  [self dismissViewControllerAnimated:YES completion:^{
  }];
}

- (IBAction)reSetKonashiButtonPressed:(id)sender {
  
  [[OALSimpleAudio sharedInstance] stopAllEffects];
  
  ModelManager *mm = [ModelManager sharedManager];
  mm.isPlay = YES;
  [self dismissViewControllerAnimated:YES completion:^{
  }];
}

@end
