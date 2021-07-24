#import "Tweak.h"

// Sub list removal
%hook YTMySubsFilterHeaderViewController
- (void)loadView {
    // Nope
}

- (_Bool)isAttachedToPage{
    return false;
}
%end

// No home categories
%hook YTSubheaderContainerView
- (void)setFrame:(struct CGRect)arg1 {
    // If the size in 0, we just don't see it :)
}
%end
