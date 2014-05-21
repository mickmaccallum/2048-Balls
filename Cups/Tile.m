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
        [self setUserInteractionEnabled:YES];
        [self setOuter:NO];
        [self setQueuePosition:-1];
        [self setZPosition:1000.0];
        [self setSize:CGSizeMake(30.0, 30.0)];
        [self setAnchorPoint:CGPointMake(0.5, 0.5)];
        self.rounding = [[SKShapeNode alloc] init];

        UIBezierPath *bezier = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-self.size.width / 2.0, -self.size.height / 2.0, self.size.width, self.size.height)];

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

        [self setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:15.0]];
        [self.physicsBody setDynamic:NO];
        [self.physicsBody setAffectedByGravity:NO];
        [self.physicsBody setFriction:0.0];
        [self.physicsBody setRestitution:0.25];

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
    [self.physicsBody setContactTestBitMask:(uint32_t)numberValue | 1];
    [self.physicsBody setCollisionBitMask:~(1)];
//    [self.physicsBody setCollisionBitMask:~((uint32_t)numberValue | 1)];

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

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [super touchesBegan:touches
              withEvent:event];

    if ([self.selectionDelegate respondsToSelector:@selector(tileTapped:)]) {
        [self.selectionDelegate tileTapped:self];
    }
}

- (void)setQueuePosition:(NSInteger)queuePosition
{
    _queuePosition = queuePosition;

    if (queuePosition >= 0) {
        [self popToQueuePosition:queuePosition];
    }
}

- (void)popToQueuePosition:(NSInteger)queuePosition
{
//    SKAction *scaleDown = [SKAction scaleTo:0.0
//                                   duration:0.15];
//
//    SKAction *scaleUp = [SKAction scaleTo:1.0
//                                   duration:0.15];
    
    SKAction *action = nil;
    
    if (CGPointEqualToPoint(self.position, CGPointZero)) {
        [self setScale:0.0];
        [self setPosition:CGPointFromString([self startingPositions][queuePosition])];
        action = [SKAction scaleTo:1.0 duration:0.2];
    }else{
        action = [SKAction moveTo:CGPointFromString([self startingPositions][queuePosition]) duration:0.2];
    }

    SKAction *block = [SKAction runBlock:^{
        [self setPosition:CGPointFromString([self startingPositions][queuePosition])];
    } queue:dispatch_get_main_queue()];

    [self runAction:[SKAction sequence:@[action,block]]];
}


- (NSArray *)startingPositions
{
    static NSArray *positions = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        positions = @[NSStringFromCGPoint(CGPointMake(self.scene.size.width / 2.0, self.scene.size.height / 2.0 + 20.0)),
                      NSStringFromCGPoint(CGPointMake(self.scene.size.width / 2.0 - 30.0, self.scene.size.height / 2.0 + 50.0)),
                      NSStringFromCGPoint(CGPointMake(self.scene.size.width / 2.0, self.scene.size.height / 2.0 + 80.0))];

    });

    return positions;
}


@end