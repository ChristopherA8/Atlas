#import "StuffINeed.h"

// Hide the background blur around the old buttons
%hook AVCABackdropLayerView
-(void)layoutSubviews {
  self.hidden = YES;
}
%end

// Hide everything from the old layout
%hook AVLayoutView
-(void)layoutSubviews {
  self.hidden = YES;
}
%end

// Steal the pre-existing AVScrubber and playPauseButton, so that I don't have to implement my own :p
%hook AVTransportControlsView

%property(nonatomic, retain) AVButton *anchorCenterItem;
%property(nonatomic, retain) AVButton *rewindButton;
%property(nonatomic, retain) AVButton *fastforwardButton;
%property(nonatomic, retain) AVButton *closeButton;
%property(nonatomic, retain) UIBlurEffect *blurEffect;
%property(nonatomic, retain) UIVisualEffectView *blurEffectView;
%property(nonatomic, retain) UIView *doubleTapToSkipAhead;
%property(nonatomic, retain) UIView *doubleTapToSkipBack;
%property(nonatomic, retain) AVButton *pipButton;
%property(nonatomic, retain) AVButton *gravityButton;
%property(nonatomic, retain) AVButton *airplayButton;

-(id)initWithFrame:(CGRect)arg1 styleSheet:(id)arg2 {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideScrubberAndLabels) name:@"hideScrubber" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showScrubberAndLabels) name:@"showScrubber" object:nil];
  return %orig;
}

