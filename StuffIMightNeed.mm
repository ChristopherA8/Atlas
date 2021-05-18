// The wildcard in my makefile is not building .mm files so I don't need to
// worry about this trying to compile

// clang-format kinda killed any logos formatting,
// ... I should have thought of that.. and changed the file extension to .x or
//    something
/////////////////////////////////
% hook AVPlaybackControlsView

    - (void)playbackControlsView
    : (id)arg1 animateAlongsideVisibilityAnimationsWithAnimationCoordinator
    : (id)arg2 appearingViews : (id)arg3 disappearingViews : (id)arg4 {
  // %orig;
  if (showing) {
    // blurEffectView.alpha = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideScrubber"
                                                        object:self];
  } else {
    // blurEffectView.alpha = 0.4f;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showScrubber"
                                                        object:self];
  }
}
% end
    ///////////////////////////////////