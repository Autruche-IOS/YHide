#import "Tweak.h"

#ifdef DEBUG
# define DEBUG_PRINT(x, ...) NSLog(x, ##__VA_ARGS__)
#else
# define DEBUG_PRINT(x, ...) // Nothing
#endif

/*****************************************************
 * General filter
 */
// Remove useless header buttons
%hook YTRightNavigationButtons
- (void)setButton:(id)arg1 forType:(NSUInteger)forType {
    /*
        1 -> Search text field
        8 -> Search icon
    */
    if (forType == 8 || forType == 1)
    {
        DEBUG_PRINT(@"<YTHide> Letting through header button (%lu)", (unsigned long) forType);
        %orig;
    }
    else
    {
        DEBUG_PRINT(@"<YTHide> Not rendering unwanted header button (%lu)", (unsigned long) forType);
    }
}
%end

// No vocal search
%hook YTSearchTextField
- (void)setVoiceSearchEnabled:(BOOL)arg1 {
    DEBUG_PRINT(@"<YTHide> Not rendering the voice search button");
}
%end

// Create the compiled regex, for performance purposes
NSPredicate *compiledRegex = nil;
%ctor {
    /*
    video_with_context_wrapper.eml
    home_video_with_context.eml
        -> Subscripted, home and related videos videos

    search_video_with_context.eml
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
    video_description_header.eml
        -> Video description

    YTIPlaylistPanelRenderer
    playlist_video_list_renderer
        -> Playlists

    comments_composite_entry_point.eml|
    _COMMENT_
        -> Comment section

    style_type: STYLE_HOME_FILTER
        -> Home

    channel_bar.eml
    YTIShelfRenderer
    compact_video.eml|
    compact_playlist.eml|
    channel_renderer
    channel_about_metadata_renderer
    about_channel_view.eml
        -> Channel's stuff
    */
    NSString * allowedItems = @".*(video_with_context_wrapper.eml|home_video_with_context.eml|related_video_with_context.eml|\
search_video_with_context.eml|watch_card_rich_header_renderer|YTIHorizontalCardListRenderer|\
share_targets|\
YTIFullscreenEngagementOverlayRendererRoot_fullscreenEngagementChannelRenderer|related_watch_next_end_screen|LiveChat|\
YTIInfoCardCollectionRenderer|\
YTISlimVideoMetadataSectionRendererRoot_slimVideoDescriptionRenderer|YTISlimVideoMetadataSectionRendererRoot_slimVideoInformationRenderer|video_description_header.eml|\
YTIPlaylistPanelRenderer|playlist_video_list_renderer|\
comments_composite_entry_point\\.eml\\||_COMMENT_|\
style_type: STYLE_HOME_FILTER|\
channel_bar.eml|YTIShelfRenderer|compact_video.eml\\||compact_playlist.eml\\||channel_renderer|channel_about_metadata_renderer|about_channel_view.eml).*";

    compiledRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", allowedItems];
}

// Tells if the object has to be removed
BOOL isWhiteListed(id randomReceivedObject) {
    BOOL whiteListed = false;

    NSString *itemString = [NSString stringWithFormat:@"%@", randomReceivedObject];

    // Not an allowed element
    if ([compiledRegex evaluateWithObject:itemString])
    {
        DEBUG_PRINT(@"<YTHide> Allowing: %@", itemString);
        whiteListed = true;
    }
    else
    {
        DEBUG_PRINT(@"<YTHide> Found an unwanted element, removing it: %@", itemString);
    }

    return whiteListed;
}

