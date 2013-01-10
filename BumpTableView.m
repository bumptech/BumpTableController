//
//  BumpTableView.m
//
//  Created by Sahil Desai on 12/11/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import "BumpTableView.h"
#import "NSArray+Bump.h"
#import "NSObject+Bump.h"

#define SEARCH_BAR_HEIGHT 44.0f


/* Class for managing transitions between BumpTableView updates */
@interface BumpTransition : NSObject
@property (nonatomic) NSSet *inserted;
@property (nonatomic) NSSet *deleted;
@property (nonatomic) NSSet *mutual;
@property (nonatomic) NSSet *moved;
@end

@implementation BumpTransition
- (NSString *)description {
    return [NSString stringWithFormat:@"<Transition inserted:%@\ndeleted:%@\nmutual:%@\nmoved:%@\n>",
            [[_inserted allObjects] indentedDescription],
            [[_deleted allObjects] indentedDescription],
            [[_mutual allObjects] indentedDescription],
            [[_moved allObjects] indentedDescription]];
}
@end


/* Main BumpTableView Class */
@interface BumpTableView ()
// Search
@property (nonatomic) UITableView *searchResultsTableView;
@property (nonatomic) NSString *searchString;
@property (nonatomic) NSArray *searchResultsRows;
@end

@implementation BumpTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if ((self = [super initWithFrame:frame style:style])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.delegate = self;
    self.dataSource = self;
    self.transtionAnimation = UITableViewRowAnimationTop;
}

#pragma mark - Helpers

+ (BumpTableSection *)sectionForIndex:(NSInteger)sectionIndex model:(BumpTableModel *)model {
    return [[model sections] objectAtIndex:sectionIndex];
}

- (BumpTableSection *)sectionForIndex:(NSInteger)sectionIndex {
    return [[self class] sectionForIndex:sectionIndex model:_model];
}

+ (BumpTableRow *)rowForIndexPath:(NSIndexPath *)indexPath model:(BumpTableModel *)model {
    return [[[self sectionForIndex:indexPath.section model:model] rows] objectAtIndex:indexPath.row];
}

- (BumpTableRow *)rowForIndexPath:(NSIndexPath *)indexPath {
    return [[self class] rowForIndexPath:indexPath model:_model];
}

- (BumpTableRow *)rowForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    if (tableView == self) return [self rowForIndexPath:indexPath];
    if (tableView == _searchResultsTableView) return [_searchResultsRows objectAtIndex:indexPath.row];
    NSAssert(false, @"Unknown tableview");
    return nil;
}

- (NSArray *)selectedRows {
    NSArray *selectedRows = [[self indexPathsForSelectedRows] mapWithBlock:^id(NSIndexPath *indexPath) {
        return [self rowForIndexPath:indexPath];
    }];
    return selectedRows;
}

#pragma mark - Model changing

- (void)setModel:(BumpTableModel *)model {
    _model = model;
    [self reloadData];
}

