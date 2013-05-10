//
//  BumpTableController.h
//  bump2
//
//  Created by Sahil Desai on 5/7/13.
//
//

#import "BumpTableModel.h"
#import "BumpTableViewCell.h"

@protocol BumpTableScrollViewDelegate;

@interface BumpTableController : NSObject <UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate>

- (id)initWithTableView:(UITableView *)tableView;

@property (nonatomic,weak) UITableView *tableView;                          // the tableView that this controller handles

@property (nonatomic,strong) BumpTableModel *model;                         // setting a model will automatically call reload the data using the new model (not animated)

- (void)transitionToModel:(BumpTableModel *)newModel;                       // animated version of setModel: using UITableViewRowAnimationTop for all row insertions/deletions

@property (nonatomic,assign) UITableViewRowAnimation transtionAnimation;    // animation transition to use for row insertions/deletions (does not affect move animations)
                                                                            // Default is UITableViewRowAnimationTop

@property (nonatomic) BOOL showSectionIndexTitles;                          // show scrubber. Default is NO
@property (nonatomic) BOOL allowsSwipeConfirmation;                         // show button over cell when user swipes. Default is NO
@property (nonatomic,copy) NSString *swipeConfirmationTitle;                // title of swipe button. Default is "Delete"

@property (nonatomic,strong) UISearchBar *searchBar;                        // upon first access, the search bar is added to the table header

@property (nonatomic,weak) id <BumpTableScrollViewDelegate> scrollViewDelegate;  // passes through UIScrollViewDelegate callbacks

@end


// Passthroughs for UIScrollViewDelegate (since the BumpTableController is the UITableView delegate and as a result also the UIScrollViewDelegate
@protocol BumpTableScrollViewDelegate <NSObject, UIScrollViewDelegate>
@optional

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;                     // any offset changes
- (void)scrollViewDidZoom:(UIScrollView *)scrollView;                       // any zoom scale changes

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
// called on finger up if the user dragged. velocity is in points/second.
// targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0);
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;   // called on finger up as we are moving
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;      // called when scroll view grinds to a halt

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView; // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;     // return a view that will be scaled. if delegate returns nil, nothing happens
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view NS_AVAILABLE_IOS(3_2); // called before the scroll view begins zooming its content
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale; // scale between minimum and maximum. called after any 'bounce' animations

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView;   // return a yes if you want to scroll to the top. if not defined, assumes YES
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;      // called when scrolling animation finished. may be called immediately if already at top

@end