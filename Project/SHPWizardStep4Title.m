//
//  SHPWizardStep4Title.m
//  Galatina
//
//  Created by dario de pascalis on 17/02/15.
//
//

#import "SHPWizardStep4Title.h"
#import "SHPApplicationContext.h"
#import "SHPConstants.h"
#import "SHPCategory.h"
#import "SHPComponents.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPImageUtil.h"
#import "SHPWizardStep5Poi.h"
#import "SHPWizardStepFinal.h"

@interface SHPWizardStep4Title ()
@end

@implementation SHPWizardStep4Title

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
}

-(void)initialize{
    [self getTypeAndCategory];
    typeDictionary = [SHPComponents getConfigValueFromWizardPlist:self.applicationContext typeSelected:typeSelected];
    
    // init description text field
    self.titleTextView.delegate = self;
    kPlaceholderTitle = NSLocalizedString(@"UserStoryTitlePlaceholderLKey", nil);
    self.minimumWordsMessageLabel.text = NSLocalizedString(@"minimumWordsForTitle", nil);
    [self resetPostMessage];
    
    // SET TITLE NAV BAR
    UIImage *title_image;
    NSString *categoryIconURL = [self.selectedCategory iconURL];
    NSLog(@".......cat URL %@", categoryIconURL);
    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
    UIImage *staticIcon = [self.selectedCategory getStaticIconFromDisk];
    if (cacheIcon) {
        title_image = cacheIcon;
    }
    else if (staticIcon) {
        title_image = staticIcon;
    }
    [SHPComponents customizeTitleWithImage:title_image vc:self];
    
    // Show placeholder text
    [self basicSetup];
    [self customSetup];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *trackerName = [[NSString alloc] initWithFormat:@"WizardStepTitle type:%@ category:%@", typeSelected, self.selectedCategory.label];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}

-(void)getTypeAndCategory{
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.selectedCategory = (SHPCategory *) [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
}

-(void)basicSetup {
    // dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;// without this, tap on buttons is captured by the view
    [self.view addGestureRecognizer:tap];
    
    NSLog(@"addGestureRecognizer");
    // init next button
    self.nextButton.title = NSLocalizedString(@"wizardNextButton", nil);
    [self.buttonCellNext setTitle:NSLocalizedString(@"wizardNextButton", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonCellNext layer]];
    
    //NSLog(@"WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY %@", [self.wizardDictionary objectForKey:WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY]);
    NSLog(@"topMessageLabel %@", self.topMessageLabel);
    NSString *headerLabel = [[NSString alloc] initWithFormat:@"header-step4-title-%@", typeSelected];
    NSString *hintLabel = [[NSString alloc] initWithFormat:@"hint-step4-title-%@", typeSelected];
    NSString *textHeader = NSLocalizedString(headerLabel, nil);
    NSString *textHint = NSLocalizedString(hintLabel, nil);
    
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHeader toAttributedLabel:self.topMessageLabel];
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHint  toAttributedLabel:self.hintLabel];
    NSLog(@"topMessageLabel %@", self.topMessageLabel);
}

-(void)customSetup {
    NSString *trimmedTitle = [[self.wizardDictionary objectForKey:WIZARD_TITLE_KEY] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedTitle) {
        self.titleTextView.text = trimmedTitle;
        self.titleTextView.textColor = [UIColor blackColor];
    }
    [self validateForm];
}


-(void)dismissKeyboard {
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}

