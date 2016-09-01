//
//  SHPBackgroundView.m
//  BirdWatching
//
//  Created by andrea sponziello on 29/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPBackgroundView.h"

@implementation SHPBackgroundView

@synthesize rectColor;
@synthesize radius;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) drawRect:(CGRect)rect {    
    [super drawRect:rect];
    //CGRect rectangle = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
    //CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    //CGContextFillRect(context, rectangle);
    
//    CGFloat radius = 2.0;
    UIColor *shadowColorDark = [UIColor colorWithRed:188.0f/255.0f green:190.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
    
    
    CGRect shadowRectLightDark = CGRectMake(radius, 0, self.frame.size.width - radius * 2, self.frame.size.height - 0.5);
    CGPathRef shadowLightDarkPath = [self newPathForRoundedRect:shadowRectLightDark radius:radius];
    
    CGRect shadowRectDark = CGRectMake(0.5, 0, self.frame.size.width - 1, self.frame.size.height - 1);
    CGPathRef shadowDarkPath = [self newPathForRoundedRect:shadowRectDark radius:radius];
    
    CGRect backgroundRect = CGRectMake(1, 0, self.frame.size.width - 2.0, self.frame.size.height - 1.5);
    CGPathRef backgroundPath = [self newPathForRoundedRect:backgroundRect radius:radius];
    
    CGContextSetFillColorWithColor(context, shadowColorDark.CGColor);
 	CGContextAddPath(context, shadowDarkPath);
    CGContextFillPath(context);
    
    CGContextFillRect(context, shadowRectLightDark);

//    // test
//    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
//    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    
    CGContextSetFillColorWithColor(context, [self.rectColor CGColor]);
    CGContextAddPath(context, backgroundPath);
	CGContextFillPath(context);
    
	CGPathRelease(shadowLightDarkPath);
    CGPathRelease(shadowDarkPath);
    CGPathRelease(backgroundPath);
}

- (CGPathRef) newPathForRoundedRect:(CGRect)rect radius:(CGFloat)__radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
    
	CGRect innerRect = CGRectInset(rect, __radius, __radius);
    
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
    
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, __radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, __radius);
    
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, __radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, __radius);
    
	CGPathCloseSubpath(retPath);
    
	return retPath;
}

@end
