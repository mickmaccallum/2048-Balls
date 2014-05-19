//
//  GameScene.m
//  Cups
//
//  Created by Mick on 5/19/14.
//  Copyright (c) 2014 MacCDevTeam LLC. All rights reserved.
//

#import "GameScene.h"
#import "Tile.h"
#import "UIColor+GameColors.h"

@interface GameScene () < SKPhysicsContactDelegate >

@property (strong, nonatomic) SKShapeNode *track;
@property (strong, nonatomic) SKShapeNode *leftBucket;
@property (strong, nonatomic) SKShapeNode *rightBucket;

@end

@implementation GameScene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    
    if (self) {

        [self.physicsWorld setContactDelegate:self];
        [self.physicsWorld setGravity:CGVectorMake(0.0, -20.0)];
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0.0, 0.0, size.width, size.height)]];
        [self.physicsBody setCategoryBitMask:1];
        [self.physicsBody setCollisionBitMask:2];
        [self.physicsBody setContactTestBitMask:0];
        [self.physicsBody setFriction:100.0];
        
        [self setBackgroundColor:[UIColor _backgroundColor]];
        
        [self addChild:self.track];

        [self addChild:self.leftBucket];
        [self addChild:self.rightBucket];

        NSMutableArray *bezierPoints = [NSMutableArray array];
        CGPathApply(self.track.path, (__bridge void *)(bezierPoints), MyCGPathApplierFunc);

        NSValue *value = bezierPoints[0];
        
        CGPoint start = value.CGPointValue;
        

        for (NSInteger i = 1; i < 20; i += 2) {
            Tile *tile = [[Tile alloc] initWithNumberValue:2];
            [tile setAlpha:0.0];
            [tile setPosition:start];
            [self.track addChild:tile];
            
            SKAction *follow = [SKAction followPath:self.track.path
                                           asOffset:NO
                                       orientToPath:NO
                                           duration:20.0];
            
            [tile runAction:[SKAction sequence:@[[SKAction waitForDuration:i],[SKAction group:@[[SKAction fadeInWithDuration:0.5],[SKAction repeatActionForever:follow]]]]]];
        }
    }
    
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [view addGestureRecognizer:tapGesture];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
    Tile *tile = [[Tile alloc] initWithNumberValue:2];
    [tile setPosition:CGPointMake(self.size.width / 2.0, self.size.height / 2.0)];
    [self.track addChild:tile];

    [tile.physicsBody setAffectedByGravity:YES];
    [tile.physicsBody setDynamic:YES];
}


- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if ([contact.bodyA.node isMemberOfClass:[Tile class]] && [contact.bodyB.node isMemberOfClass:[Tile class]]) {
        Tile *tileA = (Tile *)contact.bodyA.node;
        Tile *tileB = (Tile *)contact.bodyB.node;

        if (tileA.numberValue == tileB.numberValue) {
            if ([tileB respondsToSelector:@selector(removeFromParent)]) {
                [tileB removeFromParent];
            }

            tileA.numberValue *= 2.0;
        }else{
            
            NSLog(@"%@",contact);
        }
    }
}

- (SKShapeNode *)track
{
    if (!_track) {
        _track = [SKShapeNode new];
    
        CGRect frame = CGRectMake(25.0, self.size.height / 2.0 - 350.0 / 2.0, 270.0, 350.0);
        UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:frame
                                                          cornerRadius:15.0];
        
        [_track setPath:bezier.CGPath];
        [_track setFillColor:[SKColor _boardColor]];
        [_track setStrokeColor:[SKColor _boardEdgeColor]];
    }
    
    return _track;
}

- (SKShapeNode *)leftBucket
{
    if (!_leftBucket) {
        _leftBucket = [SKShapeNode new];
        
        UIBezierPath *bezier = [UIBezierPath bezierPath];
        
        CGFloat centerX = self.size.width / 2.0;
        CGFloat centerY = self.size.height / 2.0;
        CGFloat topOfTrack = self.track.frame.size.height + self.track.frame.origin.y;
        
        [bezier moveToPoint:CGPointMake(25.0, topOfTrack - 24.0)];
        [bezier addLineToPoint:CGPointMake(centerX - 17.0, centerY)];
        [bezier addLineToPoint:CGPointMake(centerX - 17.0, centerY - 30.0)];
        [bezier moveToPoint:CGPointMake(centerX - 17.0, centerY + 50)];
        [bezier addLineToPoint:CGPointMake(25.0 + 24.0, topOfTrack)];
        
        
        [_leftBucket setPath:bezier.CGPath];
        [_leftBucket setFillColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
        [_leftBucket setStrokeColor:[SKColor _boardEdgeColor]];
    }
    
    return _leftBucket;
}

- (SKShapeNode *)rightBucket
{
    if (!_rightBucket) {
        _rightBucket = [SKShapeNode new];
        
    }
    
    return _rightBucket;
}

- (void)removeFromParent // Fuck iOS 7.1
{
    [self.track removeFromParent];
    [self setTrack:nil];
    
    [self.leftBucket removeFromParent];
    [self setLeftBucket:nil];
    
    [self.rightBucket removeFromParent];
    [self setRightBucket:nil];
    
    [super removeFromParent];
}

void MyCGPathApplierFunc (void *info, const CGPathElement *element) {
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;

    CGPoint *points = element->points;
    CGPathElementType type = element->type;

    switch(type) {
        case kCGPathElementMoveToPoint: // contains 1 point
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;

        case kCGPathElementAddLineToPoint: // contains 1 point
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            break;

        case kCGPathElementAddQuadCurveToPoint: // contains 2 points
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            break;

        case kCGPathElementAddCurveToPoint: // contains 3 points
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[0]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[1]]];
            [bezierPoints addObject:[NSValue valueWithCGPoint:points[2]]];
            break;

        case kCGPathElementCloseSubpath: // contains no point
            break;
    }
}

@end
