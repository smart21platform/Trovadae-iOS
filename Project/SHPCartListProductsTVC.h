//
//  SHPCartListProductsTVC.h
//  Eurofood
//
//  Created by Dario De Pascalis on 02/07/14.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@class SHPCart;

@interface SHPCartListProductsTVC : UITableViewController{
    NSInteger nItems;
    float totalPrice;
    SHPCart *carrello;
}
@property (weak, nonatomic) IBOutlet UILabel *labelTotalCart;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@end