-(void)_layoutDoubleRowViews {
  if (![self.scrubber isDescendantOfView:self]) {

    // Double tap to fastforward
    doubleTapToSkipAhead = [[UIView alloc] init];
    doubleTapToSkipAhead.alpha = 0.1;
    doubleTapToSkipAhead.layer.cornerCurve = kCACornerCurveContinuous;
    doubleTapToSkipAhead.clipsToBounds = YES;
    doubleTapToSkipAhead.layer.cornerRadius = 140;
    doubleTapToSkipAhead.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    doubleTapToSkipAhead.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer *singleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleTapTwo.numberOfTapsRequired = 1;
    [doubleTapToSkipAhead addGestureRecognizer:singleTapTwo];
    UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fastforwardGestureFired)];
    doubleTapTwo.numberOfTapsRequired = 2;
    [doubleTapToSkipAhead addGestureRecognizer:doubleTapTwo];
    [singleTapTwo requireGestureRecognizerToFail:doubleTapTwo];
    [self.superview.superview.superview addSubview:doubleTapToSkipAhead];
    [doubleTapToSkipAhead anchorTop:self.superview.superview.superview.topAnchor leading:self.superview.superview.superview.centerXAnchor bottom:self.superview.superview.superview.bottomAnchor trailing:self.superview.superview.superview.trailingAnchor padding:UIEdgeInsetsMake(0, 70, 0, 0) size:CGSizeZero];

    // Double tap to rewind
    doubleTapToSkipBack = [[UIView alloc] init];
    doubleTapToSkipBack.alpha = 0.1;
    doubleTapToSkipBack.layer.cornerCurve = kCACornerCurveContinuous;
    doubleTapToSkipBack.clipsToBounds = YES;
    doubleTapToSkipBack.layer.cornerRadius = 140;
    doubleTapToSkipBack.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner;
    doubleTapToSkipBack.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    singleTap.numberOfTapsRequired = 1;
    [doubleTapToSkipBack addGestureRecognizer:singleTap];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rewindGestureFired)];
    doubleTap.numberOfTapsRequired = 2;
    [doubleTapToSkipBack addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.superview.superview.superview addSubview:doubleTapToSkipBack];
    [doubleTapToSkipBack anchorTop:self.superview.superview.superview.topAnchor leading:self.superview.superview.superview.leadingAnchor bottom:self.superview.superview.superview.bottomAnchor trailing:self.superview.superview.superview.centerXAnchor padding:UIEdgeInsetsMake(0, 0, 0, 70) size:CGSizeZero];

    // Stack ovrflow copy paste go brrr
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //always fill the view
        blurEffectView.userInteractionEnabled = NO;
        blurEffectView.frame = self.superview.superview.superview.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurEffectView.alpha = 0.4f;
        // tfw you keep adding .superview until something works :)
        [self.superview.superview.superview insertSubview:blurEffectView atIndex:0];
    }

    // This is just being used to anchor the other views and can be removed, now that I shoved everything into a single class
    anchorCenterItem = [[%c(AVButton) alloc] init]; // This was the old playPause button, before I just repurposed the old one
    anchorCenterItem.translatesAutoresizingMaskIntoConstraints = NO;

    // Make the play button white
    [self.standardPlayPauseButton.imageView setTintColor:UIColor.whiteColor];

    // Rewind button.. pretty self explanatory
    rewindButton = [[%c(AVButton) alloc] init];
    [rewindButton setImage:[UIImage systemImageNamed:@"backward.fill"
                                    withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:25
                                                                                  weight:UIImageSymbolWeightRegular
                                                                                  scale:UIImageSymbolScaleMedium]]
                                    forState:UIControlStateNormal];
    [rewindButton addTarget:self 
                  action:@selector(rewindButtonPressed)
                  forControlEvents:UIControlEventTouchUpInside];
    [rewindButton.imageView setTintColor:UIColor.whiteColor];
    rewindButton.translatesAutoresizingMaskIntoConstraints = NO;

    // This is a fastforward button
    // I learned that fastforward was spelled fastforward and not fastforeward while making this tweak :)
    fastforwardButton = [[%c(AVButton) alloc] init];
    [fastforwardButton setImage:[UIImage systemImageNamed:@"forward.fill"
                                         withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:25
                                                                                        weight:UIImageSymbolWeightRegular
                                                                                        scale:UIImageSymbolScaleMedium]]
                                         forState:UIControlStateNormal]; // tfw it doesn't line up perfectly by tabbing, so you have to use spaces ;c
    [fastforwardButton addTarget:self 
                       action:@selector(fastforwardButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
    [fastforwardButton.imageView setTintColor:UIColor.whiteColor];
    fastforwardButton.translatesAutoresizingMaskIntoConstraints = NO;

    for (UIView *view in @[anchorCenterItem, rewindButton, fastforwardButton]) [self addSubview:view];

    // I use self.superview.superview.superview a lot in this project, but I don't even know what it is
    // It just happened to have bounds that fit the whole screen so I used it
    // CODING 100
    [anchorCenterItem centerInView:self.superview.superview.superview];
    [anchorCenterItem heightWidthAnchorsEqualToSize:CGSizeMake(30, 30)];

    // UIView extensions for constraints are pog
    // making UIs without them would be such a pain
    // feel free to steal my UIView+Constrinats.h/.m files
    [rewindButton anchorTop:anchorCenterItem.topAnchor
                    leading:nil
                    bottom:anchorCenterItem.bottomAnchor
                  trailing:anchorCenterItem.leadingAnchor
                    padding:UIEdgeInsetsMake(0, 0, 0, 20)
                      size:CGSizeMake(30, 30)];

    [fastforwardButton anchorTop:anchorCenterItem.topAnchor
                        leading:anchorCenterItem.trailingAnchor
                          bottom:anchorCenterItem.bottomAnchor
                        trailing:nil
                        padding:UIEdgeInsetsMake(0, 20, 0, 0)
                            size:CGSizeMake(30, 30)];

    pipButton = [[%c(AVButton) alloc] init];
    [pipButton setImage:[UIImage systemImageNamed:@"pip" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [pipButton.imageView setTintColor:UIColor.whiteColor];
    [pipButton addTarget:self 
               action:@selector(pipButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    pipButton.translatesAutoresizingMaskIntoConstraints = NO;

    // why did apple call this gravity
    // what does the video size have to do with gravity
    // if someone knows, pls explain
    gravityButton = [[%c(AVButton) alloc] init]; // person.crop.rectangle lol
    [gravityButton setImage:[UIImage systemImageNamed:@"person.crop.rectangle" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [gravityButton.imageView setTintColor:UIColor.whiteColor];
    [gravityButton addTarget:self 
                   action:@selector(gravityButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    gravityButton.translatesAutoresizingMaskIntoConstraints = NO;

    airplayButton = [[%c(AVButton) alloc] init];
    [airplayButton setImage:[UIImage systemImageNamed:@"airplayvideo" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [airplayButton.imageView setTintColor:UIColor.whiteColor];
    [airplayButton addTarget:self 
                   action:@selector(airplayButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    airplayButton.translatesAutoresizingMaskIntoConstraints = NO;

    closeButton = [[%c(AVButton) alloc] init];
    [closeButton setImage:[UIImage systemImageNamed:@"xmark" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [closeButton.imageView setTintColor:UIColor.whiteColor];
    [closeButton addTarget:self 
                 action:@selector(closeButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;

    for (UIView *view in @[pipButton, closeButton, airplayButton, gravityButton]) [self addSubview:view];

    [pipButton anchorTop:self.superview.superview.superview.topAnchor leading:nil bottom:nil trailing:self.superview.superview.superview.trailingAnchor padding:UIEdgeInsetsMake(15, 0, 15, 15) size:CGSizeMake(40, 40)];
    [gravityButton anchorTop:self.superview.superview.superview.topAnchor leading:nil bottom:nil trailing:pipButton.leadingAnchor padding:UIEdgeInsetsMake(15, 0, 15, 15) size:CGSizeMake(40, 40)];
    [airplayButton anchorTop:self.superview.superview.superview.topAnchor leading:nil bottom:nil trailing:gravityButton.leadingAnchor padding:UIEdgeInsetsMake(15, 0, 15, 15) size:CGSizeMake(40, 40)];
    [closeButton anchorTop:self.superview.superview.superview.topAnchor leading:self.superview.superview.superview.leadingAnchor bottom:nil trailing:nil padding:UIEdgeInsetsMake(15, 15, 15, 0) size:CGSizeMake(40, 40)];

    [self addSubview:self.scrubber];
    [self addSubview:self.elapsedTimeLabel];
    [self addSubview:self.timeRemainingLabel];
    [self addSubview:self.standardPlayPauseButton];
    self.standardPlayPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.standardPlayPauseButton centerInView:self.superview.superview.superview];
    [self.standardPlayPauseButton heightWidthAnchorsEqualToSize:CGSizeMake(30, 30)];
    [self.scrubber anchorTop:nil 
                   leading:self.leadingAnchor
                   bottom:self.bottomAnchor
                   trailing:self.trailingAnchor
                   padding:UIEdgeInsetsMake(0, 10, 3, 10)
                   size:CGSizeMake(0,40)];
    [self.elapsedTimeLabel anchorTop:nil 
                           leading:self.scrubber.leadingAnchor 
                           bottom:self.scrubber.topAnchor
                           trailing:nil
                           padding:UIEdgeInsetsMake(0, 0, 0, 0)
                           size:CGSizeMake(40,20)];
    [self.timeRemainingLabel anchorTop:nil 
                             leading:nil
                             bottom:self.scrubber.topAnchor
                             trailing:self.scrubber.trailingAnchor
          padding:UIEdgeInsetsMake(0, 0, 0, 0)
              size:CGSizeMake(40,20)];
    [self.elapsedTimeLabel.label setTextAlignment:NSTextAlignmentLeft];
    [self.timeRemainingLabel.label setTextAlignment:NSTextAlignmentRight];

    anchorCenterItem.alpha = 0;
    rewindButton.alpha = 1;
    fastforwardButton.alpha = 1;
    closeButton.alpha = 1;
    airplayButton.alpha = 1;
    pipButton.alpha = 1;
    gravityButton.alpha = 1;
    blurEffectView.alpha = 0.4f;
    self.scrubber.alpha = 1;
    self.elapsedTimeLabel.alpha = 1;
    self.timeRemainingLabel.alpha = 1;
    // [self showScrubberAndLabels]; Testing whether I need this here or not
  }
}
-(void)_layoutSingleRowViews {
  // the single row layout is what the video player looks like in landscape mode
  // So, this runs when the orientation is in landscape
  [self _layoutDoubleRowViews]; // This is here in case I start the video in landscape
  // The lack of %orig is so that the old views don't appear
}
%new
-(void)hideScrubberAndLabels {
  [UIView animateWithDuration:0.2
          animations:^{
            self.scrubber.alpha = 0;
            self.elapsedTimeLabel.alpha = 0;
            self.timeRemainingLabel.alpha = 0;
            self.standardPlayPauseButton.alpha = 0;

            closeButton.alpha = 0;
            airplayButton.alpha = 0;
            pipButton.alpha = 0;
            gravityButton.alpha = 0;
            rewindButton.alpha = 0;
            fastforwardButton.alpha = 0;
            blurEffectView.alpha = 0;
          }];
}
%new
-(void)showScrubberAndLabels {
  [UIView animateWithDuration:0.2
          animations:^{
            self.scrubber.alpha = 1;
            self.elapsedTimeLabel.alpha = 1;
            self.timeRemainingLabel.alpha = 1;
            self.standardPlayPauseButton.alpha = 1;

            closeButton.alpha = 1;
            airplayButton.alpha = 1;
            pipButton.alpha = 1;
            gravityButton.alpha = 1;
            rewindButton.alpha = 1;
            fastforwardButton.alpha = 1;
            blurEffectView.alpha = 0.4f;
          }];
}
%new
-(void)closeButtonPressed {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"doneButtonFromCustomButton" object:self];
}
%new
-(void)rewindButtonPressed {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"skipBack" object:self];
}
%new
-(void)fastforwardButtonPressed {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"skipAhead" object:self];
}
%new
-(void)rewindGestureFired {
  [self rewindButtonPressed];
}
%new
-(void)fastforwardGestureFired {
  [self fastforwardButtonPressed];
}
%new
-(void)pipButtonPressed {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"pipButton" object:self];
}
%new
-(void)gravityButtonPressed {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"videoGravityButton" object:self];
}
%new
-(void)airplayButtonPressed {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"airplayButton" object:self];
}
// This is called when you tap on one of the doubleTapGestureViews on either side of the video player
%new
-(void)handleSingleTap {
  NSLog(@"handleSingleTap ran");
  // if (self.standardPlayPauseButton.alpha == 1) {
  //   [self hideScrubberAndLabels];
  // } else {
  //   [self showScrubberAndLabels];
  // }
  if (self.standardPlayPauseButton.alpha == 1) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideScrubber" object:self];
  } else {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showScrubber" object:self];
  }
}
-(void)dealloc {
	%orig;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
%end

%hook AVRoutePickerView
-(id)initWithFrame:(CGRect)arg1 {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_routePickerButtonTapped:) name:@"airplayButton" object:nil];
  return %orig;
}
// This is called when we press the screen mirroring button
-(void)_routePickerButtonTapped:(id)arg1 {
  %orig;
}
%end

%hook AVPlayerViewController
-(id)initWithPlayerLayerView:(id)arg1 {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneButtonTapped:) name:@"doneButtonFromCustomButton" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleSkipAhead15SecondsKeyCommand:) name:@"skipAhead" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleSkipBack15SecondsKeyCommand:) name:@"skipBack" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pictureInPictureButtonTapped:) name:@"pipButton" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoGravityButtonTapped:) name:@"videoGravityButton" object:nil];  
  return %orig;
}
-(void)doneButtonTapped:(id)arg1 {
  // NSLog(@"done button tapped");
  %orig;
}
-(void)_handleSkipBack15SecondsKeyCommand:(id)arg1 {
  // NSLog(@"_handleSkipBack15SecondsKeyCommand");
  %orig;
}
-(void)_handleSkipAhead15SecondsKeyCommand:(id)arg1 {
  // NSLog(@"_handleSkipAhead15SecondsKeyCommand");
  %orig;
}
-(void)pictureInPictureButtonTapped:(id)arg1 {
  // NSLog(@"pictureInPictureButtonTapped");
  %orig;
}
-(void)videoGravityButtonTapped:(id)arg1 {
  // NSLog(@"videoGravityButtonTapped");
  %orig;
}
-(void)_handleSingleTapGesture:(id)arg1 {
  %orig;
  if (blurEffectView.alpha == 1) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideScrubber" object:self];
  } else {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showScrubber" object:self];
  }
}
-(void)dealloc {
	%orig;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
%end


// This is here as a sanity check, so I know if I spelled the dylib path correctly in the console search bar
%ctor {
  NSLog(@"custom player loaded");
}