//
//  SHPConstants.m
//  Shopper
//
//  Created by andrea sponziello on 19/08/12.
//
//

#import "SHPConstants.h"

NSString *SHPCONST_MAIN_LIST_PRODUCT_CELL_ID = @"ProductPreviewCell";
NSString *SHPCONST_MAIN_LIST_GROUPON_CELL_PRICE_ID = @"GrouponCellPrice";
NSString *SHPCONST_MAIN_LIST_GROUPON_CELL_PRICE_FULL_ID = @"GrouponCellPriceFull";
NSString *SHPCONST_MAIN_LIST_GROUPON_CELL_LIKE_ID = @"GrouponCellLike";
NSString *SHPCONST_MAIN_LIST_FANCY_CELL_ID = @"FancyCell";
NSString *SHPCONST_MAIN_LIST_PRODUCT_LAST_CELL_ID = @"LastCell";
NSString *SHPCONST_GRID_CELL_ID = @"GridCell";

// main list cell measures
NSInteger SHPCONST_MAIN_LIST_PRODUCT_CELL_HEIGHT = 368;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_mainCellTopPad = 5;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_mainCellBottomPad = 5;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_mainCellImagePanelDistance = 8;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerTopPad = 5;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_mainCellInnerBottomPad = 1;
float SHPCONST_MAIN_LIST_PRODUCT_panelHeight = 93; // 74
float SHPCONST_MAIN_LIST_DESCRIPTION_WIDTH = 300;

NSInteger SHPCONST_MAIN_LIST_PRODUCT_DESCRIPTION_LABEL_TAG = 10;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_SHOP_LABEL_TAG = 20;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_DISTANCE_LABEL_TAG = 30;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_BUTTON_LIKE = 40;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_BUTTON_COMMENTS_TAG = 50;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_BACK_VIEW_TAG = 60;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG = 70;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_BOTTOM_VIEW_TAG = 80;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_LIKESCOUNT_VIEW_TAG = 90;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_USERIMAGE_VIEW_TAG = 100;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_USERNAME_VIEW_TAG = 110;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_CITY_VIEW_TAG = 111;
NSInteger SHPCONST_MAIN_LIST_PRODUCT_SPONSORED_VIEW_TAG = 112;
// INIZIO/FINE, CAT


NSInteger SHPCONST_DETAIL_PRODUCT_IMAGE_VIEW_TAG = 10;
NSInteger SHPCONST_DETAIL_PRODUCT_IMAGE_PROGRESS_BAR_TAG = 20;
NSInteger SHPCONST_DETAIL_PRODUCT_BUTTON_LIKE = 30;
NSInteger SHPCONST_DETAIL_PRODUCT_BUTTON_SHOP_TAG = 40;
NSInteger SHPCONST_DETAIL_PRODUCT_DESCRIPTION_LABEL_TAG= 50;

NSInteger SHPCONST_SHOP_DETAIL_gridViewWidth = 150;
NSInteger SHPCONST_SHOP_DETAIL_gridViewHeight = 155;
NSInteger SHPCONST_SHOP_DETAIL_gridImageWidth = 140;
NSInteger SHPCONST_SHOP_DETAIL_gridImageHeight = 116;

NSInteger SHPCONST_USER_ICON_WIDTH = 320;
NSInteger SHPCONST_USER_ICON_HEIGHT = 320;

NSString *SHPCONST_USERNAME = @"username";
NSString *SHPCONST_LIKE_COMMAND = @"like";
NSString *SHPCONST_UNLIKE_COMMAND = @"unlike";
NSString *SHPCONST_LAST_DATA_FILE_NAME = @"shopperLastDataFileName";
NSString *SHPCONST_POST_FORM_BOUNDARY = @"theShopperServiceFormBoundary";

NSInteger ERROR_USERNAME_USED = 100;
NSInteger ERROR_HTTP_USERNAME_USED = 409;
NSInteger ERROR_HTTP_EMAIL_USED = 410;
NSInteger ERROR_HTTP_USERNAME_INVALID = 406;

NSInteger SHPCONST_MAX_RECENTLY_USED_SHOPS = 3;

