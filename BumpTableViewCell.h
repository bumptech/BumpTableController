//
//  BumpTableViewCell.h
//
//  Created by Sahil Desai on 12/11/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BumpTableViewCell : UITableViewCell
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier initialHeight:(CGFloat)height;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier initialHeight:(CGFloat)height;
// this is a selection call that UITableView won't call: when we are using multiple selection
- (void)selectCell:(BOOL)selected;
@end
