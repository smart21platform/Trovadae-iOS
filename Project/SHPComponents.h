//
//  SHPComponents.h
//  Shopper
//
//  Created by andrea sponziello on 18/08/12.
//
//

#import <Foundation/Foundation.h>

@class SHPApplicationSettings;
@class SHPApplicationContext;

@interface SHPComponents : NSObject

+(void)setTrasparentBackground:(UINavigationController *)navigationController;
+(void)customBackButton:(UINavigationController *)navigationController;
+(UIView *)viewByXibName:(NSString *)xibName;
+(void)titleLogoForViewController:(UIViewController *)vc;
+(void)customizeTitle:(NSString *)title vc:(UIViewController *)vc;
+(void)customizeTitleWithImage:(UIImage *)title_image vc:(UIViewController *)vc;
+(UIBarButtonItem *)backButtonWithTarget:(UIViewController *)target settings:(SHPApplicationSettings *)settings;
+(UIBarButtonItem *)backMagnifyButtonWithTarget:(UIViewController *)target;
+(float)mainCellHeightForImageSize:(CGSize)imageSize descriptionHeight:(float)descriptionHeight;
//+(void)adjustCell:(UITableViewCell *)cell forImageSize:(CGSize)imageSize;
+(void)adjustCell:(UITableViewCell *)cell forImageSize:(CGSize)imageSize withDescription:(NSString *)description;
+(UITableViewCell *) MainListCell:(SHPApplicationSettings *)settings withTarget:(UIViewController *)target;
+(UITableViewCell *) MainListMoreResultsCell:(UIColor *)bgColor withTarget:(NSObject *)target settings:(SHPApplicationSettings *)settings;
+(void)updateMoreButtonCell:(UITableViewCell *)cell noMoreData:(BOOL)noMoreData isLoadingData:(BOOL)isLoadingData;
+(UIView *) MainListShowMenuButton:(NSObject *)target settings:(SHPApplicationSettings *)settings;
+(UIView *) closeImageDetailControllerButton:(NSObject *)target;

+(UILabel *)appTitleLabel:(NSString *)title withSettings:(SHPApplicationSettings *)settings;
+(UIImageView *)appTitleImage:(UIImage *)image;
+(UIView *)productDetailControlPanel:(SHPApplicationSettings *)settings width:(float)width target:(UIViewController *)target;

// shop grid
+(UIView *)sectionHeader;
// user grid
+(UIView *)userSectionHeaderWithTarget:(UIViewController *)target;
+(UIView *)gridProductView:(SHPApplicationSettings *)settings withTarget:(NSObject *)target;

// search view
+(UIView *)searchBarWithTarget:(UIViewController *)target;
+(UIView *)searchButtonsSectionHeaderWithTarget:(UIViewController *)target;

// utils
+(void)setLikeButton:(UIButton *)button withState:(NSString *)buttonState;
+(void)setLikeButtonForProductDetail:(UIButton *)button withState:(NSString *)buttonState;
+(float)centerX:(float)containerWidth contentWidth:(float)contentWidth;
+(float)centerY:(float)containerHeight contentHeight:(float)contentHeight;
+(void)centerView:(UIView *)view inView:(UIView *)containerView;
+(void)adjustLabel:(UILabel *)label forText:(NSString *)text maxWidth:(float)maxWidth;
+(void)adjustLabel:(UILabel *)label forText:(NSString *)text;

+(UIBarButtonItem *)positionInfoButton:(UIViewController *)target;

// plist reader
+(NSDictionary *)getConfigValueFromWizardPlist:(SHPApplicationContext *)applicationContext typeSelected:(NSString *)typeSelected;

// plist reader
+(NSDictionary *)getDictionaryFromPlist:(SHPApplicationContext *)applicationContext arrayNames:(NSArray *)arrayNames;

//DICTIONARY
+(NSDictionary *)mergeDictionaries:(NSDictionary *)first second:(NSDictionary *)second;
//google analytics
//+(void)trackerGoogleAnalytics:(NSString *)className;

@end
