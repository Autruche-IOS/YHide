#import <UIKit/UIKit.h>

// Sub list removal -- YTMySubsFilterHeaderViewController
@protocol YTVariableHeightHeaderViewControllerAttachedHeader <NSObject>
@end
@protocol YTFeedFilterChipBarNavigationDelegate <NSObject>
@end
@protocol YTResponder <NSObject>
@end
@protocol YTRendererController <YTResponder>
@end
@protocol YTScrollToModelProtocol <YTResponder>
@end
@protocol YTResponseViewController <YTRendererController, YTScrollToModelProtocol>
@end
@protocol YTUserPullToRefreshObserver <NSObject>
@end

@interface YTMySubsFilterHeaderViewController : UIViewController <YTVariableHeightHeaderViewControllerAttachedHeader, YTFeedFilterChipBarNavigationDelegate, YTResponseViewController, YTUserPullToRefreshObserver>
@end

// No home categories
@protocol YTPageStyling <NSObject>
@end

@interface YTSubheaderContainerView : UIView <YTPageStyling>
@end
