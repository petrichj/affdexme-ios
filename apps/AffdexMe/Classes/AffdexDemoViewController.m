//
//  AffdexDemoViewController.m
//
//  Created by Affectiva on 2/22/13.
//  Copyright (c) 2013 Affectiva All rights reserved.
//

// If this feature is turned on, then emotions and expressions will be sent via UDP
#undef BROADCAST_VIA_UDP
#ifdef BROADCAST_VIA_UDP
#define MULTICAST_GROUP @"224.0.1.1"
#define MULTICAST_PORT 12345
#endif

// If this is being compiled for the iOS simulator, a demo mode is used since the camera isn't supported.
#if TARGET_IPHONE_SIMULATOR
#define DEMO_MODE
#endif

#import "UIDeviceHardware.h"
#import "AffdexDemoViewController.h"
#ifdef BROADCAST_VIA_UDP
#import "GCDAsyncUdpSocket.h"
#endif
#import <CoreMotion/CoreMotion.h>
#import "EmotionPickerViewController.h"

@interface AffdexDemoViewController ()

@property (strong) NSDate *dateOfLastFrame;
@property (strong) NSDate *dateOfLastProcessedFrame;
@property (strong) NSDictionary *entries;
@property (strong) NSEnumerator *entryEnumerator;
@property (strong) NSDictionary *jsonEntry;
@property (strong) NSDictionary *videoEntry;
@property (strong) NSString *jsonFilename;
@property (strong) NSString *mediaFilename;

@property (strong) NSMutableArray *facePointsToDraw;
@property (strong) NSMutableArray *faceRectsToDraw;
@property (strong) NSMutableArray *viewControllers;
@property (strong) NSMutableArray *selectedClassifiers;
#ifdef BROADCAST_VIA_UDP
@property (strong) GCDAsyncUdpSocket *udpSocket;
#endif

@property (strong) NSMutableArray *availableClassifiers; // the arry of dictionaries which contain all available classifiers
@property (strong) NSArray *emotions;   // the array of dictionaries of all emotion classifiers
@property (strong) NSArray *expressions; // the array of dictionaries of all expression classifiers

// AffdexMe supports up to 8 classifers on the screen at a time
@property (strong) NSString *classifier1Name;
@property (strong) NSString *classifier2Name;
@property (strong) NSString *classifier3Name;
@property (strong) NSString *classifier4Name;
@property (strong) NSString *classifier5Name;
@property (strong) NSString *classifier6Name;
@property (strong) NSString *classifier7Name;
@property (strong) NSString *classifier8Name;

@property (strong) CMMotionManager *motionManager;

@end

@implementation AffdexDemoViewController

#pragma mark -
#pragma mark AFDXDetectorDelegate Methods

#ifdef DEMO_MODE
- (void)detectorDidFinishProcessing:(AFDXDetector *)detector;
{
    [self stopDetector];
}
#endif

