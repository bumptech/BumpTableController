//
//  BumpTableView.h
//
//  Created by Sahil Desai on 12/11/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BumpTableModel.h"
#import "BumpTableViewCell.h"

/*!
 @class BumpTableView

 @abstract

 */

@protocol BumpTableViewScrollViewDelegate;

@interface BumpTableView : UITableView <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>

@property (nonatomic,assign) id <BumpTableViewScrollViewDelegate> scrollViewDelegate;  // passes through UIScrollViewDelegate callbacks

@property (nonatomic,assign) BOOL showSectionIndexTitles;                           // show scrubber. Default is NO
@property (nonatomic,assign) BOOL allowsSwipeConfirmation;                          // show button over cell when user swipes. Default is NO
@property (nonatomic,strong) NSString *swipeConfirmationTitle;                      // title of swipe button. Default is "Delete"

@property (nonatomic,strong) UISearchBar *searchBar;                                // upon first access, the search bar is added to the table header

// Model changes
@property (nonatomic,strong) BumpTableModel *model;                                 // setting a model will automatically call reload the data using the new model (not animated)
- (void)transitionToModel:(BumpTableModel *)newModel;                               // animated version of setModel: using UITableViewRowAnimationTop for all row insertions/deletions

@property (nonatomic,assign) UITableViewRowAnimation transtionAnimation;            // animation transition to use for row insertions/deletions (does not affect move animations)
                                                                                    // Default is UITableViewRowAnimationTop
@end

@protocol BumpTableViewScrollViewDelegate <NSObject, UIScrollViewDelegate>
// Passthroughs for UIScrollViewDelegate
@optional

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;                     // any offset changes
- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2); // any zoom scale changes

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