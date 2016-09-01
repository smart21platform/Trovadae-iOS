//
//  SHPImageUtil.h
//  Shopper
//
//  Created by andrea sponziello on 13/08/12.
//
//

#import <Foundation/Foundation.h>

@class SHPProduct;

@interface SHPImageUtil : NSObject


+(UIImage *)adjustEXIF:(UIImage *)image;
+(CGSize)fitSize:(CGSize)size intoSize:(CGSize)size;
+(CGSize)fitSizeWidth:(CGSize)size intoSize:(CGSize)newSize;
+(CGSize)imageSizeForProduct:(SHPProduct *)p constrainedInto:(CGSize)intoSize;
+(UIImage *)scaleImage:(UIImage*)image toSize:(CGSize)size;
+(UIImage *)previewThumbOnImage:(UIImage *)thumb image:(UIImage *)image;
+(UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)tintColor;
+(void)drawViewShadow:(UIView *)view;
+(UIImage *)imageWithColor:(UIColor *)tintColor withRect:(CGRect)drawRect;
+ (UIColor *)colorWithHexString:(NSString *)colorString;
+ (UIColor *)colorWithHexValue:(int)hexValue;

+(void)customIcon:(UIImageView *)iconImage;
+(void)arroundImage:(float)borderRadius borderWidth:(float)borderWidth layer:(CALayer *)layer;
+(UIImage *)circleImage:(UIImage *)image;
+(void)rotateImageView:(UIImageView *)imageView angle:(float)angle;
+(void)rotateImageViewWithAnimation:(UIImageView *)imageView duration:(float)duration angle:(float)angle;

+(UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize;
+(UIImage *)blur:(UIImage*)theImage radius:(CGFloat)radius;
+ (UIImage *)imageWithColor:(UIColor *)color;
@end
