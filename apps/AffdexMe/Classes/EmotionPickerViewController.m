//
//  EmotionPickerViewController.m
//  AffdexMe
//
//  Created by boisy on 8/18/15.
//  Copyright (c) 2015 Affectiva. All rights reserved.
//

#import "EmotionPickerViewController.h"
#import "SoundEffect.h"
#import "HeaderCollectionReusableView.h"

#define SELECTED_COLOR [UIColor greenColor]
#define SELECTED_TEXT_COLOR [UIColor blackColor]
#define UNSELECTED_COLOR [UIColor whiteColor]
#define UNSELECTED_TEXT_COLOR [UIColor blackColor]

@implementation EmotionVideoCell

@end

@interface EmotionPickerViewController ()

@property (strong) SoundEffect *sound;

@end

@implementation EmotionPickerViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
    }
    
    return self;
}

- (void)viewDidLoad;
{
    [super viewDidLoad];
    self.collectionViewCompact.allowsMultipleSelection = TRUE;
    self.collectionViewRegular.allowsMultipleSelection = TRUE;

    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionViewCompact.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(00, 0, 20, 0);

    collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionViewRegular.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(00, 0, 20, 0);
}

- (void)viewWillAppear:(BOOL)animated;
{
    [self.collectionViewCompact reloadData];
    [self.collectionViewRegular reloadData];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    NSUInteger result;
    
    if (section == 0)
    {
        result = [self.emotions count];
    }
    else
    {
        result = [self.expressions count];
    }
    
    return result;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    EmotionVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmotionCell" forIndexPath:indexPath];

    NSUInteger section = [indexPath section];
    NSUInteger index = [indexPath row];
    if (section == 0)
    {
        cell.label.text = [[self.emotions objectAtIndex:index] objectForKey:@"name"];
    }
    else
    {
        cell.label.text = [[self.expressions objectAtIndex:index] objectForKey:@"name"];
    }
    
    if ([self.selectedClassifiers containsObject:cell.label.text])
    {
        cell.label.textColor = SELECTED_TEXT_COLOR;
        cell.label.backgroundColor = SELECTED_COLOR;
        cell.backgroundColor = SELECTED_COLOR;
    }
    else
    {
        cell.label.textColor = UNSELECTED_TEXT_COLOR;
        cell.label.backgroundColor = UNSELECTED_COLOR;
        cell.backgroundColor = UNSELECTED_COLOR;
    }

    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg", cell.label.text]];
    [cell.classifierView setImage:image];
#if 0
    if (cell.moviePlayer == nil)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"anger" ofType:@"mp4"];
        
        cell.moviePlayer = [[MPMoviePlayerController alloc]
                            initWithContentURL: [NSURL fileURLWithPath:
                                                 filePath]];
        
        CGRect videoFrame = CGRectMake(0, 0, cell.movieView.frame.size.width, cell.movieView.frame.size.height);
        
        [cell.moviePlayer.view setFrame:videoFrame];
        
        cell.moviePlayer.shouldAutoplay = TRUE;
        cell.moviePlayer.repeatMode = TRUE;
        [cell.moviePlayer prepareToPlay];
        [cell.movieView addSubview:cell.moviePlayer.view];
        cell.moviePlayer.view.backgroundColor = [UIColor blueColor];
    }
#endif
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EmotionVideoCell *cell = (EmotionVideoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedClassifiers removeObject:cell.label.text];

    NSUInteger count = [self.selectedClassifiers count];
    self.instructionLabelRegular.text = [NSString stringWithFormat:@"%ld emotion%@/expression%@ selected.",
                                  (unsigned long)count,
                                  count == 1 ? @"" : @"s",
                                  count == 1 ? @"" : @"s"];
    self.instructionLabelCompact.text = [NSString stringWithFormat:@"%ld emotion%@/expression%@ selected.",
                                         (unsigned long)count,
                                         count == 1 ? @"" : @"s",
                                         count == 1 ? @"" : @"s"];
    self.sound = [[SoundEffect alloc] initWithSoundNamed:@"Whoot.m4a"];
    [self.sound play];

    [self.collectionViewCompact reloadData];
    [self.collectionViewRegular reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EmotionVideoCell *cell = (EmotionVideoCell *)[collectionView cellForItemAtIndexPath:indexPath];

    if ([self.selectedClassifiers count] < 8 && [self.selectedClassifiers containsObject:cell.label.text] == NO)
    {
        [self.selectedClassifiers addObject:cell.label.text];
        NSUInteger count = [self.selectedClassifiers count];
        self.instructionLabelRegular.text = [NSString stringWithFormat:@"%ld emotion%@/expression%@ selected.",
                                      (unsigned long)count,
                                      count == 1 ? @"" : @"s",
                                      count == 1 ? @"" : @"s"];
        self.instructionLabelCompact.text = [NSString stringWithFormat:@"%ld emotion%@/expression%@ selected.",
                                             (unsigned long)count,
                                             count == 1 ? @"" : @"s",
                                             count == 1 ? @"" : @"s"];
        self.sound = [[SoundEffect alloc] initWithSoundNamed:@"Whit.m4a"];
        [self.sound play];
    }
    else
    {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self.selectedClassifiers removeObject:cell.label.text];
        if ([self.selectedClassifiers count] == 8)
        {
            // we are at our max.
            self.instructionLabelRegular.text = [NSString stringWithFormat:@"You already have 8 expressions/emotions selected."];
            self.instructionLabelCompact.text = [NSString stringWithFormat:@"You already have 8 expressions/emotions selected."];
            self.sound = [[SoundEffect alloc] initWithSoundNamed:@"Enk.m4a"];
            [self.sound play];
        }
        else
        {
            NSUInteger count = [self.selectedClassifiers count];
            self.instructionLabelRegular.text = [NSString stringWithFormat:@"%ld emotion%@/expression%@ selected.",
                                                 (unsigned long)count,
                                                 count == 1 ? @"" : @"s",
                                                 count == 1 ? @"" : @"s"];
            self.instructionLabelCompact.text = [NSString stringWithFormat:@"%ld emotion%@/expression%@ selected.",
                                                 (unsigned long)count,
                                                 count == 1 ? @"" : @"s",
                                                 count == 1 ? @"" : @"s"];
            self.sound = [[SoundEffect alloc] initWithSoundNamed:@"Whoot.m4a"];
            [self.sound play];
        }
    }

    [cell.moviePlayer play];
    
    [self.collectionViewCompact reloadData];
    [self.collectionViewRegular reloadData];
}

- (IBAction)doneTouched:(id)sender;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    HeaderCollectionReusableView *reusableview = nil;

    if (kind == UICollectionElementKindSectionHeader)
    {
        HeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        if ([indexPath indexAtPosition:0] == 0)
        {
            headerView.label.text = @"Emotions";
        }
        else
        {
            headerView.label.text = @"Expressions";
        }
        
        reusableview = headerView;
    }
    
    if (kind == UICollectionElementKindSectionFooter)
    {
//        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
//        reusableview = footerview;
    }
    
    return reusableview;
}

@end