- (void)processedImageReady:(AFDXDetector *)detector image:(UIImage *)image faces:(NSDictionary *)faces atTime:(NSTimeInterval)time;
{
    NSDate *now = [NSDate date];
    
    if (nil != self.dateOfLastProcessedFrame)
    {
        NSTimeInterval interval = [now timeIntervalSinceDate:self.dateOfLastProcessedFrame];
        
        if (interval > 0)
        {
            float fps = 1.0 / interval;
            self.fpsProcessed.text = [NSString stringWithFormat:@"FPS(P): %.1f", fps];
        }
    }
    
    self.dateOfLastProcessedFrame = now;
    
    // setup arrays of points and rects
    self.facePointsToDraw = [NSMutableArray new];
    self.faceRectsToDraw = [NSMutableArray new];
    
    // Handle each metric in the array
    for (NSNumber *key in [faces allKeys])
    {
        AFDXFace *face = [faces objectForKey:key];
        NSDictionary *faceData = face.userInfo;
        NSArray *viewControllers = [faceData objectForKey:@"viewControllers"];

        __block float classifier1Score = 0.0, classifier2Score = 0.0, classifier3Score = 0.0;
        __block float classifier4Score = 0.0, classifier5Score = 0.0, classifier6Score = 0.0;
        __block float classifier7Score = 0.0, classifier8Score = 0.0;
        
        [self.facePointsToDraw addObjectsFromArray:face.facePoints];
        [self.faceRectsToDraw addObject:[NSValue valueWithCGRect:face.faceBounds]];

        for (ExpressionViewController *v in viewControllers)
        {
            for (NSDictionary *d in self.availableClassifiers)
            {
                if ([[d objectForKey:@"name"] isEqualToString:self.classifier1Name])
                {
                    NSString *scoreName = [d objectForKey:@"score"];
                    classifier1Score = [[face valueForKey:scoreName] floatValue];
                }
                if ([[d objectForKey:@"name"] isEqualToString:self.classifier2Name])
                {
                    NSString *scoreName = [d objectForKey:@"score"];
                    classifier2Score = [[face valueForKey:scoreName] floatValue];
                }
                if ([[d objectForKey:@"name"] isEqualToString:self.classifier3Name])
                {
                    NSString *scoreName = [d objectForKey:@"score"];
                    classifier3Score = [[face valueForKey:scoreName] floatValue];
                }
                if ([[d objectForKey:@"name"] isEqualToString:self.classifier4Name])
                {
                    NSString *scoreName = [d objectForKey:@"score"];
                    classifier4Score = [[face valueForKey:scoreName] floatValue];
                }
                if ([[d objectForKey:@"name"] isEqualToString:self.classifier5Name])
                {
                    NSString *scoreName = [d objectForKey:@"score"];
                    classifier5Score = [[face valueForKey:scoreName] floatValue];
                }
                if ([[d objectForKey:@"name"] isEqualToString:self.classifier6Name])
                {
                    NSString *scoreName = [d objectForKey:@"score"];
                    classifier6Score = [[face valueForKey:scoreName] floatValue];
                }
                if ([[d objectForKey:@"name"] isEqualToString:self.classifier7Name])
                {
                    NSString *scoreName = [d objectForKey:@"score"];
                    classifier7Score = [[face valueForKey:scoreName] floatValue];
                }
                if ([[d objectForKey:@"name"] isEqualToString:self.classifier8Name])
                {
                    NSString *scoreName = [d objectForKey:@"score"];
                    classifier8Score = [[face valueForKey:scoreName] floatValue];
                }
            }

            if ([v.name isEqualToString:self.classifier1Name])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    v.metric = classifier1Score;
                });
            }
            else if ([v.name isEqualToString:self.classifier2Name])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    v.metric = classifier2Score;
                });
            }
            else if ([v.name isEqualToString:self.classifier3Name])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    v.metric = classifier3Score;
                });
            }
            else if ([v.name isEqualToString:self.classifier4Name])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    v.metric = classifier4Score;
                });
            }
            else if ([v.name isEqualToString:self.classifier5Name])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    v.metric = classifier5Score;
                });
            }
            else if ([v.name isEqualToString:self.classifier6Name])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    v.metric = classifier6Score;
                });
            }
            else if ([v.name isEqualToString:self.classifier7Name])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    v.metric = classifier7Score;
                });
            }
            else if ([v.name isEqualToString:self.classifier8Name])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    v.metric = classifier8Score;
                });
            }

#ifdef BROADCAST_VIA_UDP
            char buffer[7];
            for (NSUInteger i = 0; i < [self.availableClassifiers count]; i++)
            {
                NSDictionary *entry = [self.availableClassifiers objectAtIndex:i];
                NSString *scoreName = [entry objectForKey:@"score"];
                CGFloat score = [[face valueForKey:scoreName] floatValue];
                buffer[i] = (char)(isnan(score) ? 0 : score);
            }
            NSData *d = [NSData dataWithBytes:buffer length:sizeof(buffer)];
            [self.udpSocket sendData:d toHost:MULTICAST_GROUP port:MULTICAST_PORT withTimeout:-1 tag:0];
#endif
        }
    }
};

