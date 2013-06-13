//
//  BumpTableModel.m
//
//  Created by Sahil Desai on 12/11/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import "BumpTableModel.h"
#import "NSArray+Bump.h"
#import "NSObject+Bump.h"

@interface BumpTableModel ()
@property (nonatomic) NSMutableDictionary *sectionNumberForRow;
@property (nonatomic) NSMutableDictionary *rowNumberForRow;
@end

@implementation BumpTableModel : NSObject

+ (instancetype)modelWithSections:(NSArray *)sections {
    BumpTableModel *model = [self new];
    model.sections = sections;
    return model;
}

+ (instancetype)modelWithRows:(NSArray *)rows {
    [rows enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        NSAssert([obj isKindOfClass:[BumpTableRow class]],
                 @"Array passed into modelWithRows: must only contain BumpTableRow objects");
    }];
    BumpTableSection *section = [BumpTableSection sectionWithKey:@"all" rows:rows];
    NSArray *sections = [NSArray arrayWithObject:section];
    return [BumpTableModel modelWithSections:sections];
}

#pragma mark - Setters

- (void)setSections:(NSArray *)sections {
    [sections enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        NSAssert([obj isKindOfClass:[BumpTableSection class]],
                 @"Each element in the sections array must be a BumpTableSection");
    }];
    _sections = [NSArray arrayWithArray:sections];
}

- (void)generateIndexPathIndex {
    self.sectionNumberForRow = [NSMutableDictionary dictionary];
    self.rowNumberForRow = [NSMutableDictionary dictionary];

    for (int sectionNumber = 0; sectionNumber < [self.sections count]; sectionNumber++) {
        BumpTableSection *section = [self.sections objectAtIndex:sectionNumber];

        for (int rowNumber = 0; rowNumber < [[section rows] count]; rowNumber++) {
            BumpTableRow *row = [[section rows] objectAtIndex:rowNumber];
            [self.sectionNumberForRow setObject:@(sectionNumber) forKey:row.key];
            [self.rowNumberForRow setObject:@(rowNumber) forKey:row.key];
        }
    }
}

- (NSIndexPath *)indexPathForRow:(BumpTableRow *)row {
    if(!self.rowNumberForRow) {
        [self generateIndexPathIndex];
    }
    NSNumber *rowNumber = self.rowNumberForRow[row.key];
    NSNumber *sectionNumber = self.sectionNumberForRow[row.key];
    if (rowNumber && sectionNumber) {
        return [NSIndexPath indexPathForRow:[rowNumber intValue]
                                  inSection:[sectionNumber intValue]];
    }
    return nil;
}

- (NSDictionary *)sectionIndexes {
    NSMutableDictionary *indexes = [NSMutableDictionary dictionaryWithCapacity:[_sections count]];
    [_sections enumerateObjectsUsingBlock:^(BumpTableSection *s, NSUInteger idx, BOOL *stop) {
        [indexes setObject:[NSIndexSet indexSetWithIndex:idx] forKey:s.key];
    }];
    return indexes;
}

- (NSDictionary *)rowIndexPaths {
    NSMutableDictionary *indexPaths = [NSMutableDictionary dictionaryWithCapacity:
                                       [_sections sumWithBlock:
                                        ^int(BumpTableSection *s) {
                                            return s.rows.count + 1;
                                        }]];
    [_sections enumerateObjectsUsingBlock:^(BumpTableSection *s, NSUInteger sidx, BOOL *stop) {
        NSMutableDictionary *sectionIndexPaths = [NSMutableDictionary dictionaryWithCapacity:s.rows.count];
        [s.rows enumerateObjectsUsingBlock:^(BumpTableRow *r, NSUInteger ridx, BOOL *stop) {
            [sectionIndexPaths setObject:[NSIndexPath indexPathForRow:ridx inSection:sidx]
                                  forKey:r.key];
        }];
        [indexPaths setObject:sectionIndexPaths forKey:s.key];
        [indexPaths addEntriesFromDictionary:sectionIndexPaths];
    }];
    return indexPaths;
}

