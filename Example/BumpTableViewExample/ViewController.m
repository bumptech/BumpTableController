//
//  ViewController.m
//  BumpTableViewExample
//
//  Created by Jason Ting on 12/12/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import "ViewController.h"
#import "BumpTableView.h"

#define ROW_HEIGHT 44.0f

@interface ViewController ()
@end

@implementation ViewController {
    BumpTableView *_tableView;
    UISearchDisplayController *_search;
    NSMutableArray *_sections;
    BumpTableSection *_chosenSection;
    BumpTableSection *_allSection;
    NSMutableArray *_fontRows;
    NSMutableArray *_chosenFontRows;
    BOOL _sorted;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Font Browser";
    }
    return self;
}

- (void)viewDidLoad
{
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
    _tableView = [[BumpTableView alloc] initWithFrame:self.view.bounds];
    _tableView.allowsSwipeConfirmation = YES;

    [self updateView];
    [self enableSearching];
    [self.view addSubview:_tableView];
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
                                    reuseIdentifier:reuseId
                                          generator:^UITableViewCell *(NSString *reuseIdentifier) {
                                              return [[BumpTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
                                          }];

    newRow.searchString = item;
    newRow.customizer = ^(BumpTableViewCell *cell) {
        cell.textLabel.text = item;
        cell.textLabel.font = [UIFont fontWithName:item size:18.0f];
        cell.textLabel.textColor = [UIColor darkGrayColor];
    };

    newRow.onTap = ^(BumpTableViewCell *cell) {
        NSMutableArray *newChosenRows = [NSMutableArray arrayWithArray:_chosenSection.rows];
        NSMutableArray *newAllRows = [NSMutableArray arrayWithArray:_allSection.rows];

        if ([_allSection.rows containsObject:newRow]) {
            [newChosenRows addObject:newRow];
            [newAllRows removeObject:newRow];
        } else {
            [newChosenRows removeObject:newRow];
            [newAllRows addObject:newRow];
        }

        _chosenFontRows = [[newChosenRows sortedArrayUsingComparator:^NSComparisonResult(BumpTableRow *row1, BumpTableRow *row2) {
            return [row1.searchString compare:row2.searchString];
        }] mutableCopy];

        _fontRows = [[newAllRows sortedArrayUsingComparator:^NSComparisonResult(BumpTableRow *row1, BumpTableRow *row2) {
            return [row1.searchString compare:row2.searchString];
        }] mutableCopy];

        [self updateView];
        [self.searchDisplayController setActive:NO];
    };

    newRow.onSwipeConfirmation = ^(BumpTableViewCell *cell) {
        NSMutableArray *newChosenRows = [NSMutableArray arrayWithArray:_chosenSection.rows];
        NSMutableArray *newAllRows = [NSMutableArray arrayWithArray:_allSection.rows];

        if ([_allSection.rows containsObject:newRow]) {
            [newAllRows removeObject:newRow];
            _fontRows = newAllRows;
        } else {
            [newChosenRows removeObject:newRow];
            _chosenFontRows = newChosenRows;
        }

        [self updateView];
    };

    return newRow;
}

- (void)updateView {
    _sections = [NSMutableArray array];

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
        [_sections addObject:_chosenSection];
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
        [_sections addObject:_allSection];
    }

    [_tableView transitionToModel:[BumpTableModel modelWithSections:_sections]];
}

- (void)enableSearching {
    if (!_search) {
        _search = [[UISearchDisplayController alloc] initWithSearchBar:_tableView.searchBar
                                                   contentsController:self];
        _search.searchResultsDataSource  = _tableView;
        _search.searchResultsDelegate = _tableView;
        _search.delegate = _tableView;
    }
}

@end
