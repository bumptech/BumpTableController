//
//  BumpTableModel.h
//
//  Created by Sahil Desai on 12/11/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BumpTableSection;
@class BumpTableRow;

typedef BOOL(^BumpTableRowPredicate)(BumpTableRow *row);

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
 @method
 @abstract
 Creates and returns an model object configured with the sections provided

 @param sections    Array of `BumpTableSection` objects
 */
+ (instancetype)modelWithSections:(NSArray *)sections;

/*!
 @method
 @abstract
 Creates and returns an model object configured with the rows provided 
 inside of a single section with the key "all"

 @param rows        Array of `BumpTableRow` objects
 */
+ (instancetype)modelWithRows:(NSArray *)rows;

/*!
 @method
 @abstract
 Returns a dictionary containing the `NSIndexPath` of each section keyed on their unique keys
 */
- (NSDictionary *)sectionIndexes;

/*!
 @method
 @abstract
 Returns a dictionary containing the `NSIndexPath` of each row, keyed on their unique keys
 */
- (NSDictionary *)rowIndexPaths;

/*!
 @method
 @abstract
 Returns an array that contains each table-row, resulting from a filter of all
 rows in the current model using the given string

 @param searchString    The string to use to filter
 */
- (NSMutableArray *)rowsForSearchString:(NSString *)searchString;

/*!
 @method
 @abstract
 Same as rowsForSearchString, except the resulting filtered rows are wrapped 
 in a `BumpTableModel` and returned

 @param searchString    The string to use to filter
 */
- (BumpTableModel *)modelForSearchString:(NSString *)searchString;

/*!
 @method
 @abstract
 Returns the `NSIndexPath` for a given row. Will return nil if row does not exist in this table

 @param row     A table row that exists in this model
 */
- (NSIndexPath *)indexPathForRow:(BumpTableRow *)row;


/*!
 @method
 @abstract
 Returns a list of BumpTableRow objects that match the given predicate

 @param predicate   block that takes a row and returns a boolean
 */
- (NSArray *)rowsForPredicate:(BumpTableRowPredicate)predicate;

@end


/*!
 @typedef BumpTableHeaderFooterGenerator

 @abstract
 Block used to create and return a UIView to be used as a table header or footer
 */
typedef UIView *(^BumpTableHeaderFooterGenerator)(void);

/*!
 @class BumpTableHeaderFooter

 @abstract
 Model for a table header or footer
 */
@interface BumpTableHeaderFooter : NSObject

/*!
 @abstract
The title of this header or footer. Note that this is ignored
by UITableView if a generator is supplied.
 */
@property (nonatomic, retain) NSString *title;

/*!
 @abstract
 the height of the header or footer view
 */
@property (nonatomic) CGFloat height;

/*!
 @abstract
 The generator that it used to create the table header or footer
 */
@property (nonatomic, copy) BumpTableHeaderFooterGenerator generator;

/*!
 @abstract
 Generates the view or returns nil if no generator is set
 */
- (UIView *)view;

/*!
 @method
 @abstract
 Creates and returns a headerFooter model object, to be set on a table model

 @param height      The height of the header or footer view
 @param generator   The block used to create the header or footer view
 */
+ (instancetype)headerFooterForHeight:(CGFloat)height generator:(BumpTableHeaderFooterGenerator)generator;

/*!
 @method
 @abstract
 Creates and returns a headerFooter model object, to be set on a table model

 @param title      The title of this header or footer
 */
+ (instancetype)headerFooterWithTitle:(NSString *)title;

@end


/*!
 @class BumpTableSection

 @abstract
 The model object used to describe a table section
 */
@interface BumpTableSection : NSObject

/*!
 @abstract
 Must be unique in a table, specific within section. Used to animate transitions
 */
@property (nonatomic, strong) NSObject <NSCopying> *key;

/*!
 @abstract
 Array of table row objects contained in this section
 */
@property (nonatomic, strong) NSArray *rows;

