//
//  ViewController.h
//  faceDetection
//
//  Created by Affectiva on 2/22/13.
//  Copyright (c) 2013 Affectiva All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AFDXDetector.h"

@interface ViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, AFDXDetectorDelegate>

@property (weak) IBOutlet UIImageView *imageView;
@property (weak) IBOutlet UIImageView *processedImageView;
@property (strong) AVCaptureSession *session;
@property dispatch_queue_t process_queue;
@property (weak) IBOutlet UILabel *fps;
@property (weak) IBOutlet UILabel *fpsProcessed;
@property (weak) IBOutlet UILabel *detectors;
@property (weak) IBOutlet UILabel *appleDetectors;
@property (weak) IBOutlet UIImageView *ledView;
@property (strong) AFDXDetector *detector;

- (IBAction)handleButtonTouch:(UIButton *)sender;

@end
