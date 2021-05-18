// Good coding practices 101
//
// Name your headers something useful
// Instead of Headers.h
// Why not try calling it "ThingsThatMakeMyCodeWork.h"
// Or "LimenosSiteIsSlow.h"
// These names have true meaning and will help you
// Especially when looking back at your code in the future
//
//
// :)
//
//
//
// anyways

#import "UIView+Constraints.h"
#import <AVFoundation/AVFoundation.h>

@interface AVButton : UIButton
@property(nonatomic, retain) UIVisualEffectView *backgroundEffectView;
@end

@interface AVView : UIView
@end

@interface AVLabel : UIView
@property(nonatomic, readonly) UILabel *label;
@end

@interface AVScrubber : UISlider
@end

@interface AVLayoutView : AVView
@end

@interface AVCABackdropLayerView : UIView
@end

@interface AVTouchIgnoringView : UIView
@end

@interface AVRoutePickerView : UIView
- (void)_routePickerButtonTapped:(id)arg1;
@end

@interface AVPlaybackControlsRoutePickerView : AVRoutePickerView
@end

// Should I have used properties instead of global variables?
// Yes
// Did I?
// No
// :)
// This whole project was literally redone and has been majorly refactored many
// times, so it's kind of a mess. If you're looking for help making a tweak, pls
// don't try to copy what I do here :)
// AVButton *anchorCenterItem;
// AVButton *rewindButton;
// AVButton *fastforwardButton;
// AVButton *closeButton;
// UIBlurEffect *blurEffect;
// UIVisualEffectView *blurEffectView;
// UIView *doubleTapToSkipAhead;
// UIView *doubleTapToSkipBack;
// // More actions buttons
// AVButton *pipButton;
// AVButton *gravityButton;
// AVButton *airplayButton;

@interface AVTransportControlsView : UIView
// @property (assign, nonatomic) AVButton *skipBackButton;
// @property (assign, nonatomic) AVButton *skipForwardButton;
@property(assign, nonatomic) AVButton *standardPlayPauseButton;
@property(nonatomic, readonly) AVScrubber *scrubber;
@property(nonatomic, readonly) AVLabel *elapsedTimeLabel;
@property(nonatomic, readonly) AVLabel *timeRemainingLabel;

@property(nonatomic, retain) AVButton *anchorCenterItem;
@property(nonatomic, retain) AVButton *rewindButton;
@property(nonatomic, retain) AVButton *fastforwardButton;
@property(nonatomic, retain) AVButton *closeButton;
@property(nonatomic, retain) UIBlurEffect *blurEffect;
@property(nonatomic, retain) UIVisualEffectView *blurEffectView;
@property(nonatomic, retain) UIView *doubleTapToSkipAhead;
@property(nonatomic, retain) UIView *doubleTapToSkipBack;
@property(nonatomic, retain) AVButton *pipButton;
@property(nonatomic, retain) AVButton *gravityButton;
@property(nonatomic, retain) AVButton *airplayButton;

- (id)initWithFrame:(CGRect)arg1 styleSheet:(id)arg2;
- (AVButton *)skipBackButton;
- (void)_layoutDoubleRowViews;
- (void)_layoutSingleRowViews;
- (void)dealloc;

// %new
- (void)hideScrubberAndLabels;
- (void)showScrubberAndLabels;
// %new
- (void)playButtonPressed;
- (void)closeButtonPressed;
- (void)rewindButtonPressed;
- (void)fastforwardButtonPressed;
- (void)toggleControls;
- (void)rewindGestureFired;
- (void)fastforwardGestureFired;
- (void)pipButtonPressed;
- (void)gravityButtonPressed;
- (void)airplayButtonPressed;
- (void)handleSingleTap;
@end

@interface AVPlaybackControlsView : UIView
@property(nonatomic, readonly)
    AVButton *videoGravityButton; // This is what I was using for the image
- (void)setFullScreen:(BOOL)arg1;
@end

@interface AVPlayerViewController : UIViewController
// @property (nonatomic,retain) AVPlayerController * playerController;
- (id)initWithPlayerLayerView:(id)arg1;
- (void)togglePlayback:(id)arg1;
- (void)doneButtonTapped:(id)arg1;
- (void)_handleSkipBack15SecondsKeyCommand:(id)arg1;
- (void)_handleSkipAhead15SecondsKeyCommand:(id)arg1;
- (void)pictureInPictureButtonTapped:(id)arg1;
- (void)videoGravityButtonTapped:(id)arg1;
- (void)dealloc;
@end