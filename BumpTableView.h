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

@interface BumpTableView : UITableView <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>

/* Special additions */
@property (nonatomic) BOOL anchorsToBottom;
@property (nonatomic) BOOL showSectionIndexTitles;
@property (nonatomic) BOOL allowsSwipeConfirmation;
@property (nonatomic, strong) NSString *swipeConfirmationTitle;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) id <BumpTableViewDelegate>tableViewDelegate;

/* Model */
@property (nonatomic, strong) BumpTableModel *model;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
- (void)transitionToModel:(BumpTableModel *)newModel;

@end

@protocol BumpTableViewDelegate <NSObject>
@optional
- (void)searchBarWillDismiss;
- (void)searchBarDidDismiss;
@end