- (void)unprocessedImageReady:(AFDXDetector *)detector image:(UIImage *)image atTime:(NSTimeInterval)time;
{
    __block AffdexDemoViewController *weakSelf = self;
    if (TRUE == self.drawFacePoints || TRUE == self.drawFaceRect)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *pointsImage = [detector imageByDrawingPoints:weakSelf.drawFacePoints ? weakSelf.facePointsToDraw : nil
                                                    andRectangles:weakSelf.drawFaceRect ? weakSelf.faceRectsToDraw : nil
                                                       withRadius:1.4
                                                  usingPointColor:[UIColor whiteColor]
                                              usingRectangleColor:[UIColor whiteColor]
                                                          onImage:image];
            UIImage *flippedImage = [UIImage imageWithCGImage:pointsImage.CGImage scale:pointsImage.scale orientation:UIImageOrientationUpMirrored];
            [self.imageView setImage:flippedImage];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *flippedImage = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationUpMirrored];
            [self.imageView setImage:flippedImage];
            [weakSelf.imageView setImage:flippedImage];
        });
    }
    
#ifdef DEMO_MODE
    static NSTimeInterval last = 0;
    const CGFloat timeConstant = 0.0000001;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:(time - last) * timeConstant]];
    last = time;
#endif
    
    // compute frames per second and show
    NSDate *now = [NSDate date];
    
    if (nil != weakSelf.dateOfLastFrame)
    {
        NSTimeInterval interval = [now timeIntervalSinceDate:weakSelf.dateOfLastFrame];
        
        if (interval > 0)
        {
            float fps = 1.0 / interval;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.fps.text = [NSString stringWithFormat:@"FPS(C): %.1f", fps];
            });
        }
    }
    
    weakSelf.dateOfLastFrame = now;
}

- (void)detector:(AFDXDetector *)detector hasResults:(NSMutableDictionary *)faces forImage:(UIImage *)image atTime:(NSTimeInterval)time;
{
    if (nil == faces)
    {
        [self unprocessedImageReady:detector image:image atTime:time];
    }
    else
    {
        [self processedImageReady:detector image:image faces:faces atTime:time];
    }
}

- (void)detector:(AFDXDetector *)detector didStartDetectingFace:(AFDXFace *)face;
{
    __block AffdexDemoViewController *weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL iPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        
        if (iPhone == TRUE)
        {
            weakSelf.classifier1View_compact.alpha = 1.0;
            weakSelf.classifier2View_compact.alpha = 1.0;
            weakSelf.classifier3View_compact.alpha = 1.0;
            weakSelf.classifier4View_compact.alpha = 1.0;
            weakSelf.classifier5View_compact.alpha = 1.0;
            weakSelf.classifier6View_compact.alpha = 1.0;
            weakSelf.classifier7View_compact.alpha = 1.0;
            weakSelf.classifier8View_compact.alpha = 1.0;
        }
        else
        {
            weakSelf.classifier1View_regular.alpha = 1.0;
            weakSelf.classifier2View_regular.alpha = 1.0;
            weakSelf.classifier3View_regular.alpha = 1.0;
            weakSelf.classifier4View_regular.alpha = 1.0;
            weakSelf.classifier5View_regular.alpha = 1.0;
            weakSelf.classifier6View_regular.alpha = 1.0;
            weakSelf.classifier7View_regular.alpha = 1.0;
            weakSelf.classifier8View_regular.alpha = 1.0;
        }
        
        [UIView commitAnimations];
        
        if (weakSelf.viewControllers != nil)
        {
            face.userInfo = @{@"viewControllers" : weakSelf.viewControllers};
    #ifdef BROADCAST_VIA_UDP
            char buffer[2];
            buffer[0] = (char)face.faceId;
            buffer[1] = 1;
            NSData *d = [NSData dataWithBytes:buffer length:sizeof(buffer)];
            [weakSelf.udpSocket sendData:d toHost:MULTICAST_GROUP port:MULTICAST_PORT withTimeout:-1 tag:0];
    #endif
        }
    });
}

