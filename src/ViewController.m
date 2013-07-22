//
//  ViewController.m
//  
//
//  Created by Takahiro Hirata on 13/06/16.
//  Copyright (c) 2013年 takahirohirata.com. All rights reserved.
//

#import "ViewController.h"

// Import the konashi library
#import "Konashi.h"

@interface ViewController ()

{
  int latestRatio;
  NSTimer *timer;
}

@end

@implementation ViewController

#define KEY_FOR_THE_PREVIOUS_CONNECETD_DEVICE @"thePreviousConnectedDeviceName"
#define A_INPUT_MAX 1300
#define A_INPUT_HALF A_INPUT_MAX/2

- (void)setLabel
{
  ModelManager *mm = [ModelManager sharedManager];
  switch (mm.mode) {
    case 0:
      self.modeLabel.text = @"高校生の時の彼女";
      break;
    case 1:
      self.modeLabel.text = @"メイド";
      break;
    case 2:
      self.modeLabel.text = @"お女中";
      break;
    case 3:
      self.modeLabel.text = @"部長と不倫中の...";
      break;
    case 4:
      self.modeLabel.text = @"テレビのAD";
      break;
    case 5:
      self.modeLabel.text = @"師匠";
      break;
      
    default:
      break;
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

  [self setLabel];
  
  CGSize screenSize = [[UIScreen mainScreen] bounds].size;
  if(screenSize.width == 320.0 && screenSize.height == 568.0)
  {
    self.imageView.image =  [UIImage imageNamed:@"mainBG_L.png"];
  } else {
    self.imageView.image =  [UIImage imageNamed:@"mainBG.png"];
  }
  
  
  [Konashi initialize];
  [Konashi addObserver:self selector:@selector(setup) name:KONASHI_EVENT_READY];
  
  // Try to find a previous connected device in NSUserDefaults
  // NSUserDefaultsの中で前回接続したデバイス名を探す
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *thePreviousConnectedDeviceName = [defaults stringForKey:KEY_FOR_THE_PREVIOUS_CONNECETD_DEVICE];
  
  // If there is a record of a previous connected device in NSUserDefaults
  // もし前回接続したデバイス名がNSUserDefaultsにあれば
  if (thePreviousConnectedDeviceName) {
    NSLog(@"Found the previous connected device, so let's try connecting to the device");
    
    // Try to connect to the previous connected device
    // 取得したデバイス名で接続を試みる
    [Konashi findWithName:thePreviousConnectedDeviceName];
    
    // Add an observer in preparation for failure of connecting to the prebious connected device
    // 接続に失敗した時にfind処理を行うためのオブザーバをセットする
    [Konashi addObserver:self selector:@selector(failedToConnectToThePreviousConnectedDevice) name:KONASHI_EVENT_PERIPHERAL_NOT_FOUND];
  } else {
    // If there is a no recoard of a previous connected device, execute find to let the user choose a konashi module
    // 前回接続されたデバイス名がNSUserDefaultsの中になければfindを実行してユーザに接続を促す
    [Konashi find];
  }
  
  ModelManager *mm = [ModelManager sharedManager];
  NSString *str = [NSString stringWithFormat:@"voice%d_2.wav", mm.mode+1];
  NSLog(@"str:%@", str);
  [[OALSimpleAudio sharedInstance] playEffect:str];
  
}

- (void)viewDidAppear:(BOOL)animated
{
  [self setLabel];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)failedToConnectToThePreviousConnectedDevice
{
  NSLog(@"Failed to connect to the previous connected device");
  
  // If failed to the previous connected device, execute find to let the user choose another konashi module
  // 前回接続されたデバイス名に接続できなければfindを実行してユーザに接続を促す
  [Konashi find];
}

- (void)setup
{
  NSString *name = [Konashi peripheralName];
  NSLog(@"Connected to %s", name.UTF8String);

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:name forKey:KEY_FOR_THE_PREVIOUS_CONNECETD_DEVICE];

  BOOL successful = [defaults synchronize];
  if (successful) {
    NSLog(@"Saved to NSUserDefaults successfully");
  } else {
    NSLog(@"Failed saving to NSUserDefaults");
  }

  // Set mode for each pin
  [Konashi pinMode:S1 mode:INPUT];
  [Konashi pinMode:LED2 mode:OUTPUT];
  [Konashi pinMode:LED3 mode:OUTPUT];
  [Konashi pwmMode:LED2 mode:KONASHI_PWM_ENABLE_LED_MODE];
  [Konashi pwmMode:LED3 mode:KONASHI_PWM_ENABLE_LED_MODE];

  // Add an observer to observe changes on AIO0
  [Konashi addObserver:self selector:@selector(analogInputUpdated) name:KONASHI_EVENT_UPDATE_ANALOG_VALUE_AIO0];
  
  // Create and fire a timer to request reading AIO0
  NSTimer *analogInputTimer = [NSTimer
                               scheduledTimerWithTimeInterval:0.1f
                               target:self
                               selector:@selector(requestAnalogRead:)
                               userInfo:nil
                               repeats:YES
                               ];
  [analogInputTimer fire];
}

