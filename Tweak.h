#import <UIKit/UIKit.h>

/*****************************************************
 * General
 */
@interface YTISectionListRenderer : NSObject
- (id)contentsArray;
@end

@interface YTISectionListSupportedRenderers : NSObject
@end

@interface YTChipCloudCell : UIView
@end

// Tabs
@interface YTPivotBarItemView : UIView
@property (nonatomic,readonly) BOOL selected;
- (void)didTapButton;
@end

@interface YTPivotBarView : UIView
@property (nonatomic,readonly) NSMutableArray<YTPivotBarItemView*> * itemViews;
@end