- (void)transitionToModel:(BumpTableModel *)newModel {
    UITableViewRowAnimation insertAnimation = _transtionAnimation;
    UITableViewRowAnimation deleteAnimation = _transtionAnimation;
    BumpTableModel *oldModel = _model;
    _model = newModel;
    if (!oldModel) {
        [self reloadData];
        return;
    }
    if (!newModel) {
        [self deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, oldModel.sections.count)]
            withRowAnimation:deleteAnimation];
        return;
    }

    BumpTransition *sectionInfo = [[self class] sectionTransitionFrom:oldModel.sections
                                                                   to:newModel.sections];

    NSDictionary *oldS = [oldModel sectionIndexes];//key->indexSet
    NSAssert(oldS.count == oldModel.sections.count, @"the old table model has non-unique section keys");
    NSDictionary *newS = [newModel sectionIndexes];
    NSAssert(newS.count == newModel.sections.count, @"the new table model has non-unique section keys");
    NSDictionary *oldIps = [oldModel rowIndexPaths];//key->indexPath if its a row
    NSAssert(oldIps.count == oldS.count + [oldModel.sections sumWithBlock:^int(BumpTableSection *s) { return s.rows.count; }], @"the old table model has non-unique row keys");
    NSDictionary *newIps = [newModel rowIndexPaths];//key->dict of k->ip if it's a section
    NSAssert(newIps.count == newS.count + [newModel.sections sumWithBlock:^int(BumpTableSection *s) { return s.rows.count; }], @"the new table model has non-unique row keys");

    BumpTransition *rowInfo = [[self class] rowTransitionFrom:oldModel to:newModel
                                                 fromSections:oldS toSections:newS
                                                     fromRows:oldIps toRows:newIps
                                                 sameSections:sectionInfo.mutual];
    NSArray *thenVisibleIps = [self indexPathsForVisibleRows];
    [self beginUpdates];
    for (NSObject *key in sectionInfo.inserted) {
        [self insertSections:[newS objectForKey:key]
                  withRowAnimation:insertAnimation];
    }
    for (NSObject *key in sectionInfo.deleted) {
        [self deleteSections:[oldS objectForKey:key]
                  withRowAnimation:deleteAnimation];
    }
    // TODO: Remove this NO once section moving bugs are resolved
    if ([self respondsToSelector:@selector(moveSection:toSection:)]) {
        for (NSObject *key in sectionInfo.moved) {
            [self moveSection:[[oldS objectForKey:key] firstIndex]
                          toSection:[[newS objectForKey:key] firstIndex]];
        }
    }
    [self insertRowsAtIndexPaths:[newIps objectsForKeys:[rowInfo.inserted allObjects]
                                               notFoundMarker:[NSNull null]]
                      withRowAnimation:insertAnimation];
    [self deleteRowsAtIndexPaths:[oldIps objectsForKeys:[rowInfo.deleted allObjects]
                                               notFoundMarker:[NSNull null]]
                      withRowAnimation:deleteAnimation];
    if ([self respondsToSelector:@selector(moveRowAtIndexPath:toIndexPath:)]) {
        for (NSObject *key in rowInfo.moved) {
            [self moveRowAtIndexPath:[oldIps objectForKey:key]
                               toIndexPath:[newIps objectForKey:key]];
        }
    }
    [self endUpdates];
    NSArray *nowVisibleIps = [self indexPathsForVisibleRows];
    NSMutableArray *toReload = [NSMutableArray array];
    for (NSIndexPath *ip in thenVisibleIps) {
        BumpTableRow *oldRow = [[self class] rowForIndexPath:ip model:oldModel];
        NSObject *key = [oldRow key];
        NSIndexPath *newIp = [newIps objectForKey:key];
        if (newIp && [nowVisibleIps containsObject:newIp]) {
            BumpTableRow *row = [[self class] rowForIndexPath:newIp model:newModel];
            if ([[row reuseIdentifier] isEqualToString:[oldRow reuseIdentifier]]) {
                UITableViewCell *cell = [self cellForRowAtIndexPath:newIp];
                if (row.customizer) {
                    row.customizer(cell);
                }
            } else {
                [toReload addObject:newIp];
            }
        }
    }
    if ([toReload count]) {
        [self reloadRowsAtIndexPaths:toReload
                          withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - Transitions helpers

- (void)setTranstionAnimation:(UITableViewRowAnimation)transtionAnimation {
    _transtionAnimation = transtionAnimation;
}

/**
 * This takes two arrays of keys and returns a set of mismatches
 */
+ (NSSet *)movedKeysFrom:(NSArray *)old to:(NSArray *)new {
    NSMutableSet *moved = [NSMutableSet set];
    int i;
    for (i = 0; i < old.count && i < new.count; i++) {
        NSObject *key = [old objectAtIndex:i];
        if (![key isEqual:[new objectAtIndex:i]]) {
            [moved addObject:key];
        }
    }
    for (; i < old.count; i++) {//we hit the end of the other sections
        [moved addObject:[old objectAtIndex:i]];
    }
    return moved;
}

+ (BumpTransition *)sectionTransitionFrom:(NSArray *)oldSections to:(NSArray *)newSections {
    NSMutableSet *insertedSections = [NSMutableSet set];
    NSMutableSet *deletedSections = [NSMutableSet set];

    //calculate inserted and deleted sections
    id (^secKeys)(id) = ^id(BumpTableSection *s) { return s.key; };
    NSSet *oldSKeys = [NSSet setWithArray:[oldSections
                                           mapWithBlock:secKeys]];
    NSSet *newSKeys = [NSSet setWithArray:[newSections
                                           mapWithBlock:secKeys]];
    NSMutableSet *mutualSections = [NSMutableSet setWithSet:oldSKeys];
    [mutualSections intersectSet:newSKeys];
    [deletedSections unionSet:oldSKeys];
    [deletedSections minusSet:mutualSections];
    [insertedSections unionSet:newSKeys];
    [insertedSections minusSet:mutualSections];

    BOOL (^goodSecs)(id) = ^ BOOL(NSObject *key) {
        return [mutualSections containsObject:key];
    };
    //calculate moved sections
    NSSet *movedSections = [self movedKeysFrom:[[oldSections mapWithBlock:secKeys]
                                                filterWithBlock:goodSecs]
                                            to:[[newSections mapWithBlock:secKeys]
                                                filterWithBlock:goodSecs]];
    if (![UITableView instancesRespondToSelector:@selector(moveRowAtIndexPath:toIndexPath:)]) {
        for (NSObject *key in movedSections) {
            [deletedSections addObject:key];
            [insertedSections addObject:key];
            [mutualSections removeObject:key];
        }
    }

    BumpTransition *sectionTransition = [BumpTransition new];
    sectionTransition.inserted = insertedSections;
    sectionTransition.deleted = deletedSections;
    sectionTransition.mutual = mutualSections;
    sectionTransition.moved = movedSections;
    return sectionTransition;
}

+ (BumpTransition *)rowTransitionFrom:(BumpTableModel *)oldModel
                                   to:(BumpTableModel *)newModel
                         fromSections:(NSDictionary *)oldSecIx
                           toSections:(NSDictionary *)newSecIx
                             fromRows:(NSDictionary *)oldIps
                               toRows:(NSDictionary *)newIps
                         sameSections:(NSSet *)mutualSections {
    NSMutableSet *insertedRows = [NSMutableSet set];
    NSMutableSet *deletedRows = [NSMutableSet set];
    NSMutableSet *movedRows = [NSMutableSet set];

    //check the sections that stay the same for inserted and deleted rows
    //first make deleted and inserted supersets of actual deletions/ insertions
    for (NSObject *key in mutualSections) {
        NSDictionary *oldSectionIps = [oldIps objectForKey:key];
        NSDictionary *newSectionIps = [newIps objectForKey:key];
        NSAssert(oldSectionIps && newSectionIps, @"mutual section should be in old %@ and new %@", oldSectionIps, newSectionIps);
        [deletedRows addObjectsFromArray:[oldSectionIps allKeys]];
        [insertedRows addObjectsFromArray:[newSectionIps allKeys]];
    }
    NSMutableSet *mutualRows = [NSMutableSet setWithSet:deletedRows];
    [mutualRows intersectSet:insertedRows];
    //then subtract things that are the same
    [deletedRows minusSet:mutualRows];
    [insertedRows minusSet:mutualRows];

    //check the rows for mismatched sections, add them to the moved rows
    for (NSObject *key in mutualRows) {
        NSIndexPath *oldIp = [oldIps objectForKey:key];
        NSIndexPath *newIp = [newIps objectForKey:key];
        NSAssert(oldIp && newIp, @"mutual row should have both old %@ and new %@ ips", oldIp, newIp);
        BumpTableSection *oldSection = [self sectionForIndex:[oldIp section] model:oldModel];
        BumpTableSection *newSection = [self sectionForIndex:[newIp section] model:newModel];
        NSAssert(oldSection && newSection, @"mutual row should have old section %@ and new %@", oldSection, newSection);
        if (![oldSection.key isEqual:newSection.key]) {
            [movedRows addObject:key];
        }
    }

    //compare the rows in the old model's sections to the new model's corresponding section
    for (NSObject *key in mutualSections) {
        NSIndexSet *oldSectionIx = [oldSecIx objectForKey:key];
        NSIndexSet *newSectionIx = [newSecIx objectForKey:key];
        NSAssert(oldSectionIx && newSectionIx, @"mutual row should have old sectionIx %@ and newIx %@", oldSectionIx, newSectionIx);
        BumpTableSection *oldSection = [self sectionForIndex:[oldSectionIx firstIndex] model:oldModel];
        BumpTableSection *newSection = [self sectionForIndex:[newSectionIx firstIndex] model:newModel];
        NSAssert(oldSection && newSection, @"mutual row should have old section %@ and new %@", oldSection, newSection);
        id (^rKey)(id) = ^(BumpTableRow *r) { return r.key; };
        BOOL (^goodRow)(id) = ^BOOL(NSObject *key) {
            return [mutualRows containsObject:key] && ![movedRows containsObject:key];
        };
        NSSet *movedInThisSection = [self movedKeysFrom:[[oldSection.rows mapWithBlock:rKey]
                                                         filterWithBlock:goodRow]
                                                     to:[[newSection.rows mapWithBlock:rKey]
                                                         filterWithBlock:goodRow]];
        [movedRows unionSet:movedInThisSection];
    }

    if (![UITableView instancesRespondToSelector:@selector(moveRowAtIndexPath:toIndexPath:)]) {
        for (NSObject *key in movedRows) {
            [deletedRows addObject:key];
            [insertedRows addObject:key];
            [mutualRows removeObject:key];
            //NOTE: if you use non-standard cell caching, you may also want to reload these later
        }
    }

    BumpTransition *rowTransition = [BumpTransition new];
    rowTransition.inserted = insertedRows;
    rowTransition.deleted = deletedRows;
    rowTransition.mutual = mutualRows;
    rowTransition.moved = movedRows;
    return rowTransition;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self rowForTableView:tableView indexPath:indexPath] height];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _searchResultsTableView) return 0.0;
    return [[[self sectionForIndex:section] header] height];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == _searchResultsTableView) return 0.0;
    return [[[self sectionForIndex:section] footer] height];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == _searchResultsTableView) return nil;
    return [self sectionForIndex:section].header.generator();
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (tableView == _searchResultsTableView) return nil;
    return [self sectionForIndex:section].footer.generator();
}

