//
//  BumpTableViewCell.m
//
//  Created by Sahil Desai on 12/11/12.
//  Copyright (c) 2012 Bump Technologies Inc. All rights reserved.
//

#import "BumpTableViewCell.h"

#define DEFAULT_HEIGHT 44.0f

@implementation BumpTableViewCell

#pragma mark - Lifecycle

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    return [self initWithReuseIdentifier:reuseIdentifier initialHeight:DEFAULT_HEIGHT];
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier initialHeight:(CGFloat)height {
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier initialHeight:height];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier initialHeight:(CGFloat)height {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        CGRect b = self.contentView.bounds;
        b.size.height = height;
        self.contentView.bounds = b;
    }
    return self;
}

// Override in order to update custom UI for BumpTableView multiple selection
- (void)selectCell:(BOOL)selected {
    // Empty implementation
}

@end
