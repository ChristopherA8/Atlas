#import "Tweak.h"

%group Atlas

// Hide everything from the old layout
%hook AVLayoutView
-(void)layoutSubviews {
  self.hidden = YES;
  // ik ik but I swear overriding the "hidden" getter/setter didn't work. Take that as you will
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
%property(nonatomic, retain) AVButton *orientationButton;

%property(nonatomic, retain) AVButton *pipButton2;
%property(nonatomic, retain) AVButton *gravityButton2;
%property(nonatomic, retain) AVButton *airplayButton2;
%property(nonatomic, retain) AVButton *orientationButton2;

%property(nonatomic, retain) AVButton *pipButton3;
%property(nonatomic, retain) AVButton *gravityButton3;
%property(nonatomic, retain) AVButton *airplayButton3;
%property(nonatomic, retain) AVButton *orientationButton3;

%property(nonatomic, retain) UIView *darkOverlay;
%property (nonatomic, retain) UIView *numberView;
%property (nonatomic, retain) UILabel *leftNumber;
%property (nonatomic, retain) UILabel *rightNumber;

- (id)initWithFrame:(CGRect)arg1 styleSheet:(id)arg2 {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftGesture) name:@"leftGesture" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightGesture) name:@"rightGesture" object:nil];
  return %orig;
}

