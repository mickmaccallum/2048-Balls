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
@property (strong, nonatomic) SKSpriteNode *leftDoor;
@property (strong, nonatomic) SKSpriteNode *rightDoor;

@property (strong, nonatomic) SKShapeNode *housing;
@property (strong, nonatomic) NSMutableArray *queue;

@property (nonatomic, assign, getter = isHoldingDoor) BOOL holdingDoor;

@end

@implementation GameScene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    
    if (self) {

        [self.physicsWorld setContactDelegate:self];
        [self.physicsWorld setGravity:CGVectorMake(0.0, -10.0)];
        
        [self setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0.0, 0.0, size.width, size.height)]];
        
        [self.physicsBody setCategoryBitMask:1];
        [self.physicsBody setCollisionBitMask:2];
        [self.physicsBody setContactTestBitMask:UINT32_MAX];
        [self.physicsBody setFriction:100.0];
        
        [self setBackgroundColor:[UIColor _backgroundColor]];
        [self setHoldingDoor:NO];
        
        [self addChild:self.track];
        [self addChild:self.housing];
        [self addChild:self.leftDoor];
        [self addChild:self.rightDoor];

        NSMutableArray *bezierPoints = [NSMutableArray array];
        CGPathApply(self.track.path, (__bridge void *)(bezierPoints), MyCGPathApplierFunc);

        NSValue *value = bezierPoints[0];
        CGPoint start = value.CGPointValue;

        for (NSInteger i = 1; i < 30; i += 3) {
            Tile *tile = [[Tile alloc] initWithNumberValue:[self randomStartingValue]];
            [tile setOuter:YES];
            [tile setScale:0.0];
            [tile setPosition:start];
            [self.track addChild:tile];
            
            SKAction *follow = [SKAction followPath:self.track.path
                                           asOffset:NO
                                       orientToPath:NO
                                           duration:30.0];
            
            [tile runAction:[SKAction sequence:@[[SKAction waitForDuration:i],[SKAction group:@[[SKAction scaleTo:1.0 duration:0.2],[SKAction repeatActionForever:follow]]]]]];
        }
    }
    
    return self;
}

- (NSInteger)randomStartingValue
{
    uint32_t rand = arc4random_uniform(100) + 1; // 0 - 100

    NSInteger num = 2;

    if (rand % 100 == 0) {
        num = 8;
    }else if (rand % 10 == 0) {
        num = 4;
    }
    return num;
}

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [longPress setMinimumPressDuration:0.0];
    [view addGestureRecognizer:longPress];

    [self generateQueue];
}

- (NSMutableArray *)queue
{
    if (!_queue) {
        _queue = [NSMutableArray new];
    }

    return _queue;
}

- (void)setHoldingDoor:(BOOL)holdingDoor
{
    if (_holdingDoor != holdingDoor) {
        _holdingDoor = holdingDoor;

        if (holdingDoor && self.queue.count) {
            Tile *tile = self.queue[0];

            [tile.physicsBody setDynamic:YES];

            SKAction *wait = [SKAction waitForDuration:0.2];

            SKAction *unhold = [SKAction runBlock:^{
                [self setHoldingDoor:NO];
            } queue:dispatch_get_main_queue()];

            [self.leftDoor runAction:[SKAction sequence:@[wait,[SKAction rotateToAngle:-M_PI_4 duration:0.15]]]];
            [self.rightDoor runAction:[SKAction sequence:@[wait,[SKAction rotateToAngle:M_PI_4 duration:0.15],unhold]]];

            [self bumpQueue];
        }
    }
}

- (void)bumpQueue
{
    [self.queue removeObjectAtIndex:0];

    for (Tile *tile in self.queue) {
        tile.queuePosition -- ;
    }

    [self addTileAtQueuePosition:2];
}

- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {

        [self.leftDoor runAction:[SKAction rotateToAngle:-M_PI_2
                                                duration:0.05]];

        [self.rightDoor runAction:[SKAction rotateToAngle:M_PI_2
                                                 duration:0.05]];

        [self setHoldingDoor:YES];
    }
}

- (void)generateQueue
{
    for (NSInteger i = 0; i <= 2; i ++) {
        [self addTileAtQueuePosition:i];
    }
}

