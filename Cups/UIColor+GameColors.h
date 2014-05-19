//
//  UIColor+TileColors.h
//  2048tris
//
//  Created by Michael MacCallum on 5/16/14.
//  Copyright (c) 2014 Michael MacCallum. All rights reserved.
//

@interface UIColor (GameColors)

+ (UIColor *)_colorForTileNumber:(NSInteger)number;
+ (UIColor *)_fontColorForTileNumber:(NSInteger)number;
+ (UIColor *)_backgroundColor;
+ (UIColor *)_boardColor;
+ (UIColor *)_boardEdgeColor;

@end
