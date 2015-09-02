//
//  EmotionPickerViewController.h
//  AffdexMe
//
//  Created by boisy on 8/18/15.
//  Copyright (c) 2015 Affectiva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface EmotionVideoCell : UICollectionViewCell

@property (strong) MPMoviePlayerController *moviePlayer;
@property (strong) IBOutlet UIImageView *classifierView;
@property (weak) IBOutlet UILabel *label;

@end

@interface EmotionPickerViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak) IBOutlet UICollectionView *collectionViewRegular;
@property (weak) IBOutlet UICollectionView *collectionViewCompact;
@property (strong) UICollectionView *collectionView;
@property (strong) NSMutableArray *selectedClassifiers;
@property (strong) NSArray *emotions;
@property (strong) NSArray *expressions;
@property (weak) IBOutlet UILabel *instructionLabelRegular;
@property (weak) IBOutlet UILabel *instructionLabelCompact;


- (IBAction)doneTouched:(id)sender;

@end
