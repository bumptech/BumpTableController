//
//  BumpTableView.h
//
//  Created by Sahil Desai on 12/11/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BumpTableModel.h"
#import "BumpTableViewCell.h"

@protocol BumpTableViewDelegate;

@interface BumpTableView : UIView <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate> {
    UITableView *_tableView;
}

@property (nonatomic, assign) id <BumpTableViewDelegate>tableViewDelegate;

/* UITableView & UIScrollView passthroughs */
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIView *tableFooterView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) UIEdgeInsets scrollingIndicatorInsets;
@property (nonatomic) UITableViewCellSeparatorStyle separatorStyle;
@property (nonatomic) BOOL scrollsToTop;
@property (nonatomic) BOOL allowsMultipleSelection;

/* Special additions */
@property (nonatomic) BOOL anchorsToBottom;
@property (nonatomic) BOOL showSectionIndexTitles;
@property (nonatomic) BOOL allowsSwipeConfirmation;
@property (nonatomic, strong) NSString *swipeConfirmationTitle;
@property (nonatomic, strong) UISearchBar *searchBar;

/* Model */
@property (nonatomic, strong) BumpTableModel *model;
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
- (void)transitionToModel:(BumpTableModel *)newModel;
- (void)pauseUpdates;
- (void)resumeUpdates;

@end

@protocol BumpTableViewDelegate <NSObject>
@optional
- (void)searchBarWillDismiss;
- (void)searchBarDidDismiss;
@end