- (void)reloadOtherTableView:(UITableView *)currentTableView {
    UITableView *other;
    if (currentTableView == _searchResultsTableView)
        other = self;
    else
        other = _searchResultsTableView;
    [other reloadData];
}

- (void)toggleRow:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    BumpTableRow *row = [self rowForTableView:tableView indexPath:indexPath];
    row.selected = !row.selected;
    BumpTableViewCell *cell = (BumpTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (row.selected) {
        if (row.onSelection) row.onSelection(cell);
    } else {
        if (row.onDeselection) row.onDeselection(cell);
    }
    [cell selectCell:row.selected];
    [self reloadOtherTableView:tableView];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self toggleRow:indexPath inTableView:tableView];
    BumpTableRow *row = [self rowForTableView:tableView indexPath:indexPath];
    BumpTableViewCell *cell = (BumpTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (row.onTap) row.onTap(cell);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self toggleRow:indexPath inTableView:tableView];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BumpTableRow *row = [self rowForTableView:tableView indexPath:indexPath];
        BumpTableViewCell *cell = (BumpTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (row.onSwipeConfirmation) row.onSwipeConfirmation(cell);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _swipeConfirmationTitle;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _searchResultsTableView) return 1;
    return [[_model sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _searchResultsTableView) {
        return [_searchResultsRows count];
    }
    return [[[self sectionForIndex:section] rows] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BumpTableRow *row = [self rowForTableView:tableView indexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.reuseIdentifier];
    if (!cell) {
        cell = row.generator(row.reuseIdentifier);
    }
    if (row.customizer) {
        row.customizer(cell);
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return _allowsSwipeConfirmation;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView != _searchResultsTableView && _showSectionIndexTitles) {
        NSMutableArray *indexTitles = [NSMutableArray array];
        for (BumpTableSection *section in _model.sections) {
            [indexTitles addObject:section.indexTitle];
        }
        return indexTitles;
    } else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

#pragma mark - Searching

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width, SEARCH_BAR_HEIGHT)];
        _searchBar.backgroundImage = [UIImage imageNamed:@"searchbar_invites.png"];
        self.tableHeaderView = _searchBar;
    }
    return _searchBar;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    _searchResultsTableView = tableView;
    _searchResultsTableView.backgroundColor = self.backgroundColor;
    _searchResultsTableView.separatorStyle = self.separatorStyle;
    _searchResultsRows  = [NSArray array];
}


- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    _searchResultsTableView = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSMutableArray *_newResults = [_model rowsForSearchString:searchString];

    if ([_newResults isEqual:_searchResultsRows]) {
        return NO;
    }
    _searchResultsRows = _newResults;
    return YES;
}

@end
