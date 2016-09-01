//
//  SHPComponents.m
//  Shopper
//
//  Created by andrea sponziello on 18/08/12.
//
//

#import "SHPComponents.h"
#import "SHPBackgroundView.h"
#import "SHPConstants.h"
#import "SHPApplicationSettings.h"
#import <QuartzCore/QuartzCore.h>
#import "SHPImageUtil.h"
#import "SHPApplicationContext.h"

@implementation SHPComponents

//+(UIButton *)MainListLikeButton:(UITableViewCell *)cell {
//    return nil;
//}
+(void)setTrasparentBackground:(UINavigationController *)navigationController
{
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.shadowImage = [UIImage new];
    navigationController.navigationBar.translucent = YES;
}
+(void)customBackButton:(UINavigationController *)navigationController{
    UIImage *faceImage = [UIImage imageNamed:@"buttonArrowLeftOrange.png"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height );
    //[face addTarget:self action:@selector(goToBackStep) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    navigationController.navigationItem.leftBarButtonItem = backButton;
}

+(UIView *)viewByXibName:(NSString *)xibName {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:xibName owner:nil options:nil];
    return [views objectAtIndex:0];
}

+(void)titleLogoForViewController:(UIViewController *)vc {
    // title image
    UIImage *logo = [UIImage imageNamed:@"title-logo"];
    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
    vc.navigationItem.titleView = titleLogo;
}

+(void)customizeTitle:(NSString *)title vc:(UIViewController *)vc {
    if(title == nil){
        NSLog(@"title1 %@", title);
        [self titleLogoForViewController:vc];
         vc.navigationItem.title=nil;
    }else{
        NSLog(@"title2 %@", title);
        vc.navigationItem.title = title;
    }
}

+(void)customizeTitleWithImage:(UIImage *) title_image vc:(UIViewController *) vc{
    UIImage *resized = [SHPImageUtil scaleImage:title_image toSize:CGSizeMake(30, 30)];
    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:resized];
    vc.navigationItem.titleView = titleLogo;
    vc.navigationItem.title = nil;
}

+(UIBarButtonItem *)backButtonWithTarget:(UIViewController *)target settings:(SHPApplicationSettings *)settings {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:target action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
//    UIImage *bgImageNormal = [UIImage imageNamed:@"btn_nav_bar_dark_back_default"];
//    UIImage *bgImagePressed = [UIImage imageNamed:@"btn_nav_bar_dark_back_pressed"];
//    //[bgImageNormal resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)]
//    bgImageNormal =
//    [bgImageNormal stretchableImageWithLeftCapWidth:14.0 topCapHeight:0.0];
//    bgImagePressed =
//    [bgImagePressed stretchableImageWithLeftCapWidth:14.0 topCapHeight:0.0];
    
    UIImage *imageNormal = [SHPImageUtil tintImage:[UIImage imageNamed:@"back-arrow"] withColor:settings.appTitleColor];
    UIImage *imagePressed = [UIImage imageNamed:@"back-arrow-pressed"];
    
//    [backButton setBackgroundImage:bgImageNormal forState:UIControlStateNormal];
//    [backButton setBackgroundImage:bgImagePressed forState:UIControlStateHighlighted];
    [backButton setImage:imageNormal forState:UIControlStateNormal];
    [backButton setImage:imagePressed forState:UIControlStateHighlighted];
    [backButton sizeToFit];
//    backButton.frame = CGRectMake(0, 0, 41, 31);//CGRectMake(0, 0, 43, 31); //CGRectMake(0, 0, 50, 30);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    
    return barButton;
}

+(UIBarButtonItem *)backMagnifyButtonWithTarget:(UIViewController *)target {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton addTarget:target action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *imageNormal = [UIImage imageNamed:@"magnify"];
//    UIImage *imagePressed = [UIImage imageNamed:@"back-arrow-pressed"];
    
    [backButton setImage:imageNormal forState:UIControlStateNormal];
    [backButton sizeToFit];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView: backButton];
    
    return barButton;
}