- (void)requestAnalogRead:(NSTimer*)timer
{
    [Konashi analogReadRequest:AIO0];
}

//アナログ入力
- (void)analogInputUpdated
{
 
  if(timer.isValid){
    return;
  }
  
  ModelManager *mm = [ModelManager sharedManager];
  if (mm.isPlay==NO) {
    return;
  }
  
  float voltage = [Konashi analogRead:AIO0];
  float _voltage = voltage - 699.5;
  
  float v_rate = (_voltage);
  
  //LED点灯
  int ratio = fabs(latestRatio - v_rate);
  
  
  [Konashi pwmLedDrive:LED2 dutyRatio:ratio];
  [Konashi pwmLedDrive:LED3 dutyRatio:ratio];
  //NSLog(@"%.2f, %.2f, %.2f, %d", voltage, _voltage, v_rate, ratio);
 
  int limit1 = 20;
  int limtt2 = 80;
  int limtt3 = 1000;
  if (limit1<=ratio && ratio<limtt2) {
    NSString *str = [NSString stringWithFormat:@"voice%d_3.wav", mm.mode+1];
    NSLog(@"str:%@", str);
    [[OALSimpleAudio sharedInstance] playEffect:str];
    
     timer = [NSTimer scheduledTimerWithTimeInterval:1.5f
     target:self
     selector:@selector(hogeMethod:)
     userInfo:nil
     repeats:NO];
    
    
  } else if (limtt2<=ratio && ratio<limtt3) {
    //[[OALSimpleAudio sharedInstance] stopAllEffects];
    NSString *str = [NSString stringWithFormat:@"voice%d_4.wav", mm.mode+1];
    NSLog(@"str:%@", str);
    [[OALSimpleAudio sharedInstance] playEffect:str loop:NO];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                             target:self
                                           selector:@selector(hogeMethod:)
                                           userInfo:nil
                                            repeats:NO];
    
  }
  
  latestRatio = v_rate;
}

-(void)hogeMethod:(NSTimer*)timer{
  //何もしない
}

- (IBAction)analogOutputControllerChanged:(id)sender {
  int ratio = (int)round([self.analogOutputController value]);
  NSLog(@"%d", ratio);
  [Konashi pwmLedDrive:LED2 dutyRatio:ratio];
  [Konashi pwmLedDrive:LED3 dutyRatio:ratio];
}

- (IBAction)settingButtonPressed:(id)sender {
  
  [[OALSimpleAudio sharedInstance] stopAllEffects];
  ModelManager *mm = [ModelManager sharedManager];
  mm.isPlay = NO;
  
  self.modeLabel.text = @"";
}

@end
