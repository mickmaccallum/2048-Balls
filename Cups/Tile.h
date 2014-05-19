//
//  Tile.h
//  2048TRIS Take Two
//
//  Created by Michael MacCallum on 5/17/14.
//  Copyright (c) 2014 Michael MacCallum. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Tile : SKSpriteNode

@property (nonatomic, assign) CGPoint gridPosition;
@property (nonatomic, assign) NSInteger numberValue;

- (instancetype)initWithNumberValue:(NSInteger)numberValue;

- (void)prepareForRemoval; // Fuck iOS 7.1

@end