- (void)addTileAtQueuePosition:(NSInteger)index
{
    Tile *tile = [[Tile alloc] initWithNumberValue:[self randomStartingValue]];

    [tile.physicsBody setAffectedByGravity:YES];
    [tile.physicsBody setDynamic:NO];

    [self.track addChild:tile];
    [self.queue addObject:tile];

    [tile setQueuePosition:index];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if ([contact.bodyA.node isMemberOfClass:[Tile class]] && [contact.bodyB.node isMemberOfClass:[Tile class]]) {
        Tile *tileA = (Tile *)contact.bodyA.node;
        Tile *tileB = (Tile *)contact.bodyB.node;

        if (tileA.isOuter || tileB.isOuter) {
            if (tileA.numberValue == tileB.numberValue) {

                Tile *topTile = nil;
                Tile *bottomTile = nil;

                if (tileA.physicsBody.affectedByGravity) {
                    topTile = tileA;
                    bottomTile = tileB;
                }else{
                    topTile = tileB;
                    bottomTile = tileA;
                }

                dispatch_async(dispatch_get_main_queue(), ^{

                    [topTile removeAllActions];

                    [topTile.physicsBody setCategoryBitMask:0];
                    [topTile.physicsBody setCollisionBitMask:0];
                    [topTile.physicsBody setContactTestBitMask:0];
                    [topTile.physicsBody setAffectedByGravity:NO];

                    [topTile setScale:0.0];
                    [bottomTile setZPosition:topTile.zPosition + 1];

                    [bottomTile runAction:[SKAction sequence:@[[SKAction scaleTo:1.5 duration:0.1],[SKAction scaleTo:1.0 duration:0.1]]]];
                    bottomTile.numberValue *= 2.0;
                });
            }else{
                NSLog(@"%@",contact);
            }
        }
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
    if ([contact.bodyA.node isMemberOfClass:[self class]] || [contact.bodyB.node isMemberOfClass:[self class]]) {
        GameScene *scene = nil;
        Tile *tile = nil;

        if ([contact.bodyA.node isMemberOfClass:[self class]]) {
            scene = (GameScene *)contact.bodyA.node;
        }else if ([contact.bodyB.node isMemberOfClass:[self class]]) {
            scene = (GameScene *)contact.bodyB.node;
        }

        if ([contact.bodyA.node isMemberOfClass:[Tile class]]) {
            tile = (Tile *)contact.bodyA.node;
        }else if ([contact.bodyB.node isMemberOfClass:[Tile class]]){
            tile = (Tile *)contact.bodyB.node;
        }

        if (scene && tile) {
            if ([tile respondsToSelector:@selector(prepareForRemoval)] && [tile respondsToSelector:@selector(removeFromParent)]) {
                NSLog(@"Removing node from fall out %@",tile);
                [tile prepareForRemoval];
                [tile removeFromParent];
            }
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

- (SKSpriteNode *)leftDoor
{
    if (!_leftDoor) {
        _leftDoor = [[SKSpriteNode alloc] initWithColor:[SKColor _boardEdgeColor]
                                                   size:CGSizeMake(43.0, 2.0)];

        CGFloat halfWidth = self.size.width / 2.0;
        CGFloat halfHeight = self.size.height / 2.0;

        [_leftDoor setAnchorPoint:CGPointMake(0.0, 0.5)];
        [_leftDoor setPosition:CGPointMake(halfWidth - 30.0, halfHeight + 20.0)];
        [_leftDoor setZRotation:-M_PI_4];
        [_leftDoor setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:_leftDoor.size]];

        [_leftDoor.physicsBody setDynamic:NO];
        [_leftDoor.physicsBody setCategoryBitMask:8];
        [_leftDoor.physicsBody setCollisionBitMask:~8];
        [_leftDoor.physicsBody setContactTestBitMask:~8];
    }
    
    return _leftDoor;
}

- (SKSpriteNode *)rightDoor
{
    if (!_rightDoor) {
        _rightDoor = [[SKSpriteNode alloc] initWithColor:[SKColor _boardEdgeColor]
                                                   size:CGSizeMake(43.0, 2.0)];

        CGFloat halfWidth = self.size.width / 2.0;
        CGFloat halfHeight = self.size.height / 2.0;

        [_rightDoor setAnchorPoint:CGPointMake(1.0, 0.5)];
        [_rightDoor setPosition:CGPointMake(halfWidth + 30.0, halfHeight + 20.0)];

        [_rightDoor setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:_rightDoor.size]];
        [_rightDoor setZRotation:M_PI_4];
        [_rightDoor.physicsBody setDynamic:NO];
        [_rightDoor.physicsBody setCategoryBitMask:8];
        [_rightDoor.physicsBody setCollisionBitMask:~8];
        [_rightDoor.physicsBody setContactTestBitMask:~8];
    }
    
    return _rightDoor;
}

- (SKShapeNode *)housing
{
    if (!_housing) {
        _housing = [[SKShapeNode alloc] init];

        UIBezierPath *bezier = [UIBezierPath bezierPath];

        CGFloat halfWidth = self.size.width / 2.0;
        CGFloat halfHeight = self.size.height / 2.0;

        // Bottom Center
        [bezier moveToPoint:CGPointMake(halfWidth - 30.0, halfHeight + 20.0)];
        [bezier addLineToPoint:CGPointMake(halfWidth, halfHeight + 50.0)];
        [bezier addLineToPoint:CGPointMake(halfWidth + 30.0, halfHeight + 20.0)];

        // Right (already at starting point)
        [bezier addLineToPoint:CGPointMake(halfWidth + 60.0, halfHeight + 50.0)];
        [bezier addLineToPoint:CGPointMake(halfWidth + 30.0, halfHeight + 80.0)];
        [bezier addLineToPoint:CGPointMake(halfWidth, halfHeight + 50.0)];

        // Left (already at starting point)
        [bezier addLineToPoint:CGPointMake(halfWidth - 30.0, halfHeight + 80.0)];
        [bezier addLineToPoint:CGPointMake(halfWidth - 60.0, halfHeight + 50.0)];
        [bezier addLineToPoint:CGPointMake(halfWidth - 30.0, halfHeight + 20.0)];

        // Top
        [bezier moveToPoint:CGPointMake(halfWidth - 30.0, halfHeight + 80.0)];
        [bezier addLineToPoint:CGPointMake(halfWidth, halfHeight + 110.0)];
        [bezier addLineToPoint:CGPointMake(halfWidth + 30.0, halfHeight + 80.0)];

        [_housing setPath:bezier.CGPath];
        [_housing setLineWidth:2.0];
        [_housing setStrokeColor:[SKColor _boardEdgeColor]];
        [_housing setAntialiased:NO];
    }

    return _housing;
}

- (void)removeFromParent // Fuck iOS 7.1
{
    [self.track removeFromParent];
    [self setTrack:nil];

    [self.housing removeFromParent];
    [self setHousing:nil];
    
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
