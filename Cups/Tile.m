//
//  Tile.m
//  2048TRIS Take Two
//
//  Created by Michael MacCallum on 5/17/14.
//  Copyright (c) 2014 Michael MacCallum. All rights reserved.
//

#import "Tile.h"
#import "UIColor+GameColors.h"

@interface Tile ()

@property (strong, nonatomic) SKLabelNode *label;
@property (strong, nonatomic) SKShapeNode *rounding;

@end

@implementation Tile

- (instancetype)initWithNumberValue:(NSInteger)numberValue
{
    self = [super init];

    if (self) {
        [self setZPosition:1000.0];
        [self setSize:CGSizeMake(30.0, 30.0)];
        [self setAnchorPoint:CGPointMake(0.5, 0.5)];
        self.rounding = [[SKShapeNode alloc] init];

        UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-self.size.width / 2.0, -self.size.height / 2.0, self.size.width, self.size.height)
                                                          cornerRadius:3.0];

        [self.rounding setFillColor:[UIColor _colorForTileNumber:2]];
        [self.rounding setStrokeColor:[UIColor _colorForTileNumber:2]];
        [self.rounding setPath:bezier.CGPath];
        [self addChild:self.rounding];

        self.label = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];

        [self.label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [self.label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [self.label setPosition:CGPointMake(0.0, 0.0)];
        [self.label setFontSize:24.0];

        [self addChild:self.label];

        [self setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:self.size]];
        [self.physicsBody setDynamic:YES];
        [self.physicsBody setAffectedByGravity:NO];
        [self.physicsBody setFriction:0.0];
        [self.physicsBody setRestitution:0.0];
        [self.physicsBody setCollisionBitMask:0];

        [self setNumberValue:numberValue];
    }

    return self;
}

- (void)setNumberValue:(NSInteger)numberValue
{
    _numberValue = numberValue;

    [self.label setText:[NSString stringWithFormat:@"%li",(long)numberValue]];
    [self.label setFontColor:[UIColor _fontColorForTileNumber:numberValue]];
    [self.rounding setFillColor:[UIColor _colorForTileNumber:numberValue]];
    [self.rounding setStrokeColor:[UIColor _colorForTileNumber:numberValue]];

    [self.physicsBody setCategoryBitMask:(uint32_t)numberValue];
    [self.physicsBody setContactTestBitMask:(uint32_t)numberValue];
}

- (void)removeFromParent // Solves iOS 7.1 bug
{
    [self prepareForRemoval];

    [super removeFromParent];
}

- (void)prepareForRemoval
{
    [self.label removeFromParent];
    [self.rounding removeFromParent];
}


@end