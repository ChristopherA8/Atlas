#import "StuffINeed.h"

// Try overriding the hidden getter for these methods
// Instead of using layoutSubviews :)

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
%property(nonatomic, retain) AVButton *pipButton;
%property(nonatomic, retain) AVButton *gravityButton;
%property(nonatomic, retain) AVButton *airplayButton;

%property(nonatomic, retain) UIBlurEffect *blurEffect;
%property(nonatomic, retain) UIVisualEffectView *blurEffectView;

-(id)initWithFrame:(CGRect)arg1 styleSheet:(id)arg2 {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideScrubberAndLabels) name:@"hideScrubber" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showScrubberAndLabels) name:@"showScrubber" object:nil];
  return %orig;
}

-(void)_layoutDoubleRowViews {
  if (![self.scrubber isDescendantOfView:self]) {

    self.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:self.blurEffect];
    self.blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    self.blurEffectView.userInteractionEnabled = NO;
    [self addSubview:self.blurEffectView];

    [self.blurEffectView anchorTop:self.superview.superview.superview.topAnchor leading:self.superview.superview.superview.leadingAnchor bottom:self.superview.superview.superview.bottomAnchor trailing:self.superview.superview.superview.trailingAnchor padding:UIEdgeInsetsZero size:CGSizeZero];

    // This is just being used to anchor the other views and can be removed, now that I shoved everything into a single class
    self.anchorCenterItem = [[%c(AVButton) alloc] init]; // This was the old playPause button, before I just repurposed the old one
    self.anchorCenterItem.translatesAutoresizingMaskIntoConstraints = NO;

    // Make the play button white
    [self.standardPlayPauseButton.imageView setTintColor:UIColor.whiteColor];

    // Rewind button.. pretty self explanatory
    self.rewindButton = [[%c(AVButton) alloc] init];
    [self.rewindButton setImage:[UIImage systemImageNamed:@"backward.fill"
                                    withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:22
                                                                                  weight:UIImageSymbolWeightRegular
                                                                                  scale:UIImageSymbolScaleMedium]]
                                    forState:UIControlStateNormal];
    [self.rewindButton addTarget:self 
                  action:@selector(rewindButtonPressed)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.rewindButton.imageView setTintColor:UIColor.whiteColor];
    self.rewindButton.translatesAutoresizingMaskIntoConstraints = NO;

    // This is a fastforward button
    // I learned that fastforward was spelled fastforward and not fastforeward while making this tweak :)
    self.fastforwardButton = [[%c(AVButton) alloc] init];
    [self.fastforwardButton setImage:[UIImage systemImageNamed:@"forward.fill"
                                         withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:22
                                                                                        weight:UIImageSymbolWeightRegular
                                                                                        scale:UIImageSymbolScaleMedium]]
                                         forState:UIControlStateNormal]; // tfw it doesn't line up perfectly by tabbing, so you have to use spaces ;c
    [self.fastforwardButton addTarget:self 
                       action:@selector(fastforwardButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
    [self.fastforwardButton.imageView setTintColor:UIColor.whiteColor];
    self.fastforwardButton.translatesAutoresizingMaskIntoConstraints = NO;

    for (UIView *view in @[self.anchorCenterItem, self.rewindButton, self.fastforwardButton]) [self addSubview:view];

    // I use self.superview.superview.superview a lot in this project, but I don't even know what it is
    // It just happened to have bounds that fit the whole screen so I used it
    // CODING 100
    [self.anchorCenterItem centerInView:self.superview.superview.superview];
    [self.anchorCenterItem heightWidthAnchorsEqualToSize:CGSizeMake(30, 30)];

    // UIView extensions for constraints are pog
    // making UIs without them would be such a pain
    // feel free to steal my UIView+Constrinats.h/.m files
    [self.rewindButton anchorTop:self.anchorCenterItem.topAnchor
                    leading:nil
                    bottom:self.anchorCenterItem.bottomAnchor
                  trailing:self.anchorCenterItem.leadingAnchor
                    padding:UIEdgeInsetsMake(0, 0, 0, 25)
                      size:CGSizeMake(30, 30)];

    [self.fastforwardButton anchorTop:self.anchorCenterItem.topAnchor
                        leading:self.anchorCenterItem.trailingAnchor
                          bottom:self.anchorCenterItem.bottomAnchor
                        trailing:nil
                        padding:UIEdgeInsetsMake(0, 25, 0, 0)
                            size:CGSizeMake(30, 30)];

    self.pipButton = [[%c(AVButton) alloc] init];
    [self.pipButton setImage:[UIImage systemImageNamed:@"pip" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.pipButton.imageView setTintColor:UIColor.whiteColor];
    [self.pipButton addTarget:self 
               action:@selector(pipButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    self.pipButton.translatesAutoresizingMaskIntoConstraints = NO;

    // why did apple call this gravity
    // what does the video size have to do with gravity
    // if someone knows, pls explain
    self.gravityButton = [[%c(AVButton) alloc] init]; // person.crop.rectangle lol
    [self.gravityButton setImage:[UIImage systemImageNamed:@"person.crop.rectangle" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.gravityButton.imageView setTintColor:UIColor.whiteColor];
    [self.gravityButton addTarget:self 
                   action:@selector(gravityButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    self.gravityButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.airplayButton = [[%c(AVButton) alloc] init];
    [self.airplayButton setImage:[UIImage systemImageNamed:@"airplayvideo" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.airplayButton.imageView setTintColor:UIColor.whiteColor];
    [self.airplayButton addTarget:self 
                   action:@selector(airplayButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    self.airplayButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.closeButton = [[%c(AVButton) alloc] init];
    [self.closeButton setImage:[UIImage systemImageNamed:@"xmark" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.closeButton.imageView setTintColor:UIColor.whiteColor];
    [self.closeButton addTarget:self 
                 action:@selector(closeButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;

    for (UIView *view in @[self.pipButton, self.closeButton, self.airplayButton, self.gravityButton]) [self addSubview:view];

    [self.pipButton anchorTop:self.superview.superview.superview.topAnchor leading:nil bottom:nil trailing:self.superview.superview.superview.trailingAnchor padding:UIEdgeInsetsMake(15, 0, 15, 15) size:CGSizeMake(40, 40)];
    [self.gravityButton anchorTop:self.superview.superview.superview.topAnchor leading:nil bottom:nil trailing:self.pipButton.leadingAnchor padding:UIEdgeInsetsMake(15, 0, 15, 15) size:CGSizeMake(40, 40)];
    [self.airplayButton anchorTop:self.superview.superview.superview.topAnchor leading:nil bottom:nil trailing:self.gravityButton.leadingAnchor padding:UIEdgeInsetsMake(15, 0, 15, 15) size:CGSizeMake(40, 40)];
    [self.closeButton anchorTop:self.superview.superview.superview.topAnchor leading:self.superview.superview.superview.leadingAnchor bottom:nil trailing:nil padding:UIEdgeInsetsMake(15, 15, 15, 0) size:CGSizeMake(40, 40)];

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
                   padding:UIEdgeInsetsMake(0, 10, 0, 10)
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

    self.anchorCenterItem.alpha = 0;
    self.rewindButton.alpha = 1;
    self.fastforwardButton.alpha = 1;
    self.closeButton.alpha = 1;
    self.airplayButton.alpha = 1;
    self.pipButton.alpha = 1;
    self.gravityButton.alpha = 1;
    self.scrubber.alpha = 1;
    self.elapsedTimeLabel.alpha = 1;
    self.timeRemainingLabel.alpha = 1;
    self.blurEffectView.alpha = 0.4f;

  }
}
-(void)_layoutSingleRowViews {
  // the single row layout is what the video player looks like in landscape mode
  // So, this runs when the orientation is in landscape
  [self _layoutDoubleRowViews]; // This is here in case I start the video in landscape
  // The lack of %orig is so that the old views don't appear
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
// I don't think I need this here :)
-(void)_handleSingleTapGesture:(id)arg1 {
  %orig;
}
-(void)_handleDoubleTapGesture:(UITapGestureRecognizer *)arg1 {
  // This handles the rewind/fastforward double tap gesture
  // It just checks which side of the screen the touch point came from

  if (arg1.state == UIGestureRecognizerStateEnded) {
    CGPoint point = [arg1 locationInView:self.view.superview.superview.superview];
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    if (point.x < (screenWidth/2)) {
      // Left
      [self _handleSkipBack15SecondsKeyCommand:nil];
    } else {
      // Right
      [self _handleSkipAhead15SecondsKeyCommand:nil];
    }
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