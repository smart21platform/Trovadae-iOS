//
//  SHPGridCell.h
//  Shopper
//
//  Created by andrea sponziello on 01/09/12.
//
//

#import <UIKit/UIKit.h>

@interface SHPGridCell : UITableViewCell

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, strong) NSArray *columnViews;
@property (nonatomic, assign) NSInteger columnsCount;

-(id)initWithViews:(NSArray *)views_ insets:(UIEdgeInsets)insets_ reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(NSInteger)cellWidth;

-(void)hideColumnsFromIndex:(NSInteger)index;

-(UIView *)viewAtColumn:(NSInteger)columnIndex;

@end