- (void)detector:(AFDXDetector *)detector didStopDetectingFace:(AFDXFace *)face;
{
    __block AffdexDemoViewController *weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL iPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        
        if (iPhone == TRUE)
        {
            weakSelf.classifier1View_compact.alpha = 0.0;
            weakSelf.classifier2View_compact.alpha = 0.0;
            weakSelf.classifier3View_compact.alpha = 0.0;
            weakSelf.classifier4View_compact.alpha = 0.0;
            weakSelf.classifier5View_compact.alpha = 0.0;
            weakSelf.classifier6View_compact.alpha = 0.0;
            weakSelf.classifier7View_compact.alpha = 0.0;
            weakSelf.classifier8View_compact.alpha = 0.0;
        }
        else
        {
            weakSelf.classifier1View_regular.alpha = 0.0;
            weakSelf.classifier2View_regular.alpha = 0.0;
            weakSelf.classifier3View_regular.alpha = 0.0;
            weakSelf.classifier4View_regular.alpha = 0.0;
            weakSelf.classifier5View_regular.alpha = 0.0;
            weakSelf.classifier6View_regular.alpha = 0.0;
            weakSelf.classifier7View_regular.alpha = 0.0;
            weakSelf.classifier8View_regular.alpha = 0.0;
        }
        
        [UIView commitAnimations];
        
        face.userInfo = nil;
#ifdef BROADCAST_VIA_UDP
        char buffer[2];
        buffer[0] = (char)face.faceId;
        buffer[1] = 0;
        NSData *d = [NSData dataWithBytes:buffer length:sizeof(buffer)];
        [weakSelf.udpSocket sendData:d toHost:MULTICAST_GROUP port:MULTICAST_PORT withTimeout:-1 tag:0];
#endif
    });
}


#pragma mark -
#pragma mark ViewController Delegate Methods

+ (void)initialize;
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"drawFacePoints" : [NSNumber numberWithBool:YES]}];
}

-(BOOL)canBecomeFirstResponder;
{
    return YES;
}

- (void)dealloc;
{
    self.detector = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForBackground:(id)sender;
{
#ifdef BROADCAST_VIA_UDP
    self.udpSocket = nil;
#endif
    [self stopDetector];
}

- (void)prepareForForeground:(id)sender;
{
    [self startDetector];
#ifdef BROADCAST_VIA_UDP
    dispatch_queue_t q = dispatch_queue_create("udp", 0);
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithSocketQueue:q];
#endif
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.emotions = @[@{@"name" : @"Anger", @"propertyName" : @"anger", @"score": @"angerScore"},
                          @{@"name" : @"Contempt", @"propertyName" : @"contempt", @"score": @"contemptScore"},
                          @{@"name" : @"Disgust", @"propertyName" : @"disgust", @"score": @"disgustScore"},
                          @{@"name" : @"Expressiveness", @"propertyName" : @"expressiveness", @"score": @"expressivenessScore"},
                          @{@"name" : @"Fear", @"propertyName" : @"fear", @"score": @"fearScore"},
                          @{@"name" : @"Joy", @"propertyName" : @"joy", @"score": @"joyScore"},
                          @{@"name" : @"Sadness", @"propertyName" : @"sadness", @"score": @"sadnessScore"},
                          @{@"name" : @"Surprise", @"propertyName" : @"surprise", @"score": @"surpriseScore"},
                          @{@"name" : @"Valence", @"propertyName" : @"valence", @"score": @"valenceScore"}
                          ];
        
        self.expressions = @[@{@"name" : @"Attention", @"propertyName" : @"attention", @"score": @"attentionScore"},
                             @{@"name" : @"Brow Furrow", @"propertyName" : @"browFurrow", @"score": @"browFurrowScore"},
                             @{@"name" : @"Brow Raise", @"propertyName" : @"browRaise", @"score": @"browRaiseScore"},
                             @{@"name" : @"Chin Raise", @"propertyName" : @"chinRaise", @"score": @"chinRaiseScore"},
                             @{@"name" : @"Eye Closure", @"propertyName" : @"eyeClosure", @"score": @"eyeClosureScore"},
                             @{@"name" : @"Inner Brow Raise", @"propertyName" : @"innerBrowRaise", @"score": @"innerBrowRaiseScore"},
                             @{@"name" : @"Lip Depressor", @"propertyName" : @"lipDepressor", @"score": @"lipDepressorScore"},
                             @{@"name" : @"Lip Press", @"propertyName" : @"lipPress", @"score": @"lipPressScore"},
                             @{@"name" : @"Lip Pucker", @"propertyName" : @"lipPucker", @"score": @"lipPuckerScore"},
                             @{@"name" : @"Lip Suck", @"propertyName" : @"lipSuck", @"score": @"lipSuckScore"},
                             @{@"name" : @"Mouth Open", @"propertyName" : @"mouthOpen", @"score": @"mouthOpenScore"},
                             @{@"name" : @"Nose Wrinkle", @"propertyName" : @"noseWrinkle", @"score": @"noseWrinkleScore"},
                             @{@"name" : @"Smile", @"propertyName" : @"smile", @"score": @"smileScore"},
                             @{@"name" : @"Smirk", @"propertyName" : @"smirk", @"score": @"smirkScore"},
                             @{@"name" : @"Upper Lip Raise", @"propertyName" : @"upperLipRaise", @"score": @"upperLipRaiseScore"},
                          ];
        
        self.availableClassifiers = [NSMutableArray arrayWithArray:self.emotions];
        [self.availableClassifiers addObjectsFromArray:self.expressions];
        
        self.selectedClassifiers = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedClassifiers"] mutableCopy];
        if (self.selectedClassifiers == nil)
        {
            self.selectedClassifiers = [NSMutableArray arrayWithObjects:@"Joy", @"Sadness", @"Anger", @"Contempt", @"Disgust", @"Fear", @"Surprise", @"Valence", nil];
        }
    }
    
    return self;
}

