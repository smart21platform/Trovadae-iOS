//
//  SHPInfoFirstLoadVC.h
//  Anima e Cuore
//
//  Created by dario de pascalis on 02/12/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class SHPApplicationContext;

@interface SHPInfoFirstLoadVC : UIViewController<CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;

@property (weak, nonatomic) IBOutlet UIImageView *iconLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelTitleInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelTextInfo;
@property (weak, nonatomic) IBOutlet UIButton *labelButtonContinue;
@property (weak, nonatomic) IBOutlet UIImageView *imageBackground;

- (IBAction)actionButtonContinue:(id)sender;
@end
