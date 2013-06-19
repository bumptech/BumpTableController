//
//  BumpTableController.h
//  bump2
//
//  Created by Sahil Desai on 5/7/13.
//
//

#import "BumpTableModel.h"

@interface BumpTableController : NSObject <UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate>

- (id)initWithTableView:(UITableView *)tableView;

@property (nonatomic,unsafe_unretained) UITableView *tableView;                        // the tableView that this controller handles

@property (nonatomic,strong) BumpTableModel *model;                         // setting a model will automatically call reload the data using the new model (not animated)

- (void)transitionToModel:(BumpTableModel *)newModel;                       // animated version of setModel: using UITableViewRowAnimationTop for all row insertions/deletions

@property (nonatomic,assign) UITableViewRowAnimation transitionAnimation;    // animation transition to use for row insertions/deletions (does not affect move animations)
                                                                            // Default is UITableViewRowAnimationTop

@property (nonatomic) BOOL showSectionIndexTitles;                          // show scrubber. Default is NO
@property (nonatomic) BOOL allowsSwipeConfirmation;                         // show button over cell when user swipes. Default is NO
@property (nonatomic,copy) NSString *swipeConfirmationTitle;                // title of swipe button. Default is "Delete"

@property (nonatomic,strong) UISearchBar *searchBar;                        // upon first access, the search bar is added to the table header

@property (nonatomic,unsafe_unretained) id <UIScrollViewDelegate> scrollViewDelegate;  // passes through UIScrollViewDelegate callbacks

@end