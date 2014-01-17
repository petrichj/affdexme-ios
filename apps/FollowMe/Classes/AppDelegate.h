//
//  AppDelegate.h
//  faceDetection
//
//  Created by Affectiva on 2/22/13.
//  Copyright (c) 2013 Affectiva All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (assign) BOOL detectorRunning;

@end
