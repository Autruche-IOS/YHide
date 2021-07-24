#import "Tweak.h"

// Sub list removal
%hook YTMySubsFilterHeaderViewController
- (void)loadView {
#if DEBUG
    NSLog(@"<YTHide> Not rendering the Sub list");
#endif
}
- (_Bool)isAttachedToPage{
    return false;
}
%end

// No home categories
%hook YTSubheaderContainerView
- (void)setFrame:(struct CGRect)arg1 {
    // If the size in 0, we just don't see it :)
#if DEBUG
    NSLog(@"<YTHide> Hiding home categories");
#endif
}
%end

// No tshirsts ad
%hook YTWatchNextResultsViewController
- (void)addSectionsFromArray:(id)arg1 {

    NSMutableArray *array = (NSMutableArray*) arg1;
    NSString *itemClass;

    // Loop over all the received elements
    for (int i = [array count]; i--;)
    {
        itemClass = NSStringFromClass([[array objectAtIndex:i] class]);

        // If the object is of an ad class - we can't link the class', so we only compare the names
        if ([itemClass isEqualToString:@"YTICompanionAdRenderer"] || [itemClass isEqualToString:@"YTIItemSectionRenderer"])
        {
#if DEBUG
            NSLog(@"<YTHide> Found a merch ad, getting rid of it");
#endif
            [array removeObjectAtIndex:i];
        }
    }

    // Do the redering
    %orig;
}


//MSHookIvar<YTISectionListRenderer *>(self, "_watchNextResults")
%end