// Remove all not whitelisted cards
%hook YTInnerTubeCollectionViewController
- (void)addSectionsFromArray:(id)arg1 {
    if (compiledRegex != nil && arg1 != nil)
    {
        // Cast for the loop
        NSMutableArray *globalRendererList = (NSMutableArray*) arg1;
        int globalCount = [globalRendererList count];

        // Loops over the renderers
        for (int i = globalCount; i--;)
        {
            // Bad cas, bu it should be harmless, as we check for the method
            id innerObject = [globalRendererList objectAtIndex:i];

            // Seek for the content (inner arrays, for more precise filtering)
            while (![[innerObject class] instancesRespondToSelector:@selector(count)] && [[innerObject class] instancesRespondToSelector:@selector(contentsArray)]) // Not an array but has content
            {
                innerObject = [innerObject contentsArray];
            }

            // No inner list was found
            if (![[innerObject class] instancesRespondToSelector:@selector(count)])
            {
                // Single element
                if (!isWhiteListed([globalRendererList objectAtIndex:i]))
                {
                    [globalRendererList removeObjectAtIndex:i];
                }
            }
            else
            {
                // Lists
                DEBUG_PRINT(@"<YTHide> Processing the inner Renderer");
                NSMutableArray<YTISectionListSupportedRenderers*> *innerRendererList = (NSMutableArray*) innerObject;
                int innerCount = [innerRendererList count], innerRemovedCount = 0;

                // Loops over the contents of the renderers
                for (int j = innerCount; j--;)
                {
                    if (!isWhiteListed([innerRendererList objectAtIndex:j]))
                    {
                        [innerRendererList removeObjectAtIndex:j];
                        innerRemovedCount++;
                    }
                }

                // If it is empty, just remove it (prevent unexpected behaviour)
                if (innerRemovedCount == innerCount)
                {
                    [globalRendererList removeObjectAtIndex:i];
                }
            }
        }
    }
    else
    {
        DEBUG_PRINT(@"<YTHide> Incompatible YT version (no array provided)");
    }

    // Nothing to see here, let youtube add the remaining
    %orig;
}
%end

// Remove the recommendation scroller
%hook YTChipCloudCell
- (void)setEntry:(id)arg1 {
    DEBUG_PRINT(@"<YTHide> Not rendering the recommendation scroller");
}
- (void)layoutSubviews {
    DEBUG_PRINT(@"<YTHide> Not rendering the recommendation scroller");
    [self removeFromSuperview];
}
%end

// Remove bottom tabs
BOOL alreadyWentToSebsTab = false;
%hook YTPivotBarView
- (void)layoutSubviews {
    for (int i = [self.itemViews count]; i--;)
    {
        // Don't hide if already
        if (![self.itemViews[i] isHidden])
        {
            /*
                0 => Home
                3 => Subs
            */
            if (i != 0 && i != 3)
            {
                DEBUG_PRINT(@"<YTHide> Hiding unwated tab (position: %d)", i);
                [self.itemViews[i] setHidden:true];
            }
        }
    }

    // Do the line, Bart
    %orig;

    // Let's focus on the subs ;)
    if (!alreadyWentToSebsTab)
    {
        DEBUG_PRINT(@"<YTHide> Going to the Subs tab");
        alreadyWentToSebsTab = true;
        [self.itemViews[3] didTapButton];
    }
}
%end

/*****************************************************
 * Sub tab
 */
// Sub list removal
%hook YTMySubsFilterHeaderViewController
- (void)loadView {
    DEBUG_PRINT(@"<YTHide> Not rendering the Sub list");
}
- (_Bool)isAttachedToPage{
    return false;
}
%end

/*****************************************************
 * Home tab
 */
// No home categories
%hook YTSubheaderContainerView
- (void)setFrame:(struct CGRect)arg1 {
    // If the size is 0, we just don't see it :)
    DEBUG_PRINT(@"<YTHide> Hiding home categories");
}
%end

/*****************************************************
 * Videos player and co
 */
// No landscpae overlay
%hook YTMainAppVideoPlayerOverlayViewController
- (_Bool)shouldEnableRelatedVideos {
    return false;
}
- (_Bool)shouldShowAutonavEndscreen {
    return false;
}
%end

// No toast
%hook YTMainAppControlsOverlayView
- (void)setPlayerToastText:(id)arg1 {
    DEBUG_PRINT(@"<YTHide> Not rendering the toast");
}
- (void)layoutSubviews {
    DEBUG_PRINT(@"<YTHide> Not rendering the useless player buttons");
    // Get the top buttons
    NSArray *topSubViews = [[self topControlsAccessibilityContainerView] subviews];
    int arrayCount = [topSubViews count];

    // Hide them
    for (int i = arrayCount; i--;)
    {
        // Options button is the exception
        if (i != 4)
        {
            [[topSubViews objectAtIndex:i] setHidden:true];
        }
    }

    %orig;
}
%end

// No paid toast
%hook YTPaidContentViewController
- (void)loadView {
    DEBUG_PRINT(@"<YTHide> Not rendering the AD warning");
}
%end
