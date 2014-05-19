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

@interface GameScene ()

@property (strong, nonatomic) SKShapeNode *track;
@property (strong, nonatomic) SKShapeNode *bucket;

@end

@implementation GameScene

- (instancetype)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    
    if (self) {
        
        [self setBackgroundColor:[UIColor _backgroundColor]];
        
        [self addChild:self.track];
        [self addChild:self.bucket];

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

- (SKShapeNode *)bucket
{
    if (!_bucket) {
        _bucket = [SKShapeNode new];
        
        
    }
    
    return _bucket;
}

- (void)removeFromParent // Fuck iOS 7.1
{
    [self.track removeFromParent];
    [self setTrack:nil];
    
    [self.bucket removeFromParent];
    [self setBucket:nil];
    
    [super removeFromParent];
}

@end
