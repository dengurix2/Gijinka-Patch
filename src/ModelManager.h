//
//  ModelManager.h
//
//
//  Created by TAKAHIRO HIRATA on 13/06/16.
//  Copyright (c) 2013 takahirohirata.com. All rights reserved.
//

@interface ModelManager : NSObject 

@property (nonatomic) int mode;
@property (nonatomic) BOOL isPlay;

+ (ModelManager*)sharedManager;

@end
