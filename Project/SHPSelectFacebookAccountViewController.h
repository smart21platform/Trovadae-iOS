//
//  SHPSelectFacebookAccountViewController.h
//  Ciaotrip
//
//  Created by andrea sponziello on 06/02/14.
//
//

#import <UIKit/UIKit.h>

@class SHPFacebookPage;
@class SHPApplicationContext;

@interface SHPSelectFacebookAccountViewController : UITableViewController

@property(strong, nonatomic) SHPApplicationContext *applicationContext;
@property(strong, nonatomic) SHPFacebookPage *selectedPage;
@property(strong, nonatomic) NSArray *pages;
@property(assign, nonatomic) BOOL loadError;

@end
