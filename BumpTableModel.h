//
//  BumpTableModel.h
//  Flock
//
//  Created by Sahil Desai on 12/11/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BumpTableSection;
@class BumpTableRow;


/*!
 @class BumpTableModel

 @abstract
 The `BumpTableModel` object is the model backing for a BumpTableView

 @discussion

 */
@interface BumpTableModel : NSObject

/*!
 @abstract
 The table section objects that make up the model
 
 @discussion
 This should only contain `BumpTableSection` objects
 */
@property (nonatomic, copy) NSArray *sections;

/*!
 @abstract
 Array containing the selected table rows
 */
@property (readonly) NSArray *selectedRows;

/*!
 @abstract
 Creates and returns an model object configured with the sections provided

 @param sections    Array of `BumpTableSection` objects
 */
+ (instancetype)modelWithSections:(NSArray *)sections;

/*!
 @abstract
 Creates and returns an model object configured with the rows provided 
 inside of a single section with the key "all"

 @param rows        Array of `BumpTableRow` objects
 */
+ (instancetype)modelWithRows:(NSArray *)rows;

/*!
 @abstract

 */
- (NSDictionary *)sectionIndexes;

/*!
 @abstract

 */
- (NSDictionary *)rowIndexPaths;

/*!
 @abstract

 @param
 */
- (BumpTableModel *)modelForSearchString:(NSString *)searchString;

/*!
 @abstract

 @param
 */
- (NSMutableArray *)rowsForSearchString:(NSString *)searchString;

/*!
 @abstract

 @param
 */
- (NSIndexPath *)indexPathForRow:(BumpTableRow *)row;

@end


/*!
 @typedef BumpTableHeaderFooterGenerator

 @abstract

 @discussion

 */
typedef UIView *(^BumpTableHeaderFooterGenerator)(void);

/*!
 @typedef BumpTableHeaderFooterUpdater

 @abstract

 @discussion

 */
typedef void (^BumpTableHeaderFooterUpdater)(UIView *header);

/*!
 @class

 @abstract

 @discussion

 */
@interface BumpTableHeaderFooter : NSObject
@property (nonatomic) CGFloat height;
@property (nonatomic, copy) BumpTableHeaderFooterGenerator generator;
+ (instancetype)headerFooterForHeight:(CGFloat)height generator:(BumpTableHeaderFooterGenerator)generator;
@end


/*!
 @class

 @abstract

 @discussion

 */
@interface BumpTableSection : NSObject
// Must be unique in a table, specific one section. Used to animate transitions
@property (nonatomic, strong) NSObject <NSCopying> *key;
// BumpTableRow objects, should not be nil
@property (nonatomic, strong) NSArray *rows;
// Scrubber Label
@property (nonatomic, strong) NSString *indexTitle;
// Header
@property (nonatomic, strong) BumpTableHeaderFooter *header;
@property (nonatomic, strong) BumpTableHeaderFooter *footer;
+ (instancetype)sectionWithKey:(NSObject<NSCopying>*)key rows:(NSArray*)rows;
@end


/*!
 @typedef BumpTableHeaderFooterUpdater

 @abstract

 @discussion

 */
typedef UITableViewCell *(^BumpTableCellGenerator)(NSString *reuseIdentifier);

/*!
 @typedef BumpTableHeaderFooterUpdater

 @abstract

 @discussion

 */
typedef void (^BumpTableCellUpdater)(id cell);

/*!
 @typedef BumpTableHeaderFooterUpdater

 @abstract

 @discussion

 */
typedef void (^BumpTableCellOnSelection)(id cell);

/*!
 @typedef BumpTableHeaderFooterUpdater

 @abstract

 @discussion

 */
typedef void (^BumpTableCellOnSwipeConfirmation)(id cell);

/*!
 @class

 @abstract

 @discussion

 */
@interface BumpTableRow : NSObject
// Must be unique in a table, specific to the data of one row. Used to animate transitions
@property (nonatomic, strong) NSObject <NSCopying> *key;
// String to be used for searching
@property (nonatomic, strong) NSString *searchString;
// The height of the cell, needed by UITableView for upfront calculation
@property (nonatomic) CGFloat height;
// Identifies the cell for use by other similar rows
@property (nonatomic, strong) NSString *reuseIdentifier;
// Indicates whether this row is selectable
@property (nonatomic) BOOL selectable;
// Indicates whether this row is selectable. Defaults to yes.
@property (nonatomic) BOOL selected;

/* if a cell of the designated reuseId can't be produced by recycling old ones,
 * this will generate a new one. Note: this may not be called for all rows,
 * and the cell returned may be recycled for other rows */
@property (nonatomic, copy) BumpTableCellGenerator generator;
/* This is called to customize the cell for this particular row.
 * This will be called upon creation of a new cell, when the cell recycles,
 * and when the model changes (if cell is visible) */
@property (nonatomic, copy) BumpTableCellUpdater customizer;

//This get's called when the user taps on a row.
//It should be used if you don't care about selection state callbacks below
@property (nonatomic, copy) BumpTableCellOnSelection onTap;

// This gets called when the row is selected
@property (nonatomic, copy) BumpTableCellOnSelection onSelection;
// This gets called when the row is deselected
@property (nonatomic, copy) BumpTableCellOnSelection onDeselection;
// This gets called when the row's swipe confirmation button is pressed
@property (nonatomic, copy) BumpTableCellOnSwipeConfirmation onSwipeConfirmation;

/*!
 @abstract

 @param
 @param
 @param
 @param 
 */
+ (instancetype)rowWithKey:(NSObject*)key
                    height:(CGFloat)height
           reuseIdentifier:(NSString *)reuseIdentifier
                 generator:(BumpTableCellGenerator)generator;
@end