- (void)viewDidLoad;
{
    [super viewDidLoad];

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *shortVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    self.versionLabel.text = [NSString stringWithFormat:@"%@ (%@)", shortVersion, version];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareForBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareForForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [self resignFirstResponder];
    
    [super viewWillDisappear:animated];
    
    [self stopDetector];

    for (ExpressionViewController *vc in self.viewControllers)
    {
        [vc.view removeFromSuperview];
    }
    
    self.viewControllers = nil;
}

- (void)viewWillAppear:(BOOL)animated;
{
    self.versionLabel.hidden = TRUE;
    [self.imageView setImage:nil];
    
    NSUInteger count = [self.selectedClassifiers count];
    self.classifier1Name = count >= 1 ? [self.selectedClassifiers objectAtIndex:0] : nil;
    self.classifier2Name = count >= 2 ? [self.selectedClassifiers objectAtIndex:1] : nil;
    self.classifier3Name = count >= 3 ? [self.selectedClassifiers objectAtIndex:2] : nil;
    self.classifier4Name = count >= 4 ? [self.selectedClassifiers objectAtIndex:3] : nil;
    self.classifier5Name = count >= 5 ? [self.selectedClassifiers objectAtIndex:4] : nil;
    self.classifier6Name = count >= 6 ? [self.selectedClassifiers objectAtIndex:5] : nil;
    self.classifier7Name = count >= 7 ? [self.selectedClassifiers objectAtIndex:6] : nil;
    self.classifier8Name = count >= 8 ? [self.selectedClassifiers objectAtIndex:7] : nil;
    
    BOOL iPhone = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);

    [super viewWillAppear:animated];
    
    // setup views
    if (iPhone == TRUE)
    {
        [self.classifier1View_compact setBackgroundColor:[UIColor clearColor]];
        [self.classifier2View_compact setBackgroundColor:[UIColor clearColor]];
        [self.classifier3View_compact setBackgroundColor:[UIColor clearColor]];
        [self.classifier4View_compact setBackgroundColor:[UIColor clearColor]];
        [self.classifier5View_compact setBackgroundColor:[UIColor clearColor]];
        [self.classifier6View_compact setBackgroundColor:[UIColor clearColor]];
        [self.classifier7View_compact setBackgroundColor:[UIColor clearColor]];
        [self.classifier8View_compact setBackgroundColor:[UIColor clearColor]];

        self.classifier1View_compact.alpha = 0.0;
        self.classifier2View_compact.alpha = 0.0;
        self.classifier3View_compact.alpha = 0.0;
        self.classifier4View_compact.alpha = 0.0;
        self.classifier5View_compact.alpha = 0.0;
        self.classifier6View_compact.alpha = 0.0;
        self.classifier7View_compact.alpha = 0.0;
        self.classifier8View_compact.alpha = 0.0;
    }
    else
    {
        [self.classifier1View_regular setBackgroundColor:[UIColor clearColor]];
        [self.classifier2View_regular setBackgroundColor:[UIColor clearColor]];
        [self.classifier3View_regular setBackgroundColor:[UIColor clearColor]];
        [self.classifier4View_regular setBackgroundColor:[UIColor clearColor]];
        [self.classifier5View_regular setBackgroundColor:[UIColor clearColor]];
        [self.classifier6View_regular setBackgroundColor:[UIColor clearColor]];
        [self.classifier7View_regular setBackgroundColor:[UIColor clearColor]];
        [self.classifier8View_regular setBackgroundColor:[UIColor clearColor]];

        self.classifier1View_regular.alpha = 0.0;
        self.classifier2View_regular.alpha = 0.0;
        self.classifier3View_regular.alpha = 0.0;
        self.classifier4View_regular.alpha = 0.0;
        self.classifier5View_regular.alpha = 0.0;
        self.classifier6View_regular.alpha = 0.0;
        self.classifier7View_regular.alpha = 0.0;
        self.classifier8View_regular.alpha = 0.0;
    }
    
    // create the expression view controllers to hold the expressions for this face

    self.viewControllers = [NSMutableArray new];
    if (self.classifier1Name != nil)
    {
        ExpressionViewController *vc = [[ExpressionViewController alloc] initWithName:self.classifier1Name deviceIsPhone:iPhone];
        [self.viewControllers addObject:vc];
        iPhone == TRUE ? [self.classifier1View_compact addSubview:vc.view] : [self.classifier1View_regular addSubview:vc.view];
    }

    if (self.classifier2Name != nil)
    {
        ExpressionViewController *vc = [[ExpressionViewController alloc] initWithName:self.classifier2Name deviceIsPhone:iPhone];
        [self.viewControllers addObject:vc];
        iPhone == TRUE ? [self.classifier2View_compact addSubview:vc.view] : [self.classifier2View_regular addSubview:vc.view];
    }
    
    if (self.classifier3Name != nil)
    {
        ExpressionViewController *vc = [[ExpressionViewController alloc] initWithName:self.classifier3Name deviceIsPhone:iPhone];
        [self.viewControllers addObject:vc];
        iPhone == TRUE ? [self.classifier3View_compact addSubview:vc.view] : [self.classifier3View_regular addSubview:vc.view];
    }

    if (self.classifier4Name != nil)
    {
        ExpressionViewController *vc = [[ExpressionViewController alloc] initWithName:self.classifier4Name deviceIsPhone:iPhone];
        [self.viewControllers addObject:vc];
        iPhone == TRUE ? [self.classifier4View_compact addSubview:vc.view] : [self.classifier4View_regular addSubview:vc.view];
    }
    
    if (self.classifier5Name != nil)
    {
        ExpressionViewController *vc = [[ExpressionViewController alloc] initWithName:self.classifier5Name deviceIsPhone:iPhone];
        [self.viewControllers addObject:vc];
        iPhone == TRUE ? [self.classifier5View_compact addSubview:vc.view] : [self.classifier5View_regular addSubview:vc.view];
    }

    if (self.classifier6Name != nil)
    {
        ExpressionViewController *vc = [[ExpressionViewController alloc] initWithName:self.classifier6Name deviceIsPhone:iPhone];
        [self.viewControllers addObject:vc];
        iPhone == TRUE ? [self.classifier6View_compact addSubview:vc.view] : [self.classifier6View_regular addSubview:vc.view];
    }

    if (self.classifier7Name != nil)
    {
        ExpressionViewController *vc = [[ExpressionViewController alloc] initWithName:self.classifier7Name deviceIsPhone:iPhone];
        [self.viewControllers addObject:vc];
        iPhone == TRUE ? [self.classifier7View_compact addSubview:vc.view] : [self.classifier7View_regular addSubview:vc.view];
    }

    if (self.classifier8Name != nil)
    {
        ExpressionViewController *vc = [[ExpressionViewController alloc] initWithName:self.classifier8Name deviceIsPhone:iPhone];
        [self.viewControllers addObject:vc];
        iPhone == TRUE ? [self.classifier8View_compact addSubview:vc.view] : [self.classifier8View_regular addSubview:vc.view];
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedClassifiers forKey:@"selectedClassifiers"];
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
{
    if (event.subtype == UIEventSubtypeMotionShake)
    {
        self.versionLabel.hidden = !self.versionLabel.hidden;
    }
    
    [super motionEnded:motion withEvent:event];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];

