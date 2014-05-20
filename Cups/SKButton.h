//
//  SKButton.h
//  SKButton Project
//
//  Created by Mick on 4/1/14.
//  Copyright (c) 2014 MacCDevTeam LLC. All rights reserved.
//

@import SpriteKit;

typedef enum : NSUInteger {
    SKButtonActionTypeTouchDown = 1,
    SKButtonActionTypeTouchUpInside = 1 << 1
} SKButtonActionType;

typedef void(^ActionBlock)(void);

@interface SKButton : SKSpriteNode

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *fontName;
@property (strong, nonatomic) SKColor *textColor;
@property (strong, nonatomic) SKColor *highlightedColor;
@property (nonatomic, assign) CGFloat textSize;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) BOOL overrideSoundSettings;
@property (strong, nonatomic) SKLabelNode *label;

- (void)addActionOfType:(SKButtonActionType)type withBlock:(ActionBlock)actionBlock;

@end