- (NSMutableArray *)rowsForSearchString:(NSString *)searchString {
    searchString = [searchString lowercaseString];
    NSMutableArray *results = [NSMutableArray array];
    [_sections enumerateObjectsUsingBlock:^(BumpTableSection *s, NSUInteger sidx, BOOL *stop) {
        [s.rows enumerateObjectsUsingBlock:^(BumpTableRow *r, NSUInteger ridx, BOOL *stop) {
            if (r.searchString && [r.searchString rangeOfString:searchString].location != NSNotFound) {
                [results addObject:r];
            }
        }];
    }];
    return results;
}

- (BumpTableModel *)modelForSearchString:(NSString *)searchString {
    return [BumpTableModel modelWithRows:[self rowsForSearchString:searchString]];
}

- (NSArray *)rowsForPredicate:(BumpTableRowPredicate)predicate {
    NSMutableArray *rows = [NSMutableArray array];
    [_sections enumerateObjectsUsingBlock:^(BumpTableSection *s, NSUInteger idx, BOOL *stop) {
        [s.rows enumerateObjectsUsingBlock:^(BumpTableRow *r, NSUInteger idx, BOOL *stop) {
            if (predicate(r)) [rows addObject:r];
        }];
    }];

    return rows;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Model sections:%@\n>", [_sections indentedDescription]];
}

@end

@implementation BumpTableHeaderFooter {
    CGFloat _height;
}

@dynamic height;

+ (instancetype)headerFooterForHeight:(CGFloat)height generator:(BumpTableHeaderFooterGenerator)generator {
    BumpTableHeaderFooter *hf = [BumpTableHeaderFooter new];
    hf.height = height;
    hf.generator = generator;
    return hf;
}

+ (instancetype)headerFooterWithTitle:(NSString *)title {
    BumpTableHeaderFooter *hf = [BumpTableHeaderFooter new];
    hf.title = title;
    return hf;
}

- (UIView *)view {
    if (_generator) return _generator();
    return nil;
}

- (void)setHeight:(CGFloat)height {
    _height = height;
}

- (CGFloat)height {
    if (_height == 0.0) {
        if (!_title)
            return 0.0;
        if ([[UIDevice currentDevice].systemVersion intValue] >= 5)
            return UITableViewAutomaticDimension;
        else return 22.0;   // Grouped table views should be 10.0, this only affects < iOS 5
    }
    return _height;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Header/Footer height: %f generator:%d\n>", _height, !!_generator];
}

@end

@implementation BumpTableSection

+ (instancetype)sectionWithKey:(NSObject <NSCopying>*)key rows:(NSArray*)rows {
    BumpTableSection *section = [self new];
    section.key = key;
    section.rows = [NSArray arrayWithArray:rows];
    return section;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Section key:%@\nheader:%@\nfooter:%@\nrows:%@\n>",
            self.key,
            self.header,
            self.footer,
            [self.rows indentedDescription]];
}

@end

@implementation BumpTableRow {
    BOOL _selected;
    NSString *_searchString;
}

@dynamic searchString, selected;

+ (instancetype)rowWithKey:(NSObject <NSCopying>*)key
                    height:(CGFloat)height
           reuseIdentifier:(NSString *)reuseIdentifier
                 generator:(BumpTableCellGenerator)generator {
    BumpTableRow *row = [self new];
    row.key = key;
    row.height = height;
    row.reuseIdentifier = reuseIdentifier;
    row.generator = generator;
    row.selectable = YES;
    return row;
}

+ (instancetype)rowWithKey:(NSObject <NSCopying>*)key
                    height:(CGFloat)height
           reuseIdentifier:(NSString *)reuseIdentifier
{
    return [[self class] rowWithKey:key
                      height:height
             reuseIdentifier:reuseIdentifier
                   generator:NULL];
}

- (void)setSelected:(BOOL)selected {
    assert(self.selectable);
    _selected = selected;
}

- (BOOL)selected {
    return _selected;
}

- (void)setSearchString:(NSString *)searchString {
    _searchString = [[searchString lowercaseString] copy];
}

- (NSString *)searchString {
    return _searchString;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<Row key:%@\nsearch string:%@\nheight:%f\nreuse:%@\ngenerator:%d\ncustomizer:%d\nonTap:%d\n>",
            self.key,
            self.searchString,
            self.height,
            self.reuseIdentifier,
            !!self.generator,
            !!self.customizer,
            !!self.onTap];
}

@end