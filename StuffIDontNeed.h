@interface AVPlayerController
@property(nonatomic, retain) AVPlayer *player;
- (BOOL)isPlaying;
- (void)setPlaying:(BOOL)arg1;
@end

// Double tap to fastforward
self.doubleTapToSkipAhead = [[UIView alloc] init];
self.doubleTapToSkipAhead.alpha = 0.1;
self.doubleTapToSkipAhead.layer.cornerCurve = kCACornerCurveContinuous;
self.doubleTapToSkipAhead.clipsToBounds = YES;
self.doubleTapToSkipAhead.layer.cornerRadius = 140;
self.doubleTapToSkipAhead.layer.maskedCorners =
    kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
self.doubleTapToSkipAhead.backgroundColor = UIColor.clearColor;
UITapGestureRecognizer *singleTapTwo =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap)];
singleTapTwo.numberOfTapsRequired = 1;
[self.doubleTapToSkipAhead addGestureRecognizer:singleTapTwo];
UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc]
    initWithTarget:self
            action:@selector(fastforwardGestureFired)];
doubleTapTwo.numberOfTapsRequired = 2;
[self.doubleTapToSkipAhead addGestureRecognizer:doubleTapTwo];
[singleTapTwo requireGestureRecognizerToFail:doubleTapTwo];
// [self.superview.superview.superview addSubview:self.doubleTapToSkipAhead];
// [self.doubleTapToSkipAhead
// anchorTop:self.superview.superview.superview.topAnchor
// leading:self.superview.superview.superview.centerXAnchor
// bottom:self.superview.superview.superview.bottomAnchor
// trailing:self.superview.superview.superview.trailingAnchor
// padding:UIEdgeInsetsMake(0, 70, 0, 0) size:CGSizeZero];

// Double tap to rewind
self.doubleTapToSkipBack = [[UIView alloc] init];
self.doubleTapToSkipBack.alpha = 0.1;
self.doubleTapToSkipBack.layer.cornerCurve = kCACornerCurveContinuous;
self.doubleTapToSkipBack.clipsToBounds = YES;
self.doubleTapToSkipBack.layer.cornerRadius = 140;
self.doubleTapToSkipBack.layer.maskedCorners =
    kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
self.doubleTapToSkipBack.backgroundColor = UIColor.clearColor;
UITapGestureRecognizer *singleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap)];
singleTap.numberOfTapsRequired = 1;
[self.doubleTapToSkipBack addGestureRecognizer:singleTap];
UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
    initWithTarget:self
            action:@selector(rewindGestureFired)];
doubleTap.numberOfTapsRequired = 2;
[self.doubleTapToSkipBack addGestureRecognizer:doubleTap];
[singleTap requireGestureRecognizerToFail:doubleTap];
// [self.superview.superview.superview addSubview:self.doubleTapToSkipBack];
// [self.doubleTapToSkipBack
// anchorTop:self.superview.superview.superview.topAnchor
// leading:self.superview.superview.superview.leadingAnchor
// bottom:self.superview.superview.superview.bottomAnchor
// trailing:self.superview.superview.superview.centerXAnchor
// padding:UIEdgeInsetsMake(0, 0, 0, 70) size:CGSizeZero];

// %hook AVPlaybackControlsView

// %property(nonatomic, retain) UIBlurEffect *blurEffect;
// %property(nonatomic, retain) UIVisualEffectView *blurEffectView;

