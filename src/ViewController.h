//
//  ViewController.h
//  
//
//  Created by Takahiro Hirata on 13/06/16.
//  Copyright (c) 2013年 takahirohirata.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *analogInputController;
@property (weak, nonatomic) IBOutlet UISlider *analogOutputController;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *modeLabel;

- (IBAction)analogOutputControllerChanged:(id)sender;

@end
