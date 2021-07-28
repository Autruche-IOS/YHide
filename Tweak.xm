#import "Tweak.h"

#ifdef DEBUG
# define DEBUG_PRINT(x, ...) NSLog(x, ##__VA_ARGS__)
#else
# define DEBUG_PRINT(x, ...) // Nothing
#endif


// Sub list removal
%hook YTMySubsFilterHeaderViewController
- (void)loadView {
    DEBUG_PRINT(@"<YTHide> Not rendering the Sub list");
}
- (_Bool)isAttachedToPage{
    return false;
}
%end

// No home categories
%hook YTSubheaderContainerView
- (void)setFrame:(struct CGRect)arg1 {
    // If the size in 0, we just don't see it :)
    DEBUG_PRINT(@"<YTHide> Hiding home categories");
}
%end

// Remove a lot of cards
%hook YTInnerTubeCollectionViewController
- (void)addSectionsFromArray:(id)arg1 {
    NSMutableArray *array = (NSMutableArray*) arg1;
    int count = [array count];

    /*
    video_with_context
        -> Related videos

    YTISlimVideoMetadataSectionRendererRoot_slimVideoDescriptionRenderer
    YTISlimVideoMetadataSectionRendererRoot_slimVideoInformationRenderer
        -> Video description

    comments_composite_entry_point.eml|
    _COMMENT_
        -> Comment section

    style_type: STYLE_HOME_FILTER
        -> Home

    compact_video.eml|
    compact_playlist.eml|
    post_base_wrapper.eml|
    channel_renderer
    channel_about_metadata_renderer
    playlist_video_list_renderer
        -> Channel's stuff
    */
    NSString * allowedItems = @".*(video_with_context|YTISlimVideoMetadataSectionRendererRoot_slimVideoInformationRenderer|comments_composite_entry_point\\.eml\\||_COMMENT_|\
style_type: STYLE_HOME_FILTER|compact_video.eml\\||compact_playlist.eml\\||post_base_wrapper.eml\\||channel_renderer|channel_about_metadata_renderer|playlist_video_list_renderer).*";

    NSString *itemString = nil;
    for (int i = count; i--;)
    {
        itemString = [NSString stringWithFormat:@"%@", [array objectAtIndex:i]];

        // Not an allowed element
        if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", allowedItems] evaluateWithObject:itemString])
        {
            DEBUG_PRINT(@"<YTHide> Found an unwanted element, removing it: %@", itemString);
            [array removeObjectAtIndex:i];
        }
    }

    // Nothing to see here, let youube add the remaining
    %orig;
}
%end


// No landscpae overlay
%hook YTMainAppVideoPlayerOverlayViewController
- (_Bool)shouldShowAutonavEndscreen {
    return false;
}
%end