// -(void)setupInitialLayout {
//   NSLog(@"setupInitialLayout");
//   [[NSNotificationCenter defaultCenter] addObserver:self
//   selector:@selector(toggleBlur) name:@"toggleCustomBlurView" object:nil];
//   self.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//   self.blurEffectView = [[UIVisualEffectView alloc]
//   initWithEffect:self.blurEffect];
//   //always fill the view
//   self.blurEffectView.userInteractionEnabled = NO;
//   self.blurEffectView.frame = self.bounds;
//   self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
//   UIViewAutoresizingFlexibleHeight; self.blurEffectView.alpha = 0.4f; if
//   (![self.blurEffectView isDescendantOfView:self]) [self
//   insertSubview:self.blurEffectView atIndex:0]; %orig;
// }
// -(void)playbackControlsView:(id)arg1
// animateAlongsideVisibilityAnimationsWithAnimationCoordinator:(id)arg2
// appearingViews:(id)arg3 disappearingViews:(id)arg4 {
//   %orig;

//  if (!showing) {
//     [self.blurEffectView removeFromSuperview];
//     showing = NO;
//     NSLog(@"blur removed");
//   } else {
//     showing = YES;
//     if (!self.blurEffectView) {
//       self.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//       self.blurEffectView = [[UIVisualEffectView alloc]
//       initWithEffect:self.blurEffect];
//     }
//     self.blurEffectView.userInteractionEnabled = NO;
//     self.blurEffectView.frame = self.bounds;
//     self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
//     UIViewAutoresizingFlexibleHeight; self.blurEffectView.alpha = 0.4f; if
//     (![self.blurEffectView isDescendantOfView:self]) [self
//     insertSubview:self.blurEffectView atIndex:0]; NSLog(@"blur inserted");
//   }

// }
// %new
// -(void)toggleBlur {
//   // NSLog(@"toggleBlur");
//   if (!showing) {
//     [self.blurEffectView removeFromSuperview];
//     showing = NO;
//     NSLog(@"blur removed");
//   } else {
//     showing = YES;
//     if (!self.blurEffectView) {
//       self.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//       self.blurEffectView = [[UIVisualEffectView alloc]
//       initWithEffect:self.blurEffect];
//     }
//     self.blurEffectView.userInteractionEnabled = NO;
//     self.blurEffectView.frame = self.bounds;
//     self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
//     UIViewAutoresizingFlexibleHeight; self.blurEffectView.alpha = 0.4f; if
//     (![self.blurEffectView isDescendantOfView:self]) [self
//     insertSubview:self.blurEffectView atIndex:0]; NSLog(@"blur inserted");
//   }
// }
// -(void)dealloc {
// 	%orig;
// 	[[NSNotificationCenter defaultCenter] removeObserver:self];
// }
// %end

// %new
// -(void)hideScrubberAndLabels {
//   [UIView animateWithDuration:0.2
//           animations:^{
//             self.scrubber.alpha = 0;
//             self.elapsedTimeLabel.alpha = 0;
//             self.timeRemainingLabel.alpha = 0;
//             self.standardPlayPauseButton.alpha = 0;

//             self.closeButton.alpha = 0;
//             self.airplayButton.alpha = 0;
//             self.pipButton.alpha = 0;
//             self.gravityButton.alpha = 0;
//             self.rewindButton.alpha = 0;
//             self.fastforwardButton.alpha = 0;
//           }];
//           showing = NO;
// }
// %new
// -(void)showScrubberAndLabels {
//   [UIView animateWithDuration:0.2
//           animations:^{
//             self.scrubber.alpha = 1;
//             self.elapsedTimeLabel.alpha = 1;
//             self.timeRemainingLabel.alpha = 1;
//             self.standardPlayPauseButton.alpha = 1;

//             self.closeButton.alpha = 1;
//             self.airplayButton.alpha = 1;
//             self.pipButton.alpha = 1;
//             self.gravityButton.alpha = 1;
//             self.rewindButton.alpha = 1;
//             self.fastforwardButton.alpha = 1;
//           }];
//           showing = YES;

// }

// Hide the background blur around the old buttons
%
    hook AVCABackdropLayerView
    // -(BOOL)isHidden {
    //   return YES;
    // }
    // -(void)setHidden:(BOOL)hidden {
    //   %orig(YES);
    // }
    // -(void)layoutSubviews {
    //   self.hidden = YES;
    // }
    % end