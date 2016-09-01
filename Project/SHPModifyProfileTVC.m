//
//  SHPModifyProfileTVC.m
//  Mercatino
//
//  Created by Dario De Pascalis on 26/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "SHPModifyProfileTVC.h"
#import "SHPUser.h"
#import "SHPApplicationContext.h"
#import "MBProgressHUD.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"
#import "SHPConstants.h"
#import "SHPImageUtil.h"
#import "SHPHomeProfileTVC.h"


//int MIN_CHARS_PASSWORD = 6;

@interface SHPModifyProfileTVC ()

@end

@implementation SHPModifyProfileTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize
{
    NSString *headerMessage = [[NSString alloc] init];
    if([self.modifyType isEqualToString:@"fullName"]){
        headerMessage =  NSLocalizedStringFromTable(@"Inserisci un nome utente valido", @"CZ-Profile", @"");
        self.textFullName.placeholder = self.user.fullName;
    }
    else{
        headerMessage =  NSLocalizedStringFromTable(@"Inserisci una password valida di almeno 8 caratteri", @"CZ-Profile", @"");
    }
    self.labelHeaderMessage.text =  headerMessage;
    updateUserDC = [[SHPModifyProfileDC alloc] init];
    updateUserDC.delegate = self;
}



//----------------------------------------------------------------//
//START FUNCTION VIEW
//----------------------------------------------------------------//
-(void)savePassword:(NSString *)password {
    NSLog(@"*************** SAVE PASSWORD: %@ ***************",password);
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setObject:password forKey:@"PASSWORD"];
    [userPreferences synchronize];
}

-(void)showAlertMessageError:(NSString *)title msg:(NSString *)msg{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


-(void)showWaiting:(NSString *)label {
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [self.view.window addSubview:hud];
    }
    hud.center = self.view.center;
    hud.labelText = label;
    hud.animationType = MBProgressHUDAnimationZoom;
    [hud show:YES];
}

-(void)hideWaiting {
    [hud hide:YES];
}
//----------------------------------------------------------------//
//END FUNCTION VIEW
//----------------------------------------------------------------//

//****************************************************************//
// START DELEGATE updateUserDC
//****************************************************************//
-(void)userUpdated:(SHPModifyProfileDC *)dc error:(NSError *)error{
    NSLog(@"******** userUpdated ERROR %@", error);
    if(newPassword && newPassword.length>0)[self savePassword:newPassword];
    [self performSegueWithIdentifier:@"unwindToHomeProfileTVC" sender:self];
}

//****************************************************************//
// END DELEGATE updateUserDC
//****************************************************************//


//----------------------------------------------------------------//
//START BUILD TABLEVIEW
//----------------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([self.modifyType isEqualToString:@"fullName"] && section == 0){
        return NSLocalizedStringFromTable(@"MODIFICA NOME UTENTE", @"CZ-Profile", @"");
    }
    else if([self.modifyType isEqualToString:@"password"] && section == 1){
       return NSLocalizedStringFromTable(@"MODIFICA PASSWORD", @"CZ-Profile", @"");
    }
    return @"";
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([self.modifyType isEqualToString:@"fullName"] && section == 0){
        return 40;
    }
    else if([self.modifyType isEqualToString:@"password"] && section == 1){
        return 40;
    }
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.modifyType isEqualToString:@"password"] && section == 0){
        return 0;
    }
    else if([self.modifyType isEqualToString:@"fullName"] && section == 0){
        return 2;
    }
    else if([self.modifyType isEqualToString:@"password"] && section == 1){
        return 4;
    }
    else if([self.modifyType isEqualToString:@"fullName"] && section == 1){
        return 0;
    }
    return 0;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"unwindToHomeProfileTVC"]) {
        SHPHomeProfileTVC *vc = (SHPHomeProfileTVC *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.user = self.user;
    }
}


- (IBAction)actionSavePassword:(id)sender
{
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSString *password = [userPreferences valueForKey:@"PASSWORD"];
    NSString *error;
    NSLog(@"\n password : %@",password);
    if(![self.textPasswordOld.text isEqualToString:password]){
        error = NSLocalizedStringFromTable(@"La password inserita non è esatta", @"CZ-Profile", @"");
        [self showAlertMessageError:nil msg:error];
    }
    else if(![self.textPasswordNew.text isEqualToString:self.textPasswordNewConfirm.text]){
        error = NSLocalizedStringFromTable(@"Le password inserite non coincidono", @"CZ-Profile", @"");
        [self showAlertMessageError:nil msg:error];
    }
    else if(self.textPasswordNew.text.length<MIN_CHARS_PASSWORD){
        error = [NSString stringWithFormat:NSLocalizedStringFromTable(@"La password inserita deve essere di almeno %d caratteri", @"CZ-Profile", @""), MIN_CHARS_PASSWORD];
        [self showAlertMessageError:nil msg:error];
    }
    else{
         newPassword = [self.textPasswordNew.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        updateUserDC.nwPassword = newPassword;
        updateUserDC.oldPassword = password;
        [updateUserDC updateUserPassword:self.user];
    }
}

- (IBAction)actionSaveFullName:(id)sender {
    self.user.fullName = self.textFullName.text;
    [updateUserDC updateUserName:self.user];
}
@end

