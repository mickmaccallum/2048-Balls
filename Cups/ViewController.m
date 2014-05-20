//
//  ViewController.m
//  Cups
//
//  Created by Mick on 5/19/14.
//  Copyright (c) 2014 MacCDevTeam LLC. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"
@import iAd;

@interface ViewController () < ADBannerViewDelegate >

@property (weak, nonatomic) IBOutlet ADBannerView *adBanner;

@end

@implementation ViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    SKView *skView = (SKView *)self.view;

    if (!skView.scene) {
        [skView setShowsDrawCount:YES];
        [skView setShowsFPS:YES];
        [skView setShowsNodeCount:YES];
//        [skView setShowsPhysics:YES];

        SKScene *scene = [GameScene sceneWithSize:skView.bounds.size];
        [scene setScaleMode:SKSceneScaleModeAspectFill];

        [skView presentScene:scene];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (self.adBanner.alpha == 0.0) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.adBanner setAlpha:1.0];
                         }
                         completion:nil];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.adBanner.alpha != 0.0) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.adBanner setAlpha:0.0];
                         }
                         completion:nil];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner
               willLeaveApplication:(BOOL)willLeave
{
    SKView *skView = (SKView *)self.view;

    if (skView.scene) {
        if ([skView.scene respondsToSelector:@selector(setPaused:)]) {
            [skView.scene setPaused:YES];
        }
    }

    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    SKView *skView = (SKView *)self.view;

    if (skView.scene) {
        if ([skView.scene respondsToSelector:@selector(setPaused:)]) {
            [skView.scene setPaused:NO];
        }
    }
}

@end
