//
//  SHPWizardSelectCategory.m
//  Mercatino
//
//  Created by Dario De Pascalis on 19/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "SHPWizardSelectCategory.h"
#import "SHPComponents.h"
#import "SHPApplicationContext.h"
#import "SHPConstants.h"
#import "SHPCategory.h"
#import "SHPImageUtil.h"
#import "SHPCaching.h"
#import "SHPImageRequest.h"
#import "SHPWizardLandingPageTVC.h"

@interface SHPWizardSelectCategory ()

@end

@implementation SHPWizardSelectCategory

- (void)viewDidLoad
{
    [super viewDidLoad];
    // SET TITLE NAV BAR
    NSLog(@"\n viewDidLoad");
    [self customBackButton];
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize{
    cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    NSLog(@"initialize cat: %@", cachedCategories);
    NSString *labelType = [[NSString alloc] initWithFormat:@"header-step2-categories-%@", typeSelected];
    //NSString *textHeader = NSLocalizedString(labelType, nil);
}

-(void)customBackButton{
//    UIImage *faceImage = [UIImage imageNamed:@"buttonArrow.png"];
//    CGFloat angle = 180;
//    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
//    face.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height );
//    [face setImage:faceImage forState:UIControlStateNormal];
//    face.transform = CGAffineTransformMakeRotation(angle*M_PI/180);
//    if(self.backActionClose == YES){
//        [face addTarget:self action:@selector(goToClose) forControlEvents:UIControlEventTouchUpInside];
//    }else{
//        [face addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
//    }
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
//    self.navigationItem.leftBarButtonItem = backButton;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    return cachedCategories.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *shopCellId = @"CategoryCell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:shopCellId];
    NSInteger catIndex = indexPath.row;
    SHPCategory *cat = [cachedCategories objectAtIndex:catIndex];
    NSLog(@"\n cat: ....... %@", cat);
    UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
    textLabel.text = [cat localName];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:20];
    [SHPImageUtil customIcon:iconView];
    NSString *categoryIconURL = [cat iconURL];
    NSLog(@"....... %@", categoryIconURL);
    
    //REGOLE UPLOAD IMAGES CATEGORIES:
    // 1- carico image dalla cache se presente in cache
    // SALTO 2- carico image dal disco se salvata in memoria e aggiungo alla cache
    // 3- mostro immagine cache se è presente e poi carico image, salvo su disco e aggiungo alla cache
    // 4- carico image di default
    
    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
    UIImage *archiveIcon = [SHPCaching restoreImage:categoryIconURL];
    if (cacheIcon) {
        iconView.image = cacheIcon;
    }
    //else if (staticIcon) {
    //NSLog(@"staticIcon");
    //iconView.image = staticIcon;
    //}
    else {
        if (archiveIcon) {
            NSLog(@"archiveIcon");
            iconView.image = archiveIcon;
        }
        //iconView.image = nil;
        SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
        [imageRquest downloadImage:categoryIconURL
                 completionHandler:
         ^(UIImage *image, NSString *imageURL, NSError *error) {
             if (image) {
                 //save on disk
                 [SHPCaching saveImage:image inFile:imageURL];
                 //save in cache
                 [self.applicationContext.categoryIconsCache addImage:image withKey:imageURL];
                 NSArray *indexes = [self.tableView indexPathsForVisibleRows];
                 for (NSIndexPath *index in indexes) {
                     if (index.row == indexPath.row) {
                         UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
                         UIImageView *iconV= (UIImageView *)[cell viewWithTag:20];
                         iconV.image = image;
                     }
                 }
             } else {
                 UIImage *icon = [UIImage imageNamed:@"category_icon__default"];
                 iconView.image = icon;
                 [self.applicationContext.categoryIconsCache addImage:icon withKey:imageURL];
             }
         }];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger catIndex = indexPath.row;
    self.selectedCategory = [cachedCategories objectAtIndex:catIndex];
    [self performSegueWithIdentifier: @"unwindToWizardLandingPageTVC" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"unwindToWizardLandingPageTVC"]) {
        SHPWizardLandingPageTVC *vc = [segue destinationViewController];
        vc.selectedCategory = self.selectedCategory;
    }
}



@end
