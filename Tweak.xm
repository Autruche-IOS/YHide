#import "Tweak.h"

%hook YTMySubsFilterHeaderViewController
- (void)loadView {
    // Nope
}

- (_Bool)isAttachedToPage{
    return false;
}
%end
