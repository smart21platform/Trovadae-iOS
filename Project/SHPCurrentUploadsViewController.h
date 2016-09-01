//
//  SHPCurrentUploadsViewController.h
//  Dressique
//
//  Created by andrea sponziello on 05/02/13.
//
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;
@class SHPDataController;
@class SHPProductUploaderDC;

@interface SHPCurrentUploadsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSTimer *stateUpdateTimer;
@property (strong, nonatomic) SHPProductUploaderDC *selectedDataController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)closeAction:(id)sender;

@end
