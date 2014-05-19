//
//  UIColor+TileColors.m
//  2048tris
//
//  Created by Michael MacCallum on 5/16/14.
//  Copyright (c) 2014 Michael MacCallum. All rights reserved.
//

#import "UIColor+GameColors.h"

@implementation UIColor (GameColors)

+ (UIColor *)_colorForTileNumber:(NSInteger)number
{
    UIColor *color = nil;

    if (number == 2) {
        color = [UIColor _rgbColorFromArray:@[@238.0,@228.0,@218.0,@1.0]];
    }else if (number == 4) {
        color = [UIColor _rgbColorFromArray:@[@237.0,@224.0,@200.0,@1.0]];
    }else if (number == 8) {
        color = [UIColor _rgbColorFromArray:@[@242.0,@177.0,@121.0,@1.0]];
    }else if (number == 16) {
        color = [UIColor _rgbColorFromArray:@[@236.0,@141.0,@84.0,@1.0]];
    }else if (number == 32) {
        color = [UIColor _rgbColorFromArray:@[@246.0,@124.0,@95.0,@1.0]];
    }else if (number == 64) {
        color = [UIColor _rgbColorFromArray:@[@234.0,@89.0,@55.0,@1.0]];
    }else if (number == 128) {
        color = [UIColor _rgbColorFromArray:@[@243.0,@216.0,@107.0,@1.0]];
    }else if (number == 256) {
        color = [UIColor _rgbColorFromArray:@[@241.0,@208.0,@75.0,@1.0]];
    }else if (number == 512) {
        color = [UIColor _rgbColorFromArray:@[@228.0,@192.0,@42.0,@1.0]];
    }else if (number == 1024) {
        color = [UIColor _rgbColorFromArray:@[@226.0,@186.0,@19.0,@1.0]];
    }else if (number == 2048) {
        color = [UIColor _rgbColorFromArray:@[@236.0,@196.0,@0.0,@1.0]];
    }else if (number == 4096) {
        color = [UIColor _rgbColorFromArray:@[@95.0,@218.0,@147.0,@1.0]];
    }else{
        if (number > 4096) {
            color = [UIColor _rgbColorFromArray:@[@60.0,@58.0,@50.0,@1.0]];
        }else{
            color = [UIColor _rgbColorFromArray:@[@1.0,@1.0,@1.0,@1.0]];
        }
    }

    return color;
}

+ (UIColor *)_rgbColorFromArray:(NSArray *)arr
{
    return [UIColor _rgbColorWithRed:[arr[0] doubleValue]
                               green:[arr[1] doubleValue]
                                blue:[arr[2] doubleValue]
                               alpha:[arr[3] doubleValue]];
}

+ (UIColor *)_fontColorForTileNumber:(NSInteger)number
{
    if (number <= 4) {
        return [UIColor _darkTextColor];
    }else{
        return [UIColor _lightTextColor];
    }
}

+ (UIColor *)_darkTextColor
{
    return [UIColor _rgbColorWithRed:119.0
                               green:110.0
                                blue:101.0
                               alpha:1.0];
}

+ (UIColor *)_lightTextColor
{
    return [UIColor _rgbColorWithRed:249.0
                               green:246.0
                                blue:242.0
                               alpha:1.0];
}

+ (UIColor *)_rgbColorWithRed:(CGFloat)red
                        green:(CGFloat)green
                         blue:(CGFloat)blue
                        alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:red / 255.0
                           green:green / 255.0
                            blue:blue / 255.0
                           alpha:alpha];
}

+ (UIColor *)_backgroundColor
{
    return [UIColor _rgbColorWithRed:250.0
                               green:248.0
                                blue:239.0
                               alpha:1.0];
}

+ (UIColor *)_boardColor
{
    return [UIColor _rgbColorWithRed:204.0
                               green:192.0
                                blue:180.0
                               alpha:1.0];
}

+ (UIColor *)_boardEdgeColor
{
    return [UIColor _rgbColorWithRed:187.0
                               green:173.0
                                blue:160.0
                               alpha:1.0];
}

@end