- (void) displayViewController: (UIViewController*) controller;
{
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)resetPostMessage
{
    self.titleTextView.text = kPlaceholderTitle;
    self.titleTextView.textColor = [UIColor lightGrayColor];
//    self.descriptionTextView.text = kPlaceholderDescription;
//    self.descriptionTextView.textColor = [UIColor lightGrayColor];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"Begin...");
    // Clear the message text when the user starts editing
    if ([textView.text isEqualToString:kPlaceholderTitle]) {//|| [textView.text isEqualToString:kPlaceholderDescription]
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"End...");
    // Reset to placeholder text if the user is done
    // editing and no message has been entered.
    if ([textView.text isEqualToString:@""]) {
        [self resetPostMessage];
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    NSLog(@"TEXT CHANGED %@", textView.text);
    [self validateForm];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string{
    NSLog(@"shouldChangeCharactersInRange");
    NSUInteger newLength = [textView.text length] + [string length] - range.length;
    return (newLength > MAX_CHARACTERS_TITLE) ? NO : YES;
}

-(void)validateForm {
    NSLog(@"validateForm");
    NSString *trimmedTitle = [self.titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSUInteger characterCount = [trimmedTitle length];
    BOOL valid = true;
    if([trimmedTitle isEqualToString:@""]){
        //[self resetPostMessage];
        self.minimumWordsMessageLabel.hidden = NO;
        valid = false;
        //self.nextButton.enabled = NO;
    }else if([trimmedTitle isEqualToString:kPlaceholderTitle] || characterCount < MIN_CHARACTERS_TITLE) {
        //NSLog(@"INVALID");
        self.minimumWordsMessageLabel.hidden = NO;
        valid = false;
        //self.nextButton.enabled = NO;
    } else {
        //NSLog(@"VALID!");
        self.minimumWordsMessageLabel.hidden = YES;
        valid = true;
        //self.nextButton.enabled = YES;
    }
    
    NSString *checkType = [typeDictionary valueForKey:@"title"];
    NSLog(@"checkType: %@ - valid:%d",checkType, valid);
    if([checkType isEqualToString:@"2"]){
        if(valid == false){
            self.nextButton.enabled = NO;
            self.buttonCellNext.enabled = NO;
            self.buttonCellNext.alpha = 0.5;
        }else{
            self.nextButton.enabled = YES;
            self.buttonCellNext.enabled = YES;
            self.buttonCellNext.alpha = 1;
        }
    }else{
        self.nextButton.enabled = YES;
        self.buttonCellNext.enabled = YES;
        self.buttonCellNext.alpha = 1;
    }

    //NSLog(@"validateForm %@", trimmedTitle);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exampleAction:(id)sender {
    NSString *exampleLabel = [[NSString alloc] initWithFormat:@"example-step4-title-%@", typeSelected];
    NSString *example = NSLocalizedString(exampleLabel, nil);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Esempio" message:example delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


-(void)selectSegue
{
    NSLog(@"typeDictionary %@ - %@",typeDictionary, typeSelected);
//    if(![[typeDictionary valueForKey:@"title"] isEqualToString:@"0"]){
//        [self performSegueWithIdentifier:@"toStepTitle" sender:self];
//    }else
    if(![[typeDictionary valueForKey:@"poi"] isEqualToString:@"0"]){
        [self performSegueWithIdentifier:@"toStepPOI" sender:self];
    }
//    else if(![[typeDictionary valueForKey:@"date"] isEqualToString:@"0"]){
//        [self performSegueWithIdentifier:@"toStepDate" sender:self];
//    }else if(![[typeDictionary valueForKey:@"price"] isEqualToString:@"0"]){
//        [self performSegueWithIdentifier:@"toStepPrice" sender:self];
//    }
    else{
        [self performSegueWithIdentifier:@"toStepFinal" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
    [self.wizardDictionary setObject:self.titleTextView.text forKey:WIZARD_TITLE_KEY];
    //[self.wizardDictionary setObject:self.descriptionTextView.text forKey:WIZARD_DESCRIPTION_KEY];
    [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:self.wizardDictionary];
    NSLog(@"....... Step cat WIZARD_DICTIONARY_KEY %@", self.wizardDictionary);
    if ([[segue identifier] isEqualToString:@"toStepPOI"]) {
        SHPWizardStep5Poi *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toStepFinal"]) {
        SHPWizardStepFinal *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
}


- (IBAction)actionButtonCellNext:(id)sender {
    [self selectSegue];
}

- (IBAction)actionNext:(id)sender {
    [self selectSegue];
}
@end