// add wizard
NSString *WIZARD_DICTIONARY_KEY = @"wizardDictionary";

NSString *WIZARD_STEP_CATEGORY_TOP_MESSAGE_KEY = @"category-step-start";
NSString *WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY = @"photo-step-top-message";
NSString *WIZARD_STEP_DESCRIPTION_TOP_MESSAGE_KEY = @"description-step-top-message";
NSString *WIZARD_STEP_TITLE_TOP_MESSAGE_KEY = @"title-step-top-message";
NSString *WIZARD_STEP_DATE_TOP_MESSAGE_KEY = @"date-step-top-message";
NSString *WIZARD_STEP_PRICE_TOP_MESSAGE_KEY = @"price-step-top-message";
NSString *WIZARD_STEP_POI_TOP_MESSAGE_KEY = @"poi-step-top-message";

NSString *WIZARD_STEP_PHOTO_HINT_MESSAGE_KEY = @"photo-step-hint-message";
NSString *WIZARD_STEP_DESCRIPTION_HINT_MESSAGE_KEY = @"description-step-hint-message";
NSString *WIZARD_STEP_TITLE_HINT_MESSAGE_KEY = @"title-step-hint-message";

NSString *WIZARD_STEP_DATE_HINT_MESSAGE_KEY = @"date-step-hint-message";
NSString *WIZARD_STEP_PRICE_HINT_MESSAGE_KEY = @"price-step-hint-message";
NSString *WIZARD_STEP_POI_HINT_MESSAGE_KEY = @"poi-step-hint-message";

NSString *WIZARD_STEP_DESCRIPTION_EXAMPLE_MESSAGE_KEY = @"description-step-example-message";
NSString *WIZARD_STEP_TITLE_EXAMPLE_MESSAGE_KEY = @"title-step-example-message";


NSString *WIZARD_PRODUCT_ID_KEY = @"product_id";
NSString *WIZARD_DESCRIPTION_KEY = @"description";
NSString *WIZARD_TELEPHONE_KEY = @"telephone";
NSString *WIZARD_EMAIL_KEY = @"email";
NSString *WIZARD_TITLE_KEY = @"title";
NSString *WIZARD_IMAGE_KEY = @"image";
NSString *WIZARD_DATE_START_KEY = @"date-start";
NSString *WIZARD_DATE_END_KEY = @"date-end";
NSString *WIZARD_POI_KEY = @"poi";
NSString *WIZARD_TYPE_KEY = @"type";
NSString *WIZARD_CATEGORY_KEY = @"category";
NSString *WIZARD_ICON_CATEGORY_KEY = @"icon_category";
NSString *WIZARD_PRICE_KEY = @"price";
NSString *WIZARD_START_PRICE_KEY = @"startprice";
NSString *WIZARD_PERCENT_KEY = @"percent_price";
NSString *WIZARD_EDIT_MODE_KEY = @"edit_mode";

int TAB_HOME_INDEX = 0;//0 se la home è al primo posto
int TAB_SEARCH_INDEX = 1;
//int TAB_NOTIFICATIONS_INDEX = 2;
int TAB_MENU_INDEX = 4;

int MAX_CHARACTERS_TITLE = 50;
int MIN_CHARACTERS_TITLE = 5;

int MIN_CHARACTERS_DESCRIPTION = 5;
//types of category
NSString *CATEGORY_TYPE_DEAL = @"deal";
NSString *CATEGORY_TYPE_COVER = @"cover";
NSString *CATEGORY_TYPE_PHOTO = @"photo";
NSString *CATEGORY_TYPE_EVENT = @"event";
NSString *CATEGORY_TYPE_MENU = @"menu";

//preloadCategories
NSString *LAST_LOADED_CATEGORIES = @"lastLoadedCategories";
NSString *LAST_SELECTED_CATEGORY_KEY = @"mainListSelectedCategory";
NSString *DICTIONARY_CATEGORIES = @"dictionaryCategories";
NSString *CATEGORY_VISIBILITY_SEARCH = @"categoryVisibilitySearch";
NSString *CATEGORY_VISIBILITY_WIZARD = @"categoryVisibilityWizard";



@implementation SHPConstants

@end
