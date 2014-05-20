//
//  Tile.h
//  2048TRIS Take Two
//
//  Created by Michael MacCallum on 5/17/14.
//  Copyright (c) 2014 Michael MacCallum. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol TileSelectionDelegate;

@interface Tile : SKSpriteNode

@property (nonatomic, assign) NSInteger numberValue;
@property (nonatomic, assign) NSInteger queuePosition;
@property (nonatomic, assign, getter = isOuter) BOOL outer;
@property (weak, nonatomic) id < TileSelectionDelegate > selectionDelegate;

- (instancetype)initWithNumberValue:(NSInteger)numberValue;
- (void)prepareForRemoval; // Fuck iOS 7.1

@end

@protocol TileSelectionDelegate <NSObject>
@required

- (void)tileTapped:(Tile *)tile;

@end