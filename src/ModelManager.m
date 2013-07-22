//
//  ModelManager.m
//  
//
//  Created by TAKAHIRO HIRATA on 13/06/16.
//  Copyright (c) 2013 takahirohirata.com. All rights reserved.
//


#import "ModelManager.h"

@interface ModelManager ()
@end

@implementation ModelManager

+ (ModelManager*)sharedManager {
  static ModelManager* sharedSingleton;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedSingleton = [[ModelManager alloc]
                       initSharedInstance];
  });
  return sharedSingleton;
}

- (id)initSharedInstance {
  self = [super init];
  if (self) {
    // 初期化処理
  }
  return self;
}

- (id)init {
  [self doesNotRecognizeSelector:_cmd];
  return nil;
}

@end
