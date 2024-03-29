//
//  SKButton.m
//  SKButton Project
//
//  Created by Mick on 4/1/14.
//  Copyright (c) 2014 MacCDevTeam LLC. All rights reserved.
//

#import "SKButton.h"

@interface SKButton ()

@property (strong, nonatomic) SKColor *originalBackgroundColor;
@property (strong, nonatomic) ActionBlock touchDownBlock;
@property (strong, nonatomic) ActionBlock touchUpInsideBlock;

@property (nonatomic, assign) NSUInteger actionBitmask;
@property (nonatomic, assign) CGPoint startingTouchLocation;

@end

@implementation SKButton

- (instancetype)initWithColor:(SKColor *)color size:(CGSize)size
{
    self = [super initWithColor:color size:size];
    
    if (self) {
        [self setAnchorPoint:CGPointMake(0.5, 0.5)];
        [self setUserInteractionEnabled:YES];

        [self setStartingTouchLocation:CGPointZero];
        [self setActionBitmask:0];
        [self setOverrideSoundSettings:NO];

        [self addChild:self.label];
    }
    
    return self;
}

- (SKColor *)highlightedColor
{
    CGFloat h, s, b, a;
    
    if ([self.color getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [SKColor colorWithHue:h saturation:s brightness:b * 0.8 alpha:a];
    }
    
    return nil;
}

- (SKLabelNode *)label
{
    if (!_label) {
        _label = [SKLabelNode new];
        [_label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [_label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        
        [_label setPosition:CGPointZero];
        [_label setFontName:self.fontName];
    }
    
    return _label;
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesBegan:touches
              withEvent:event];

    if (self.actionBitmask ^ SKButtonActionTypeTouchDown) {
        [self setOriginalBackgroundColor:self.color];
        [self setColor:[self highlightedColor]];
    }

    if (self.actionBitmask > 0) {
        CGPoint location = [[touches anyObject] locationInNode:self];

        if (self.actionBitmask & SKButtonActionTypeTouchDown) {
            self.touchDownBlock();
        }else if (self.actionBitmask & SKButtonActionTypeTouchUpInside) {
            self.startingTouchLocation = location;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesEnded:touches
              withEvent:event];

    if (self.actionBitmask ^ SKButtonActionTypeTouchDown) {
        if (self.originalBackgroundColor) {
            [self setColor:self.originalBackgroundColor];
            [self setOriginalBackgroundColor:nil];            
        }
    }

    if (self.actionBitmask > 0) {
        if (self.actionBitmask & SKButtonActionTypeTouchUpInside) {
            CGPoint location = [[touches anyObject] locationInNode:self];

            BOOL containsPoint = [self isPoint:location
                                        inNode:self];

            if (containsPoint) {
                self.touchUpInsideBlock();
                [self setStartingTouchLocation:CGPointZero];
            }
            
        }
    }
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesMoved:touches
              withEvent:event];

    if (self.actionBitmask ^ SKButtonActionTypeTouchDown) {

        CGPoint location = [[touches anyObject] locationInNode:self];

        BOOL containsPoint = [self isPoint:location inNode:self];

        if (containsPoint) {
            if (!self.originalBackgroundColor) {
                [self setOriginalBackgroundColor:self.color];
                [self setColor:[self highlightedColor]];
            }
        }else{
            if (self.originalBackgroundColor) {
                [self setColor:self.originalBackgroundColor];
                [self setOriginalBackgroundColor:nil];
            }
        }
    }
}

- (BOOL)isPoint:(CGPoint)point
         inNode:(SKSpriteNode *)node
{
    CGFloat width = node.size.width;
    CGFloat height = node.size.height;

    point.x += width / 2.0;
    point.y += height / 2.0;

    CGRect bounds = CGRectMake(0.0, 0.0, width, height);

    return CGRectContainsPoint(bounds, point);
}

- (void)addActionOfType:(SKButtonActionType)type
              withBlock:(ActionBlock)actionBlock;
{
    if (type == SKButtonActionTypeTouchDown) {
        [self setTouchDownBlock:actionBlock];
    }else if (type == SKButtonActionTypeTouchUpInside) {
        [self setTouchUpInsideBlock:actionBlock];
    }
    self.actionBitmask = self.actionBitmask | type;
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    [self.label setText:text];
}

- (void)setFontName:(NSString *)fontName
{
    _fontName = fontName;
    
    [self.label setFontName:fontName];
}

- (void)setTextColor:(SKColor *)textColor
{
    _textColor = textColor;
    
    [self.label setFontColor:textColor];
}

- (void)setTextSize:(CGFloat)textSize
{
    _textSize = textSize;
    
    [self.label setFontSize:textSize];
}

@end
