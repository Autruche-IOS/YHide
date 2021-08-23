#import "Tweak.h"

#ifdef DEBUG
# define DEBUG_PRINT(x, ...) NSLog(x, ##__VA_ARGS__)
#else
# define DEBUG_PRINT(x, ...) // Nothing
#endif

// Create the compiled regex, for performance purposes
NSPredicate *compiledRegex = nil;
%ctor {
    /*
    video_with_context
        -> Related videos

    watch_card_rich_header_renderer
    YTIHorizontalCardListRenderer
        -> Search

    share_targets
        -> Share button

    YTIFullscreenEngagementOverlayRendererRoot_fullscreenEngagementChannelRenderer
    related_watch_next_end_screen
    LiveChat
        -> Videos cards in landscape, if this is removed, the app crashes on full rotation

    YTIInfoCardCollectionRenderer
        -> Elements that if removed can cause crash / layout error after a full rotate from landscape

    YTISlimVideoMetadataSectionRendererRoot_slimVideoDescriptionRenderer
    YTISlimVideoMetadataSectionRendererRoot_slimVideoInformationRenderer
        -> Video description

    YTIPlaylistPanelRenderer
    playlist_video_list_renderer
        -> Playlists

    comments_composite_entry_point.eml|
    _COMMENT_
        -> Comment section

    style_type: STYLE_HOME_FILTER
        -> Home

    YTIShelfRenderer
    compact_video.eml|
    compact_playlist.eml|
    post_base_wrapper.eml|
    channel_renderer
    channel_about_metadata_renderer
        -> Channel's stuff
    */
    NSString * allowedItems = @".*(video_with_context|\
watch_card_rich_header_renderer|YTIHorizontalCardListRenderer|\
share_targets|\
YTIFullscreenEngagementOverlayRendererRoot_fullscreenEngagementChannelRenderer|related_watch_next_end_screen|LiveChat|\
YTIInfoCardCollectionRenderer|\
YTISlimVideoMetadataSectionRendererRoot_slimVideoDescriptionRenderer|YTISlimVideoMetadataSectionRendererRoot_slimVideoInformationRenderer|\
YTIPlaylistPanelRenderer|playlist_video_list_renderer|\
comments_composite_entry_point\\.eml\\||_COMMENT_|\
style_type: STYLE_HOME_FILTER|\
YTIShelfRenderer|compact_video.eml\\||compact_playlist.eml\\||post_base_wrapper.eml\\||channel_renderer|channel_about_metadata_renderer).*";

    compiledRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", allowedItems];
}

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
    if (compiledRegex != nil)
    {
        NSMutableArray *array = (NSMutableArray*) arg1;
        int count = [array count];

        NSString *itemString = nil;
        for (int i = count; i--;)
        {
            itemString = [NSString stringWithFormat:@"%@", [array objectAtIndex:i]];

            // Not an allowed element
            if (![compiledRegex evaluateWithObject:itemString])
            {
                DEBUG_PRINT(@"<YTHide> Found an unwanted element, removing it: %@", itemString);
                [array removeObjectAtIndex:i];
            }
        }
    }

    // Nothing to see here, let youube add the remaining
    %orig;
}
%end


// No landscpae overlay
%hook YTMainAppVideoPlayerOverlayViewController
- (_Bool)shouldEnableRelatedVideos {
    return false;
}
- (_Bool)shouldShowAutonavEndscreen {
    return false;
}
%end