#ifdef DEMO_MODE
    self.mediaFilename = [[NSBundle mainBundle] pathForResource:@"face1" ofType:@"m4v"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.mediaFilename] == YES)
    {
        [self startDetector];
    }
#else
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusAuthorized) {
        // authorized
        [self startDetector];
    } else if(status == AVAuthorizationStatusDenied){
        // denied
        [[[UIAlertView alloc] initWithTitle:@"Error!"
                                    message:@"MeasureUp doesn't have permission to use camera, please change privacy settings"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else if(status == AVAuthorizationStatusRestricted){
        // restricted
    } else if(status == AVAuthorizationStatusNotDetermined){
        // not determined
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                [self startDetector];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error!"
                                            message:@"MeasureUp doesn't have permission to use camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        }];
    }
#endif
}

#if 0
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [UIView setAnimationsEnabled:NO];
    
    if (nil != self.session)
    {
        [self recordOrientation:toInterfaceOrientation];
    }
    
    if (nil != self.selfieView)
    {
        [self setupSelfieView];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
    [UIView setAnimationsEnabled:YES];
    [self.player.view setFrame:self.movieView.bounds];  // player's frame must match parent's
}
#endif

- (void)stopDetector;
{
    [self.detector stop];
}

- (void)startDetector;
{
    [self.detector stop];
    
#ifdef DEMO_MODE
    // create our detector with our desired facial expresions, using the front facing camera
    self.detector = [[AFDXDetector alloc] initWithDelegate:self usingFile:self.mediaFilename maximumFaces:1];
#else
    // create our detector with our desired facial expresions, using the front facing camera
    self.detector = [[AFDXDetector alloc] initWithDelegate:self usingCamera:AFDX_CAMERA_FRONT maximumFaces:1];
#endif
    

    self.drawFacePoints = [[[NSUserDefaults standardUserDefaults] objectForKey:@"drawFacePoints"] boolValue];
    self.drawFaceRect = self.drawFacePoints;
    
    NSInteger maxProcessRate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"maxProcessRate"] integerValue];
    if (0 == maxProcessRate)
    {
        maxProcessRate = 5;
    }
    
    if ([[[UIDeviceHardware new] platformString] isEqualToString:@"iPhone 4S"])
    {
        maxProcessRate = 4;
    }
    
    self.detector.maxProcessRate = maxProcessRate;
    
    self.dateOfLastFrame = nil;
    self.dateOfLastProcessedFrame = nil;
    self.detector.licensePath = [[NSBundle mainBundle] pathForResource:@"sdk" ofType:@"license"];
    
    // tell the detector which facial expressions we want to measure
    [self.detector setDetectAllEmotions:NO];
    [self.detector setDetectAllExpressions:NO];
    for (NSString *s in self.selectedClassifiers)
    {
        for (NSDictionary *d in self.availableClassifiers)
        {
            if ([s isEqualToString:[d objectForKey:@"name"]])
            {
                NSString *pn = [d objectForKey:@"propertyName"];
                [self.detector setValue:[NSNumber numberWithBool:YES] forKey:pn];
                break;
            }
        }
    }
    
    // let's start it up!
    NSError *error = [self.detector start];
    
    if (nil != error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Detector Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    
#ifdef BROADCAST_VIA_UDP
    dispatch_queue_t q = dispatch_queue_create("udp", 0);
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithSocketQueue:q];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)addSubView:(UIView *)highlightView withFrame:(CGRect)frame
{
    highlightView.frame = frame;
    highlightView.layer.borderWidth = 1;
    highlightView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.imageView addSubview:highlightView];
}

- (NSUInteger)supportedInterfaceOrientations;
{
    NSUInteger result;
    
    result = UIInterfaceOrientationMaskAll;
    
    return result;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    UIInterfaceOrientation result;
    
    result = UIInterfaceOrientationPortrait;
//    result = [UIApplication sharedApplication].statusBarOrientation;
    
    return result;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
{
    EmotionPickerViewController *vc = segue.destinationViewController;
    vc.selectedClassifiers = self.selectedClassifiers;

    vc.emotions = self.emotions;
    vc.expressions = self.expressions;
}

- (IBAction)showPicker:(id)sender;
{
    [self performSegueWithIdentifier:@"select" sender:self];
}

@end