+(UIView *)sectionHeader {
//    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"ShopSectionHeader" owner:nil options:nil];
//    UIView *view = [views objectAtIndex:0];
    UIView *view = [SHPComponents viewByXibName:@"ShopSectionHeader"];
    CGRect frame = view.frame;
    frame.size.height = 44;
    view.frame = frame;
    CALayer * l = [view layer];
    [l setMasksToBounds:YES];
    [l setBorderWidth:0.5];
    [l setBorderColor:[[UIColor lightGrayColor] CGColor]];
    return view;
}

+(UIView *)userSectionHeaderWithTarget:(UIViewController *)target {
    //    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"ShopSectionHeader" owner:nil options:nil];
    //    UIView *view = [views objectAtIndex:0];
    UIView *view = [SHPComponents viewByXibName:@"UserSectionHeader"];
    
    UIColor *borderColor = [UIColor colorWithRed:217.0/255.0 green:218.0/255.0 blue:221.0/255.0 alpha:1.0];
    UIFont *textFont = [UIFont boldSystemFontOfSize:14];
    
    // liked button
    UIButton *likedButton = (UIButton *)[view viewWithTag:20];
    [likedButton setTitle:NSLocalizedString(@"ProductsLikedButtonLKey", nil) forState: UIControlStateNormal];
    likedButton.titleLabel.font = textFont;
    [likedButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [likedButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [likedButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [likedButton addTarget:target action:@selector(likedListModePressed:) forControlEvents:UIControlEventTouchUpInside];
    CGRect frame = likedButton.frame;
    frame.size.width = 160;
    frame.origin.x = 0;
    likedButton.frame = frame;
    CALayer *l = [likedButton layer];
    [l setMasksToBounds:YES];
    [l setBorderWidth:0.5];
    [l setBorderColor:[borderColor CGColor]];
    
    // created button
    UIButton *createdButton = (UIButton *)[view viewWithTag:10];
    createdButton.titleLabel.font = textFont;
    [createdButton setTitle:NSLocalizedString(@"ProductsCreatedButtonLKey", nil) forState: UIControlStateNormal];
    [createdButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [createdButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [createdButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [createdButton addTarget:target action:@selector(createdListModePressed:) forControlEvents:UIControlEventTouchUpInside];
    l = [createdButton layer];
    frame = createdButton.frame;
    frame.size.width = 160;
    frame.origin.x = 160;
    createdButton.frame = frame;
    [l setMasksToBounds:YES];
    [l setBorderWidth:0.5];
    [l setBorderColor:[borderColor CGColor]];
    
    return view;
}

+(UIView *)searchBarWithTarget:(UIViewController *)target {
    UIView *searchView = [SHPComponents viewByXibName:@"SearchBar"];
//    UIView *buttonsView = [SHPComponents searchButtonsSectionHeaderWithTarget:target];
//    UIView *barView = [searchView viewWithTag:1];
//    CGRect frame = buttonsView.frame;
//    frame.origin.y = barView.frame.size.height;
//    buttonsView.frame = frame;
//    buttonsView.tag = 2;
    
//    [searchView addSubview:buttonsView];
    
    return searchView;
}

+(UIView *)searchButtonsSectionHeaderWithTarget:(UIViewController *)target {
    UIView *view = [SHPComponents viewByXibName:@"SearchButtonsSectionHeader"];
    
    UIColor *borderColor = [UIColor colorWithRed:217.0/255.0 green:218.0/255.0 blue:221.0/255.0 alpha:1.0];
    UIFont *textFont = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
    UIColor *defaultC = [UIColor darkGrayColor];
    UIColor *selectedC = [UIColor blackColor];
    UIColor *highlightedC = [UIColor blackColor];
    
    // products button
    UIButton *productsButton = (UIButton *)[view viewWithTag:10];
    [productsButton setTitle:NSLocalizedString(@"SearchProductsButtonLKey", nil) forState: UIControlStateNormal];
    productsButton.titleLabel.font = textFont;
    [productsButton setTitleColor:defaultC forState:UIControlStateNormal];
    [productsButton setTitleColor:selectedC forState:UIControlStateSelected];
    [productsButton setTitleColor:highlightedC forState:UIControlStateHighlighted];
    [productsButton addTarget:target action:@selector(productsListModePressed:) forControlEvents:UIControlEventTouchUpInside];
//    CGRect frame = productsButton.frame;
//    frame.size.width = 160;
//    frame.origin.x = 0;
//    productsButton.frame = frame;
    CALayer *l = [productsButton layer];
    [l setMasksToBounds:YES];
    [l setBorderWidth:0.5];
    [l setCornerRadius:5.0];
    [l setBorderColor:[borderColor CGColor]];
    
    // shops button
    UIButton *shopsButton = (UIButton *)[view viewWithTag:20];
    shopsButton.titleLabel.font = textFont;
    [shopsButton setTitle:NSLocalizedString(@"SearchShopsButtonLKey", nil) forState: UIControlStateNormal];
    [shopsButton setTitleColor:defaultC forState:UIControlStateNormal];
    [shopsButton setTitleColor:selectedC forState:UIControlStateSelected];
    [shopsButton setTitleColor:highlightedC forState:UIControlStateHighlighted];
    [shopsButton addTarget:target action:@selector(shopsListModePressed:) forControlEvents:UIControlEventTouchUpInside];
    l = [shopsButton layer];
//    frame = shopsButton.frame;
//    frame.size.width = 160;
//    frame.origin.x = 160;
//    shopsButton.frame = frame;
    [l setMasksToBounds:YES];
    [l setBorderWidth:0.5];
    [l setCornerRadius:5.0];
    [l setBorderColor:[borderColor CGColor]];
    
    
//    CALayer *l = [productsButton layer];
//    [l setMasksToBounds:YES];
//    //    [l setBorderColor:[UIColor darkGrayColor].CGColor];
//    //    [l setBorderWidth:1];
//    [l setCornerRadius:5.0];
//    
//    l = [shopsButton layer];
//    [l setMasksToBounds:YES];
//    //    [l setBorderColor:[UIColor darkGrayColor].CGColor];
//    //    [l setBorderWidth:1];
//    [l setCornerRadius:5.0];
//    
//    l = [usersButton layer];
//    [l setMasksToBounds:YES];
//    //    [l setBorderColor:[UIColor darkGrayColor].CGColor];
//    //    [l setBorderWidth:1];
//    [l setCornerRadius:5.0];
    
    
    // users button
    UIButton *usersButton = (UIButton *)[view viewWithTag:30];
    usersButton.titleLabel.font = textFont;
    [usersButton setTitle:NSLocalizedString(@"SearchUsersButtonLKey", nil) forState: UIControlStateNormal];
    [usersButton setTitleColor:defaultC forState:UIControlStateNormal];
    [usersButton setTitleColor:selectedC forState:UIControlStateSelected];
    [usersButton setTitleColor:highlightedC forState:UIControlStateHighlighted];
    [usersButton addTarget:target action:@selector(usersListModePressed:) forControlEvents:UIControlEventTouchUpInside];
    l = [usersButton layer];
//    frame = usersButton.frame;
//    frame.size.width = 160;
//    frame.origin.x = 160;
//    usersButton.frame = frame;
    [l setMasksToBounds:YES];
    [l setBorderWidth:0.5];
    [l setCornerRadius:5.0];
    [l setBorderColor:[borderColor CGColor]];
    
    return view;
}


+(UIView *)gridProductView:(SHPApplicationSettings *)settings withTarget:(NSObject *)target {
    
    UIView *view = [SHPComponents viewByXibName:@"ProductGridCell"];
    view.backgroundColor = settings.mainListBgColor;
    
    UIImageView *imageView = (UIImageView *)[view viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
    CALayer * l = [imageView layer];
    [l setMasksToBounds:YES];
    [l setBorderColor:[UIColor lightGrayColor].CGColor];
    [l setBorderWidth:0.5];
    [l setCornerRadius:5.0];
    
//    imageView.userInteractionEnabled = TRUE;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(tapImage:)];
//    [imageView addGestureRecognizer:tap];
//    [view addSubview:imageView];
    // END IMAGE
    return view;
}

+(float)mainCellHeightForImageSize:(CGSize)imageSize descriptionHeight:(float)descriptionHeight {
    float cellHeight = SHPCONST_MAIN_LIST_PRODUCT_mainCellTopPad + SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerTopPad + imageSize.height + SHPCONST_MAIN_LIST_PRODUCT_mainCellImagePanelDistance + descriptionHeight + SHPCONST_MAIN_LIST_PRODUCT_panelHeight + SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerBottomPad + SHPCONST_MAIN_LIST_PRODUCT_mainCellBottomPad;
    return cellHeight;
}

+(void)adjustCell:(UITableViewCell *)cell forImageSize:(CGSize)imageSize withDescription:(NSString *)description {
    
    UILabel *descriptionLabel = (UILabel *) [cell viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_DESCRIPTION_LABEL_TAG];
    descriptionLabel.text = description;
    descriptionLabel.numberOfLines = 0;
//    NSLog(@"......................>>>> description label %f for: %@", descriptionLabel.frame.size.height, description);
    CGRect descFrame = descriptionLabel.frame;
    descFrame.origin.y = SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerTopPad + imageSize.height + SHPCONST_MAIN_LIST_PRODUCT_mainCellImagePanelDistance;
//    descFrame.size = descriptionLabelSize;
    // reset size forsizeToFit
    // 22, 278
    descFrame.origin.x = 10;
    descFrame.size.width = SHPCONST_MAIN_LIST_DESCRIPTION_WIDTH;
    descFrame.size.height = 0;
    descriptionLabel.frame = descFrame;
    [descriptionLabel sizeToFit];
    
    UIView *bottomPanel = [cell viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_BOTTOM_VIEW_TAG];
    CGRect bottomPanelFrame = bottomPanel.frame;
//    bottomPanelFrame.origin.y = SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerTopPad + imageSize.height + SHPCONST_MAIN_LIST_PRODUCT_mainCellImagePanelDistance;
    bottomPanelFrame.origin.y = descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height;
    bottomPanel.frame = bottomPanelFrame;
    
    UIView *backView = [cell viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_BACK_VIEW_TAG]; // set height
    float backViewHeight = SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerTopPad + imageSize.height + SHPCONST_MAIN_LIST_PRODUCT_mainCellImagePanelDistance + descriptionLabel.frame.size.height + bottomPanel.frame.size.height + SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerBottomPad;
    CGRect backViewFrame = backView.frame;
    backViewFrame.size.height = backViewHeight;
    backView.frame = backViewFrame;
    
    UIView *imageView = [cell viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG]; // set height
    CGRect imageViewFrame = imageView.frame;
    imageViewFrame.size.height = imageSize.height;
    imageViewFrame.size.width = imageSize.width;
    imageViewFrame.origin.x = (backView.frame.size.width - imageSize.width) / 2; // image is in the backView
    imageView.frame = imageViewFrame;
}

+(UITableViewCell *) MainListCell:(SHPApplicationSettings *)settings withTarget:(UIViewController *)target {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SHPCONST_MAIN_LIST_PRODUCT_CELL_ID];
    UIView *contentView = cell.contentView;
    double cellWidth = cell.frame.size.width;
    
    // BACKGROUND VIEW
    float lPad = 5;
    float imageX = 5.5;
    float imageWidth = cellWidth - (imageX + lPad) * 2;
    float imageY = SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerTopPad;
    float imageHeight = 0; // dynamically set
    
    // DESCRIPTION (INITIAL HEIGHT = 0)
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.font = [UIFont systemFontOfSize:14];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.textColor = settings.mainListTextDescriptionColor;
    descriptionLabel.tag = SHPCONST_MAIN_LIST_PRODUCT_DESCRIPTION_LABEL_TAG;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    // CONTROL PANEL
    UIView *bottomPanel = [SHPComponents productCellBottomPanel:settings target:target];
    bottomPanel.backgroundColor = settings.mainListBgCellColor;
    bottomPanel.tag = SHPCONST_MAIN_LIST_PRODUCT_BOTTOM_VIEW_TAG;
    CGRect panelFrame = bottomPanel.frame;
    panelFrame.origin.x = 0;// innerLeftPad;
    panelFrame.origin.y = imageY + imageHeight + SHPCONST_MAIN_LIST_PRODUCT_mainCellImagePanelDistance;
    bottomPanel.frame = panelFrame;
    
    CGRect mainFrame;
    mainFrame.origin.x = lPad;
    mainFrame.origin.y = SHPCONST_MAIN_LIST_PRODUCT_mainCellTopPad; //mainCellTopPad;
    mainFrame.size.height = SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerTopPad + imageHeight + SHPCONST_MAIN_LIST_PRODUCT_mainCellImagePanelDistance + bottomPanel.frame.size.height + SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerBottomPad;
    mainFrame.size.width = cell.frame.size.width - lPad * 2; // - rPad;
    UIView *backView = [[UIView alloc] initWithFrame:mainFrame];
    backView.backgroundColor = settings.mainListBgCellColor;
    backView.tag = SHPCONST_MAIN_LIST_PRODUCT_BACK_VIEW_TAG;
    CALayer * layer = [backView layer];
//    [layer setMasksToBounds:YES];
    [layer setBorderWidth:0.5];
    layer.cornerRadius = 3.0;
    [layer setBorderColor:[[UIColor grayColor] CGColor]];
    
    layer.masksToBounds = NO;
    
//    // shadow
//    layer.shadowOffset = CGSizeMake(0, 1);
//    layer.shadowRadius = 1;
//    layer.shadowOpacity = 0.5;
//    layer.shouldRasterize = YES;
//    [layer setShadowPath:[[UIBezierPath
//                                  bezierPathWithRect:backView.bounds] CGPath]];
//    layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // shadow alternative
//    CGRect shadowFrame = layer.bounds;
//    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
//    layer.shadowPath = shadowPath;
    
    backView.userInteractionEnabled = TRUE;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(tapImage:)];
    [backView addGestureRecognizer:tap];
    
    [contentView addSubview:backView];
    
//    SHPBackgroundView *backView = [[SHPBackgroundView alloc] initWithFrame:mainFrame];
//    backView.tag = SHPCONST_MAIN_LIST_PRODUCT_BACK_VIEW_TAG;
//    [backView setBackgroundColor:settings.mainListBgColor];
//    [backView setRectColor:[UIColor whiteColor]]; //backViewColor];
//    [contentView addSubview:backView];
    
    // IMAGE
    CGRect image_frame;
    image_frame.origin.x = imageX;
    image_frame.origin.y = imageY;
    image_frame.size.width = imageWidth;
    image_frame.size.height = image_frame.size.width;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:image_frame];
    imageView.tag = SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG;
    imageView.frame = image_frame;
//    imageView.contentMode = UIViewContentModeCenter;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    imageView.userInteractionEnabled = TRUE;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(tapImage:)];
//    [imageView addGestureRecognizer:tap];
    // END IMAGE
    
    [backView addSubview:imageView];
    [backView addSubview:descriptionLabel];
    [backView addSubview:bottomPanel];
    
    return cell;
}

+(UILabel *)appTitleLabel:(NSString *)title withSettings:(SHPApplicationSettings *)settings {
    UILabel *navTitleLabel = [[UILabel alloc] init];
    navTitleLabel.text = title;
    navTitleLabel.numberOfLines = 2;
    navTitleLabel.font = [UIFont fontWithName:settings.appTitleFont size:settings.appTitleFontSize];
    //navTitleLabel.font = [UIFont systemFontOfSize:20.0]; // boldSystemFontOfSize
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.shadowColor = [UIColor clearColor]; //[UIColor colorWithWhite:0.0 alpha:0.5];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.textColor = settings.appTitleColor;
    [navTitleLabel sizeToFit];
    return navTitleLabel;
}

+(UIImageView *)appTitleImage:(UIImage *)image {
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    return iv;
}

+(UIView *)productCellBottomPanel:(SHPApplicationSettings *)settings target:(UIViewController *)target {
    UIView *panel = [SHPComponents viewByXibName:@"ProductBigListPanel"];
    
    UIButton *likeButton = (UIButton *) [panel viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_BUTTON_LIKE];
    [likeButton addTarget:target
                action:@selector(cellButtonLikePressed:)
                forControlEvents:UIControlEventTouchUpInside];
    [likeButton setTitle:NSLocalizedString(@"LikeLKey", nil) forState:UIControlStateNormal];
    [likeButton setTitleColor:[UIColor lightGrayColor]
                     forState:UIControlStateNormal];
    [likeButton setTitleColor:[UIColor blackColor]
                     forState:UIControlStateHighlighted];
    [likeButton setTitleColor:[UIColor blackColor]
                     forState:UIControlStateSelected];
    
    panel.backgroundColor = settings.mainListBgCellColor;
    
    UIView *likePanel = [panel viewWithTag:56];
    likePanel.backgroundColor = settings.mainListBgCellColor;
    
    return panel;
}



+(UIView *)productDetailControlPanel:(SHPApplicationSettings *)settings width:(float)width target:(UIViewController *)target {
    
    UIView *panel = [SHPComponents viewByXibName:@"ProductDetailControlPanel"];
    
    // BUTTON LIKE
    UIButton *likeButton = (UIButton *)[panel viewWithTag:SHPCONST_DETAIL_PRODUCT_BUTTON_LIKE];
    [likeButton addTarget:target
                   action:@selector(buttonLikePressed:) forControlEvents:UIControlEventTouchUpInside]; // TouchDown
    [likeButton setTitle:NSLocalizedString(@"LikeLKey", nil) forState:UIControlStateNormal];
    [likeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [likeButton setBackgroundColor:[UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1.0]];
    [likeButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    CALayer * layer = [likeButton layer];
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1.0];
    [layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0])];
    layer.cornerRadius = 5.0;
    [layer setBorderColor:[[UIColor grayColor] CGColor]];
    
    // BUTTON MAP
    UIButton *mapButton = (UIButton *)[panel viewWithTag:31];
    [mapButton addTarget:target
                   action:@selector(mapButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return panel;
}


+(void)setLikeButton:(UIButton *)button withState:(NSString *)state {
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];

    if ([state isEqualToString:SHPCONST_LIKE_COMMAND]) {
//        NSLog(@"to like state");
        [button setTitle:NSLocalizedString(@"LikeLKey", nil) forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"heart_icon_iphone"] forState:UIControlStateNormal];
        
    } else {
//        NSLog(@"to Unlike state");
        [button setTitle:NSLocalizedString(@"UnlikeLKey", nil) forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
//        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
        [button setImage:[UIImage imageNamed:@"heart_red_icon_iphone"] forState:UIControlStateNormal];
    }
}

+(void)setLikeButtonForProductDetail:(UIButton *)button withState:(NSString *)state {
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    if ([state isEqualToString:SHPCONST_LIKE_COMMAND]) {
        [button setTitle:NSLocalizedString(@"LikeLKey", nil) forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    } else {
        [button setTitle:NSLocalizedString(@"UnlikeLKey", nil) forState:UIControlStateNormal];
        
    }
}

//+(UITableViewCell *) MainListMoreResultsCell:(UIColor *)bgColor withTarget:(UIViewController *)target {
+(UITableViewCell *) MainListMoreResultsCell:(UIColor *)bgColor withTarget:(NSObject *)target settings:(SHPApplicationSettings *)settings {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SHPCONST_MAIN_LIST_PRODUCT_LAST_CELL_ID];
    UIView *contentView = cell.contentView;
    NSLog(@"MORE BUTTON PRESSED CELL: CREATED! %@", cell);
    // RELOAD BUTTON
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //float x = (320.0 - 200) / 2;
    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat x = (contentView.frame.size.width - 200) / 2;
    button.frame = CGRectMake(x, 0, 200, 30);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
//    [button setTitleColor:[UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:152.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:settings.moreResultsButtonColor forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor colorWithRed:29.0/255.0 green:39.0/255.0 blue:22.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleColor:settings.moreResultsButtonHighlighted forState:UIControlStateHighlighted];
    
    button.tag = 10;
    [button setTitle:NSLocalizedString(@"MoreResultsLKey", nil) forState:UIControlStateNormal];
//    NSLog(@"ADDING TARGET: MORE BUTTONPRESSED!!!!! TO %@", target);
    [button addTarget:target action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:button];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect frame = spinner.frame;
    frame.origin.x = contentView.frame.size.width / 2 - frame.size.width / 2;
    frame.origin.y = contentView.frame.size.height / 2 - frame.size.height / 2;
    spinner.frame = frame;
    spinner.tag = 20;
    spinner.hidden = YES;
    [contentView addSubview:spinner];
    
    UIImage *endResultsSymbol = [UIImage imageNamed:@"end-list-symbol"];
    UIImageView *endResultsView = [[UIImageView alloc] initWithImage:endResultsSymbol];
    endResultsView.center = contentView.center;
    endResultsView.hidden = YES;
    endResultsView.tag = 40;
    [contentView addSubview:endResultsView];
    
    NSLog(@"MORE BUTTON PRESSED CELL: CREATED! %@", cell);
    return cell;
}

+(void)updateMoreButtonCell:(UITableViewCell *)cell noMoreData:(BOOL)noMoreData isLoadingData:(BOOL)isLoadingData {
    if (!cell) {
        return;
    }
    UIButton *button = (UIButton *)[cell viewWithTag:10];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:20];
    UIImageView *endSym = (UIImageView *)[cell viewWithTag:40];
    if (isLoadingData) {
        button.hidden = YES;
        spinner.hidden = NO;
        endSym.hidden = YES;
        [spinner startAnimating];
    } else {
        button.hidden = NO;
        spinner.hidden = YES;
        endSym.hidden = YES;
        [spinner stopAnimating];
        if (noMoreData) {
            //            [button setTitle:NSLocalizedString(@"NoMoreResultsLKey", nil) forState:UIControlStateNormal];
            //            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            //            button.enabled = NO;
            endSym.hidden = NO;
            button.hidden = YES;
            spinner.hidden = YES;
        } else {
            [button setTitle:NSLocalizedString(@"MoreResultsLKey", nil) forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//            59,89,152.0,1.0
            UIColor *moreResultsButtonColor = [UIColor colorWithRed:59.0/255.0 green:89.0/255.0 blue:152.0/255.0 alpha:1.0];
            [button setTitleColor:moreResultsButtonColor forState:UIControlStateNormal];
            button.enabled = YES;
        }
    }
}

+(UIView *) closeImageDetailControllerButton:(NSObject *)target {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitle:@"blablabla" forState:UIControlStateNormal];
    // NSLocalizedString(@"ShowMenuButtonLKey", nil)
    
    [button addTarget:target action:@selector(closeImageControllerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor whiteColor]];
    // [button setBackgroundColor:[UIColor clearColor]];
    [button sizeToFit];
    
    //    [button setImage: [UIImage imageNamed:@"button_navi_menu_normal"] forState:UIControlStateNormal];
    //    [button setImage: [UIImage imageNamed:@"button_navi_menu_highlight"] forState:UIControlStateHighlighted];
    // the containerView is only to remove borders from the icon :D
//    button.frame = CGRectMake(-2, -2, 56, 30);
//    CGRect containerFrame = button.frame;
//    
//    containerFrame.origin.x = 20;
//    containerFrame.origin.y = 10;
//    containerFrame.size.width = button.frame.size.width - 4;
//    containerFrame.size.height = button.frame.size.height - 4;
//    UIView *container = [[UIView alloc] initWithFrame:containerFrame];
//    [container addSubview:button];
//    //    NSLog(@"frame ............. %f %f", button.frame.size.width, button.frame.size.height);
//    
//    CALayer * l = [container layer];
//    [l setMasksToBounds:YES];
//    [l setBorderWidth:0.0];
//    //    [l setBorderColor:[[UIColor whiteColor] CGColor]];
//    [l setCornerRadius:4.0];
//    
//    return container;
    
    return button;
}

+(UIView *) MainListShowMenuButton:(NSObject *)target settings:(SHPApplicationSettings *)settings {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(20, 10, 56, 30);
    button.frame = CGRectMake(-2, -2, 56, 30);
    
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
//    [button setTitleColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0] forState:UIControlStateNormal];
//    [button setTitle:NSLocalizedString(@"ShowMenuButtonLKey", nil) forState:UIControlStateNormal];
    
    [button setImage: [UIImage imageNamed:@"button_navi_menu_normal"] forState:UIControlStateNormal];
    [button setImage: [UIImage imageNamed:@"button_navi_menu_highlight"] forState:UIControlStateHighlighted];
    
    [button addTarget:target action:@selector(showMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [button setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    [button setBackgroundColor:[UIColor clearColor]];
    [button sizeToFit];
    
    // the containerView is only to remove borders from the icon :D
    CGRect containerFrame = button.frame;
    
    containerFrame.origin.x = 20;
    containerFrame.origin.y = 10;
    containerFrame.size.width = button.frame.size.width - 4;
    containerFrame.size.height = button.frame.size.height - 4;
    UIView *container = [[UIView alloc] initWithFrame:containerFrame];
    [container addSubview:button];
//    NSLog(@"frame ............. %f %f", button.frame.size.width, button.frame.size.height);
    
    CALayer * l = [container layer];
    [l setMasksToBounds:YES];
    [l setBorderWidth:0.0];
//    [l setBorderColor:[[UIColor whiteColor] CGColor]];
    [l setCornerRadius:4.0];

    return container;
}

+(float)centerX:(float)containerWidth contentWidth:(float)contentWidth {
    float xPos = (containerWidth - contentWidth) / 2;
    return xPos;
}

+(float)centerY:(float)containerHeight contentHeight:(float)contentHeight {
    float yPos = (containerHeight - contentHeight) / 2;
    return yPos;
}

+(void)adjustLabel:(UILabel *)label forText:(NSString *)text maxWidth:(float)maxWidth {
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(maxWidth,9999);
    
    CGSize expectedLabelSize = [text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    newFrame.size.width = expectedLabelSize.width;
    label.frame = newFrame;
}

//Calculate the expected size based on the font and linebreak mode of your label
+(void)adjustLabel:(UILabel *)label forText:(NSString *)text {
    [SHPComponents adjustLabel:label forText:text maxWidth:296];
}

+(void)centerView:(UIView *)view inView:(UIView *)containerView {
    // ex. [SHPComponents centerView:titleLabel inContainerView:self.navigationController.navigationBar];
    float x_pos = [SHPComponents centerX:containerView.frame.size.width contentWidth:view.frame.size.width];
    float y_pos = [SHPComponents centerY:containerView.frame.size.height contentHeight:view.frame.size.height];
    view.frame = CGRectMake(x_pos, y_pos, view.frame.size.width, view.frame.size.height);
}

+(UIBarButtonItem *)positionInfoButton:(UIViewController *)target {
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoButton addTarget:target action:@selector(infoAction:) forControlEvents:UIControlEventTouchUpInside];
    //    UIImage *imageNormal = [UIImage imageNamed:@"info-navbar"];
    //    [infoButton setImage:imageNormal forState:UIControlStateNormal];
    CGRect frame = infoButton.frame;
    frame.size.height = 40.0;
    frame.size.width = 80.0;
    infoButton.frame = frame;
    [infoButton setTitle:@"" forState:UIControlStateNormal];
    infoButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [infoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [infoButton sizeToFit];
    
    UIImage *imageNormal = [UIImage imageNamed:@"location_icon_pin"];
//    imageNormal = [imageNormal resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 0.0, 30.0, 18.0)];
    [infoButton setImage:imageNormal forState:UIControlStateNormal];
    [infoButton setImageEdgeInsets:UIEdgeInsetsMake(0, -4.0, 0.0, 0)];
//    [infoButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 20.0, 0, 10.0)];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView: infoButton];
    return  barButton;
//    [self.navigationItem setRightBarButtonItem:barButton];
}


+(NSDictionary *)getConfigValueFromWizardPlist:(SHPApplicationContext *)applicationContext typeSelected:(NSString *)typeSelected{
    NSDictionary *plistDictionary = (NSDictionary *)[applicationContext getVariable:@"PLIST_WIZARD"];
    NSDictionary *typesDictionary = [plistDictionary objectForKey:@"types"];
    NSDictionary *typeDictionary = [typesDictionary valueForKey:typeSelected];
    return typeDictionary;
}

// plist reader
+(NSDictionary *)getDictionaryFromPlist:(SHPApplicationContext *)applicationContext arrayNames:(NSArray *)arrayNames{
    NSDictionary *viewDictionary = applicationContext.plistDictionary;
    for (NSString *result in arrayNames) {
        viewDictionary = (NSDictionary *)[viewDictionary objectForKey:result];
    }
    return viewDictionary;
}

+(NSDictionary *)mergeDictionaries:(NSDictionary *)first second:(NSDictionary *)second
{
    NSMutableDictionary *ret = [first mutableCopy];
    [ret addEntriesFromDictionary:second];
    return ret;
}

//+(void)trackerGoogleAnalytics:(NSString *)className{
//    //NSString *className = NSStringFromClass([self class]);
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:className];
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
//}

@end
