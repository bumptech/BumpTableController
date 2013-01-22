//
//  BumpTableView.h
//
//  Created by Sahil Desai on 12/11/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BumpTableModel.h"
#import "BumpTableViewCell.h"

#define BumpTableViewDidBeginDraggingNotification @"BumpTableViewDidBeginDraggingNotification"

/*!
 @class BumpTableView

 @abstract

 */
@interface BumpTableView : UITableView <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>

@property (nonatomic) BOOL showSectionIndexTitles;                          // show scrubber. Default is NO
@property (nonatomic) BOOL allowsSwipeConfirmation;                         // show button over cell when user swipes. Default is NO 
@property (nonatomic, strong) NSString *swipeConfirmationTitle;             // title of swipe button. Default is "Delete"

@property (nonatomic, strong) UISearchBar *searchBar;                       // upon first access, the search bar is added to the table header

// Model changes
@property (nonatomic, strong) BumpTableModel *model;                        // setting a model will automatically call reload the data using the new model (not animated)
- (void)transitionToModel:(BumpTableModel *)newModel;                       // animated version of setModel: using UITableViewRowAnimationTop for all row insertions/deletions

@property (nonatomic) UITableViewRowAnimation transtionAnimation;           // animation transition to use for row insertions/deletions (does not affect move animations)
                                                                            // Default is UITableViewRowAnimationTop
@end