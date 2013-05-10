//
//  ViewController.m
//  BumpTableViewExample
//
//  Created by Jason Ting on 12/12/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import "ViewController.h"
#import "BumpTableController.h"


#define ROW_HEIGHT 44.0f

@interface ViewController ()

@property (nonatomic) BumpTableController *tableController;

@property (nonatomic) BumpTableSection *chosenSection;
@property (nonatomic) BumpTableSection *allSection;
@property (nonatomic) NSMutableArray *fontRows;
@property (nonatomic) NSMutableArray *chosenFontRows;

@end

@implementation ViewController {
    UITableView *_tableView;
    UISearchDisplayController *_search;
    BOOL _sorted;
}

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Font Browser";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // set up data sources
    _fontRows = [NSMutableArray array];
    _chosenFontRows = [NSMutableArray array];

    for (NSString *item in [UIFont familyNames]) {
        [_fontRows addObject:[self tableRowForItem:item]];
    }

    _fontRows = [[_fontRows sortedArrayUsingComparator:^NSComparisonResult(BumpTableRow *row1, BumpTableRow *row2) {
        return [row1.searchString compare:row2.searchString];
    }] mutableCopy];

    // set up table view
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];

    // initialize table controller with tableview
    _tableController = [[BumpTableController alloc] initWithTableView:_tableView];
    _tableController.allowsSwipeConfirmation = YES;
    _tableController.transtionAnimation = UITableViewRowAnimationTop;

    [self updateView];
    [self enableSearching];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow]
                              animated:YES];
}

- (BumpTableRow *)tableRowForItem:(NSString *)item {
    static NSString *reuseId = @"CellIdentifier";
    __weak BumpTableRow *newRow = [BumpTableRow rowWithKey:@{ @"name": item }
                                                    height:ROW_HEIGHT
                                           reuseIdentifier:reuseId];
    newRow.searchString = item;
    newRow.customizer = ^(UITableViewCell *cell) {
        cell.textLabel.text = item;
        cell.textLabel.font = [UIFont fontWithName:item size:18.0f];
        cell.textLabel.textColor = [UIColor darkGrayColor];
    };

    __weak ViewController *weakSelf = self;
    newRow.onTap = ^(UITableViewCell *cell) {
        ViewController *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSMutableArray *newChosenRows = [NSMutableArray arrayWithArray:strongSelf.chosenSection.rows];
        NSMutableArray *newAllRows = [NSMutableArray arrayWithArray:strongSelf.allSection.rows];

        if ([strongSelf.allSection.rows containsObject:newRow]) {
            [newChosenRows addObject:newRow];
            [newAllRows removeObject:newRow];
        } else {
            [newChosenRows removeObject:newRow];
            [newAllRows addObject:newRow];
        }

        strongSelf.chosenFontRows = [[newChosenRows sortedArrayUsingComparator:^NSComparisonResult(BumpTableRow *row1, BumpTableRow *row2) {
            return [row1.searchString compare:row2.searchString];
        }] mutableCopy];

        strongSelf.fontRows = [[newAllRows sortedArrayUsingComparator:^NSComparisonResult(BumpTableRow *row1, BumpTableRow *row2) {
            return [row1.searchString compare:row2.searchString];
        }] mutableCopy];

        [strongSelf updateView];
        [strongSelf.searchDisplayController setActive:NO];
    };

    newRow.onSwipeConfirmation = ^(UITableViewCell *cell) {
        ViewController *strongSelf = weakSelf;
        if (!strongSelf) return;

        NSMutableArray *newChosenRows = [NSMutableArray arrayWithArray:strongSelf.chosenSection.rows];
        NSMutableArray *newAllRows = [NSMutableArray arrayWithArray:strongSelf.allSection.rows];

        if ([strongSelf.allSection.rows containsObject:newRow]) {
            [newAllRows removeObject:newRow];
            strongSelf.fontRows = newAllRows;
        } else {
            [newChosenRows removeObject:newRow];
            strongSelf.chosenFontRows = newChosenRows;
        }
        [strongSelf updateView];
    };

    return newRow;
}

- (void)updateView {
    NSMutableArray *sections = [NSMutableArray array];

    // chosen fonts
    _chosenSection = [BumpTableSection sectionWithKey:@"chosenSection" rows:_chosenFontRows];
    _chosenSection.header = [BumpTableHeaderFooter headerFooterForHeight:27.0 generator:^UIView *{
        UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
        view.textLabel.text = @"Chosen";
        view.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        view.textLabel.textColor = [UIColor whiteColor];
        view.textLabel.shadowColor = [UIColor darkGrayColor];
        view.textLabel.shadowOffset = CGSizeMake(0,1);
        return view;
    }];

    if ([_chosenFontRows count]) {
        [sections addObject:_chosenSection];
    }

    // all fonts
    _allSection = [BumpTableSection sectionWithKey:@"allSection" rows:_fontRows];
    _allSection.header = [BumpTableHeaderFooter headerFooterForHeight:27.0 generator:^UIView *{
        UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
        view.textLabel.text = @"All";
        view.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
        view.textLabel.textColor = [UIColor whiteColor];
        view.textLabel.shadowColor = [UIColor darkGrayColor];
        view.textLabel.shadowOffset = CGSizeMake(0,1);
        return view;
    }];

    if ([_fontRows count]) {
        [sections addObject:_allSection];
    }

    [_tableController transitionToModel:[BumpTableModel modelWithSections:sections]];
}

- (void)enableSearching {
    if (!_search) {
        _search = [[UISearchDisplayController alloc] initWithSearchBar:_tableController.searchBar
                                                    contentsController:self];
        _search.searchResultsDataSource  = _tableController;
        _search.searchResultsDelegate = _tableController;
        _search.delegate = _tableController;
    }
}

@end
