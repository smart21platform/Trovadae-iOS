//
//  SHPGridCell.m
//  Shopper
//
//  Created by andrea sponziello on 01/09/12.
//
//

#import "SHPGridCell.h"

@implementation SHPGridCell

@synthesize insets;
@synthesize columnViews;
@synthesize columnsCount;

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

-(id)initWithViews:(NSArray *)views_ insets:(UIEdgeInsets)insets_ reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(NSInteger)cellWidth {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    self.columnViews = views_;
    self.columnsCount = views_.count;
    if (self) {
        UIView *contentView_ = self.contentView;
        // Initialization code
        self.insets = insets_;
        float topPad = insets_.top;
        float bottomPad = insets_.bottom;
//        float padBetween = 5;
        UIView *firstView = [views_ objectAtIndex:0];
        float allViewsWidth = firstView.frame.size.width * columnsCount;
        float viewHeight = firstView.frame.size.height;
        float viewWidth = firstView.frame.size.width;
        float padBetween = (cellWidth - allViewsWidth) / (columnsCount + 1);
//        for (int i = 0; i < views.count; i++) {
//            UIView *view = (UIView *)[views objectAtIndex:i];
//            allViewsWidth += view.frame.size.width;
//            if (i > 0) {
//                allViewsWidth += padBetween;
//            }
//            viewHeight = view.frame.size.height;
//        }
        float startX = padBetween;
        for (UIView *view in views_) {
            CGRect frame = view.frame;
            frame.origin.x = startX;
            frame.origin.y = topPad;
            view.frame = frame;
            [contentView_ addSubview:view];
            startX = startX + viewWidth + padBetween;
        }
        CGRect contentViewFrame = contentView_.frame;
        contentViewFrame.size.width = cellWidth;
        contentViewFrame.size.height = topPad + viewHeight + bottomPad;
    }
    return self;
}

-(void)hideColumnsFromIndex:(NSInteger)index {
    for (int i = 0; i < index; i++) {
        UIView *v = [self.columnViews objectAtIndex:i];
        v.hidden = NO;
    }
    for (int i = index; i < self.columnViews.count; i++) {
        UIView *v = [self.columnViews objectAtIndex:i];
        v.hidden = YES;
    }
}

-(UIView *)viewAtColumn:(NSInteger)columnIndex {
    return (UIView *)[self.columnViews objectAtIndex:columnIndex];
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
