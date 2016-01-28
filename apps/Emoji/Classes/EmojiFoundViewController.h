//
//  EmojiFoundViewController.h
//  Emoji
//
//  Created by Boisy Pitre on 1/21/16.
//  Copyright © 2016 Affectiva. All rights reserved.
//

#import <Affdex/Affdex.h>

@interface EmojiFoundViewController : UIViewController

@property (strong) IBOutlet UIImageView *imageView;
@property (strong) IBOutlet UIImageView *emojiView;
@property (strong) IBOutlet UILabel *emojiLabel;
@property (strong) AFDXFace *face;

@end
