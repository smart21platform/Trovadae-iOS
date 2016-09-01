//
//  SHPNoAuthenticatedViewController.h
//  Ciaotrip
//
//  Created by Dario De Pascalis on 27/01/14.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@interface SHPNoAuthenticatedViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *msgNoAuthenticated;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;

@end