/*!
 @abstract
 The index title to use if the table has scrubber enabled
 */
@property (nonatomic, strong) NSString *indexTitle;


/*!
 @abstract
 Header model for table
 */
@property (nonatomic, strong) BumpTableHeaderFooter *header;

/*!
 @abstract
 Footer model for table
 */
@property (nonatomic, strong) BumpTableHeaderFooter *footer;

/*!
 @method
 @abstract
 Creates and returns a table section with the given key and rows

 @param key     A unique key used to identify this section
 @param rows    The rows that should be in this section (cannot be nil)
 */
+ (instancetype)sectionWithKey:(NSObject<NSCopying>*)key rows:(NSArray*)rows;

@end


/*!
 @typedef BumpTableCellGenerator

 @abstract

 @discussion

 */
typedef UITableViewCell *(^BumpTableCellGenerator)(NSString *reuseIdentifier);

/*!
 @typedef BumpTableCellUpdater

 @abstract

 @discussion

 */
typedef void (^BumpTableCellUpdater)(id cell);

/*!
 @typedef BumpTableCellOnTap

 @abstract

 @discussion

 */
typedef void (^BumpTableCellOnTap)(id cell);

/*!
 @typedef BumpTableCellOnSwipeConfirmation

 @abstract

 @discussion

 */
typedef void (^BumpTableCellOnSwipeConfirmation)(id cell);

/*!
 @class BumpTableRow

 @abstract
 The model object used to describe a table row
 */
@interface BumpTableRow : NSObject

/*!
 @abstract
 Must be unique in a table, specific to the data of one row. Used to animate transitions
 */
@property (nonatomic, strong) NSObject <NSCopying> *key;

/*!
 @abstract
 String to be used for searching
 */
@property (nonatomic, copy) NSString *searchString;

/*!
 @abstract
 The height of the cell, needed by UITableView for upfront calculation
 */
@property (nonatomic) CGFloat height;

/*!
 @abstract
 Identifies the cell for use by other similar rows
 */
@property (nonatomic, strong) NSString *reuseIdentifier;

/*!
 @abstract
 Indicates whether this row is selectable. Defaults to yes.
*/
@property (nonatomic) BOOL selectable;

/*!
 @abstract
 Indicates whether this row is currently selected.
 */
@property (nonatomic) BOOL selected;

/*!
 @abstract
 if a cell of the designated reuseId can't be produced by recycling old ones,
 this will generate a new one. Note: this may not be called for all rows,
 and the cell returned may be recycled for other rows
 */
@property (nonatomic, copy) BumpTableCellGenerator generator;

/*!
 @abstract
 This is called to customize the cell for this particular row.
 This will be called upon creation of a new cell, when the cell recycles,
 and when the model changes (if cell is visible)
 */
@property (nonatomic, copy) BumpTableCellUpdater customizer;

/*!
 @abstract
 This get's called when the user taps on a row.
 It should be used if you don't care about selection state callbacks below
 */
@property (nonatomic, copy) BumpTableCellOnTap onTap;

/*!
 @abstract
 This gets called when the row's swipe confirmation button is pressed
 */
@property (nonatomic, copy) BumpTableCellOnSwipeConfirmation onSwipeConfirmation;

/*!
 @method
 @abstract
 Creates and returns a table row with the given information

 @param key                 Unique key used to identify this row (for transition purposes)
 @param height              The height of this row
 @param reuseIdentifier     The reuseIdentifier to use for cell recycling
 @param generator           The block used to create and initially configure a cell for this row
 */
+ (instancetype)rowWithKey:(NSObject <NSCopying>*)key
                    height:(CGFloat)height
           reuseIdentifier:(NSString *)reuseIdentifier
                 generator:(BumpTableCellGenerator)generator;

+ (instancetype)rowWithKey:(NSObject <NSCopying>*)key
                    height:(CGFloat)height
           reuseIdentifier:(NSString *)reuseIdentifier;

@end