-(void)_layoutDoubleRowViews {
  if (![self.scrubber isDescendantOfView:self]) {

    self.darkOverlay = [[UIView alloc] init];
    self.darkOverlay.translatesAutoresizingMaskIntoConstraints = NO;
    self.darkOverlay.userInteractionEnabled = NO;
    self.darkOverlay.backgroundColor = UIColor.blackColor;
    [self addSubview:self.darkOverlay];

    [self.darkOverlay atlas_anchorTop:self.superview.superview.superview.topAnchor leading:self.superview.superview.superview.leadingAnchor bottom:self.superview.superview.superview.bottomAnchor trailing:self.superview.superview.superview.trailingAnchor padding:UIEdgeInsetsZero size:CGSizeZero];

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
    [self.anchorCenterItem atlas_centerInView:self.superview.superview.superview];
    [self.anchorCenterItem atlas_heightWidthAnchorsEqualToSize:CGSizeMake(30, 30)];

    // UIView extensions for constraints are pog
    // making UIs without them would be such a pain
    // feel free to steal my UIView+Constrinats.h/.m files
    [self.rewindButton atlas_anchorTop:self.anchorCenterItem.topAnchor
                    leading:nil
                    bottom:self.anchorCenterItem.bottomAnchor
                  trailing:self.anchorCenterItem.leadingAnchor
                    padding:UIEdgeInsetsMake(0, 0, 0, 25)
                      size:CGSizeMake(30, 30)];

    [self.fastforwardButton atlas_anchorTop:self.anchorCenterItem.topAnchor
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

    self.pipButton2 = [[%c(AVButton) alloc] init];
    [self.pipButton2 setImage:[UIImage systemImageNamed:@"pip" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.pipButton2.imageView setTintColor:UIColor.whiteColor];
    [self.pipButton2 addTarget:self 
               action:@selector(pipButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    self.pipButton2.translatesAutoresizingMaskIntoConstraints = NO;

    self.pipButton3 = [[%c(AVButton) alloc] init];
    [self.pipButton3 setImage:[UIImage systemImageNamed:@"pip" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.pipButton3.imageView setTintColor:UIColor.whiteColor];
    [self.pipButton3 addTarget:self 
               action:@selector(pipButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    self.pipButton3.translatesAutoresizingMaskIntoConstraints = NO;

    self.gravityButton = [[%c(AVButton) alloc] init]; // person.crop.rectangle lol   I ~~couldn't~~ didn't want to reuse the original image for various reasons, mainly because it wasn't a standard SFSymbol
    [self.gravityButton setImage:[UIImage systemImageNamed:@"person.crop.rectangle" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.gravityButton.imageView setTintColor:UIColor.whiteColor];
    [self.gravityButton addTarget:self 
                   action:@selector(gravityButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    self.gravityButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.gravityButton2 = [[%c(AVButton) alloc] init]; // person.crop.rectangle lol   I ~~couldn't~~ didn't want to reuse the original image for various reasons, mainly because it wasn't a standard SFSymbol
    [self.gravityButton2 setImage:[UIImage systemImageNamed:@"person.crop.rectangle" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.gravityButton2.imageView setTintColor:UIColor.whiteColor];
    [self.gravityButton2 addTarget:self 
                   action:@selector(gravityButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    self.gravityButton2.translatesAutoresizingMaskIntoConstraints = NO;

    self.gravityButton3 = [[%c(AVButton) alloc] init]; // person.crop.rectangle lol   I ~~couldn't~~ didn't want to reuse the original image for various reasons, mainly because it wasn't a standard SFSymbol
    [self.gravityButton3 setImage:[UIImage systemImageNamed:@"person.crop.rectangle" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.gravityButton3.imageView setTintColor:UIColor.whiteColor];
    [self.gravityButton3 addTarget:self 
                   action:@selector(gravityButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    self.gravityButton3.translatesAutoresizingMaskIntoConstraints = NO;

    self.airplayButton = [[%c(AVButton) alloc] init];
    [self.airplayButton setImage:[UIImage systemImageNamed:@"airplayvideo" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.airplayButton.imageView setTintColor:UIColor.whiteColor];
    [self.airplayButton addTarget:self 
                   action:@selector(airplayButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    self.airplayButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.airplayButton2 = [[%c(AVButton) alloc] init];
    [self.airplayButton2 setImage:[UIImage systemImageNamed:@"airplayvideo" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.airplayButton2.imageView setTintColor:UIColor.whiteColor];
    [self.airplayButton2 addTarget:self 
                   action:@selector(airplayButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    self.airplayButton2.translatesAutoresizingMaskIntoConstraints = NO;

    self.airplayButton3 = [[%c(AVButton) alloc] init];
    [self.airplayButton3 setImage:[UIImage systemImageNamed:@"airplayvideo" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.airplayButton3.imageView setTintColor:UIColor.whiteColor];
    [self.airplayButton3 addTarget:self 
                   action:@selector(airplayButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
    self.airplayButton3.translatesAutoresizingMaskIntoConstraints = NO;

    self.orientationButton = [[%c(AVButton) alloc] init];
    [self.orientationButton setImage:[UIImage systemImageNamed:@"lock.rotation" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.orientationButton setImage:[UIImage systemImageNamed:@"lock.rotation.open" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateSelected];
    [self.orientationButton.imageView setTintColor:UIColor.whiteColor];
    [self.orientationButton addTarget:self 
                   action:@selector(orientationButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    self.orientationButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.orientationButton2 = [[%c(AVButton) alloc] init];
    [self.orientationButton2 setImage:[UIImage systemImageNamed:@"lock.rotation" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.orientationButton2 setImage:[UIImage systemImageNamed:@"lock.rotation.open" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateSelected];
    [self.orientationButton2.imageView setTintColor:UIColor.whiteColor];
    [self.orientationButton2 addTarget:self 
                   action:@selector(orientationButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    self.orientationButton2.translatesAutoresizingMaskIntoConstraints = NO;

    self.orientationButton3 = [[%c(AVButton) alloc] init];
    [self.orientationButton3 setImage:[UIImage systemImageNamed:@"lock.rotation" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.orientationButton3 setImage:[UIImage systemImageNamed:@"lock.rotation.open" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateSelected];
    [self.orientationButton3.imageView setTintColor:UIColor.whiteColor];
    [self.orientationButton3 addTarget:self 
                   action:@selector(orientationButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    self.orientationButton3.translatesAutoresizingMaskIntoConstraints = NO;

    self.closeButton = [[%c(AVButton) alloc] init];
    [self.closeButton setImage:[UIImage systemImageNamed:@"xmark" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular scale:UIImageSymbolScaleMedium]]forState:UIControlStateNormal];
    [self.closeButton.imageView setTintColor:UIColor.whiteColor];
    [self.closeButton addTarget:self 
                 action:@selector(closeButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;

    UIStackView *buttonsStack = [[UIStackView alloc] init];
    buttonsStack.axis = UILayoutConstraintAxisHorizontal;
    buttonsStack.distribution = UIStackViewDistributionFillEqually;
    buttonsStack.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:buttonsStack];
    [self addSubview:self.closeButton];

    switch (buttonOneStyle) {
      case 0:
        [buttonsStack addArrangedSubview:self.gravityButton];
        self.gravityButton.alpha = 0;
        break;
      case 1:
        [buttonsStack addArrangedSubview:self.gravityButton];
        break;
      case 2:
        [buttonsStack addArrangedSubview:self.airplayButton];
        break;
      case 3:
        [buttonsStack addArrangedSubview:self.pipButton];
        break;
      // case 4:
      //   [buttonsStack addArrangedSubview:self.orientationButton];
      //   break;
      default:
        break;
    }

    switch (buttonTwoStyle) {
      case 0:
        [buttonsStack addArrangedSubview:self.gravityButton2];
        self.gravityButton2.alpha = 0;
      case 1:
        [buttonsStack addArrangedSubview:self.gravityButton2];
        break;
      case 2:
        [buttonsStack addArrangedSubview:self.airplayButton2];
        break;
      case 3:
        [buttonsStack addArrangedSubview:self.pipButton2];
        break;
      // case 4:
      //   [buttonsStack addArrangedSubview:self.orientationButton2];
      //   break;
      default:
        break;
    }

    switch (buttonThreeStyle) {
      case 0:
        [buttonsStack addArrangedSubview:self.gravityButton3];
        self.gravityButton3.alpha = 0;
      case 1:
        [buttonsStack addArrangedSubview:self.gravityButton3];
        break;
      case 2:
        [buttonsStack addArrangedSubview:self.airplayButton3];
        break;
      case 3:
        [buttonsStack addArrangedSubview:self.pipButton3];
        break;
      // case 4:
      //   [buttonsStack addArrangedSubview:self.orientationButton3];
      //   break;
      default:
        break;
    }

    [buttonsStack atlas_anchorTop:self.superview.superview.topAnchor leading:nil bottom:nil trailing:self.superview.superview.superview.trailingAnchor padding:UIEdgeInsetsMake(0, 0, 15, 15) size:CGSizeMake(150, 40)];
    // [self.pipButton atlas_anchorTop:self.superview.superview.topAnchor leading:nil bottom:nil trailing:self.superview.superview.superview.trailingAnchor padding:UIEdgeInsetsMake(0, 0, 15, 15) size:CGSizeMake(40, 40)];
    // [self.gravityButton atlas_anchorTop:self.superview.superview.topAnchor leading:nil bottom:nil trailing:self.pipButton.leadingAnchor padding:UIEdgeInsetsMake(0, 0, 15, 15) size:CGSizeMake(40, 40)];
    // [self.airplayButton atlas_anchorTop:self.superview.superview.topAnchor leading:nil bottom:nil trailing:self.gravityButton.leadingAnchor padding:UIEdgeInsetsMake(0, 0, 15, 15) size:CGSizeMake(40, 40)];

    
    [self.closeButton atlas_anchorTop:self.superview.superview.topAnchor leading:self.superview.superview.superview.leadingAnchor bottom:nil trailing:nil padding:UIEdgeInsetsMake(0, 15, 15, 0) size:CGSizeMake(40, 40)];

    [self addSubview:self.scrubber];
    [self addSubview:self.elapsedTimeLabel];
    [self addSubview:self.timeRemainingLabel];
    [self addSubview:self.standardPlayPauseButton];
    [self addSubview:self.liveBroadcastLabel];
    self.standardPlayPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.standardPlayPauseButton atlas_centerInView:self.superview.superview.superview];
    [self.standardPlayPauseButton atlas_heightWidthAnchorsEqualToSize:CGSizeMake(30, 30)];
    [self.scrubber atlas_anchorTop:nil 
                   leading:self.leadingAnchor
                   bottom:self.bottomAnchor
                   trailing:self.trailingAnchor
                   padding:UIEdgeInsetsMake(0, 10, 0, 10)
                   size:CGSizeMake(0,40)];
    [self.elapsedTimeLabel atlas_anchorTop:nil 
                           leading:self.scrubber.leadingAnchor 
                           bottom:self.scrubber.topAnchor
                           trailing:nil
                           padding:UIEdgeInsetsMake(0, 0, 0, 0)
                           size:CGSizeMake(80,20)];
    [self.timeRemainingLabel atlas_anchorTop:nil 
                             leading:nil
                             bottom:self.scrubber.topAnchor
                             trailing:self.scrubber.trailingAnchor
          padding:UIEdgeInsetsMake(0, 0, 0, 0)
              size:CGSizeMake(80,20)];
    [self.liveBroadcastLabel atlas_anchorTop:nil 
                             leading:self.leadingAnchor
                             bottom:self.bottomAnchor
                             trailing:self.trailingAnchor
                             padding:UIEdgeInsetsMake(0, 10, 0, 10)
                             size:CGSizeMake(0,40)];
    [self.elapsedTimeLabel.label setTextAlignment:NSTextAlignmentLeft];
    [self.timeRemainingLabel.label setTextAlignment:NSTextAlignmentRight];

    self.numberView = [[UIView alloc] init];
    self.numberView.userInteractionEnabled = NO;
    self.numberView.backgroundColor = UIColor.clearColor;
    [self addSubview:self.numberView];
    [self.numberView atlas_anchorTop:self.superview.superview.superview.topAnchor leading:self.superview.superview.superview.leadingAnchor bottom:self.superview.superview.superview.bottomAnchor trailing:self.superview.superview.superview.trailingAnchor padding:UIEdgeInsetsZero size:CGSizeZero];

    self.leftNumber = [UILabel new];
    self.leftNumber.font = [UIFont boldSystemFontOfSize:20];
    self.leftNumber.userInteractionEnabled = NO;
    self.leftNumber.text = @"-15";
    self.leftNumber.textColor = UIColor.whiteColor;
    [self.leftNumber setTextAlignment:NSTextAlignmentLeft];
    [self.numberView addSubview:self.leftNumber];
    [self.leftNumber atlas_anchorTop:self.numberView.topAnchor leading:self.numberView.leadingAnchor bottom:self.numberView.bottomAnchor trailing:nil padding:UIEdgeInsetsMake(0,40,0,0) size:CGSizeMake(80, 0)];

    self.rightNumber = [UILabel new];
    self.rightNumber.font = [UIFont boldSystemFontOfSize:20];
    self.rightNumber.userInteractionEnabled = NO;
    self.rightNumber.text = @"+15";
    self.rightNumber.textColor = UIColor.whiteColor;
    [self.rightNumber setTextAlignment:NSTextAlignmentRight];
    [self.numberView addSubview:self.rightNumber];
    [self.rightNumber atlas_anchorTop:self.numberView.topAnchor leading:nil bottom:self.numberView.bottomAnchor trailing:self.numberView.trailingAnchor padding:UIEdgeInsetsMake(0,0,0,40) size:CGSizeMake(80, 0)];

    // If we're livestreaming, don't show the slider controls
    if (!self.showsLiveStreamingControls) {
      self.scrubber.alpha = 0;
      self.elapsedTimeLabel.alpha = 0;
      self.timeRemainingLabel.alpha = 0;
      self.liveBroadcastLabel.alpha = 1;
    }

    self.anchorCenterItem.alpha = 0;
    self.rewindButton.alpha = 1;
    self.fastforwardButton.alpha = 1;
    self.closeButton.alpha = 1;
    self.scrubber.alpha = 1;
    self.elapsedTimeLabel.alpha = 1;
    self.timeRemainingLabel.alpha = 1;
    self.darkOverlay.alpha = 0.4f;
    self.numberView.alpha = 1;
    self.liveBroadcastLabel.alpha = 0;

    self.leftNumber.alpha = 0;
    self.rightNumber.alpha = 0;

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
// %new
// -(void)orientationButtonPressed:(UIButton *)sender {
//   sender.selected = !sender.selected;
//   lockOrientation();
//   NSLog(@"hi");
// }
%new
-(void)leftGesture {
  if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
    self.leftNumber.font = [UIFont boldSystemFontOfSize:20];
  } else {
    self.leftNumber.font = [UIFont boldSystemFontOfSize:30];
  }
  CGRect frame = self.leftNumber.frame;
  [UIView animateWithDuration:0.3
          delay:0
          options:UIViewAnimationOptionCurveEaseOut
          animations:^{
            self.leftNumber.alpha = 1;
            if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
              self.leftNumber.frame = CGRectMake(frame.origin.x + 15, frame.origin.y, frame.size.width, frame.size.height);
            } else {
              self.leftNumber.frame = CGRectMake(frame.origin.x + 8, frame.origin.y, frame.size.width, frame.size.height);
            }
          }
          completion:^(BOOL finished){
            [UIView animateWithDuration:0.2
                    animations:^{
                      self.leftNumber.alpha = 0;
                    }
                    completion:^(BOOL finished){
                      self.leftNumber.frame = frame;
                    }];
          }];
}
%new
-(void)rightGesture {
  if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
    self.rightNumber.font = [UIFont boldSystemFontOfSize:20];
  } else {
    self.rightNumber.font = [UIFont boldSystemFontOfSize:30];
  }
  CGRect frame = self.rightNumber.frame;
  [UIView animateWithDuration:0.3
          delay:0
          options:UIViewAnimationOptionCurveEaseOut
          animations:^{
            self.rightNumber.alpha = 1;
            if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
              self.rightNumber.frame = CGRectMake(frame.origin.x - 15, frame.origin.y, frame.size.width, frame.size.height);
            } else {
              self.rightNumber.frame = CGRectMake(frame.origin.x - 8, frame.origin.y, frame.size.width, frame.size.height);
            }          }
          completion:^(BOOL finished){
            [UIView animateWithDuration:0.2
                    animations:^{
                      self.rightNumber.alpha = 0;
                    }
                    completion:^(BOOL finished){
                      self.rightNumber.frame = frame;
                    }];
          }];
}
-(void)dealloc {
	%orig;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
%end

%hook AVLabel
-(UILabel *)label {
  UILabel *whiteLabel = %orig;
  whiteLabel.textColor = [UIColor colorWithRed:1.00 green:1.00 blue:1.00 alpha:1.00];
  return whiteLabel;
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

  if (!gestureEnabled) return;
  // This handles the rewind/fastforward double tap gesture
  // It just checks which side of the screen the touch point came from

  if (arg1.state == UIGestureRecognizerStateEnded) {
    // CGPoint point = [arg1 locationInView:self.view.superview.superview.superview]; // This works
    // CGPoint point = [arg1 locationInView:self.view.superview]; // This works in the appleTV app
    CGPoint point = [arg1 locationInView:self.view]; // Ig this works everywhere
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    if (point.x < (screenWidth/2)) {
      // Left
      [self _handleSkipBack15SecondsKeyCommand:nil];
      // Show the -15
      if (animEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:@"leftGesture" object:self];
    } else {
      // Right
      [self _handleSkipAhead15SecondsKeyCommand:nil];
      // Show the +15
      if (animEnabled) [[NSNotificationCenter defaultCenter] postNotificationName:@"rightGesture" object:self];
    }
  }
}
-(void)dealloc {
	%orig;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
%end

%end

%ctor {
  preferences = [[HBPreferences alloc] initWithIdentifier:@"com.chr1s.atlasprefs"];
  [preferences registerBool:&enabled default:YES forKey:@"enabled"];
  [preferences registerBool:&gestureEnabled default:YES forKey:@"gestureEnabled"];
  [preferences registerBool:&animEnabled default:YES forKey:@"animEnabled"];
  [preferences registerInteger:&buttonOneStyle default:2 forKey:@"buttonOne"];
  [preferences registerInteger:&buttonTwoStyle default:1 forKey:@"buttonTwo"];
  [preferences registerInteger:&buttonThreeStyle default:3 forKey:@"buttonThree"];
  if (enabled) {
    %init(Atlas);
  }
}