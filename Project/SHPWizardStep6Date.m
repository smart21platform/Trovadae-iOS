//
//  SHPWizardStep6Date.m
//  Galatina
//
//  Created by dario de pascalis on 19/02/15.
//
//

#import "SHPWizardStep6Date.h"

#import "SHPConstants.h"
#import "SHPApplicationContext.h"
#import "SHPStringUtil.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPImageUtil.h"
#import "SHPCategory.h"
#import "SHPWizardHelper.h"
#import "SHPComponents.h"
#import "SHPWizardHelper.h"
#import "SHPWizardStep7Price.h"
#import "SHPWizardStepFinal.h"


//DATE-PICKER
// keep track of which rows have date cells
#define kDateStartRow   2
#define kDateEndRow     4
//END

@interface SHPWizardStep6Date ()
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
//@property (nonatomic, strong) NSDateFormatter *dateToSendFormatter;
//DATE-PICKER
// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property (strong, nonatomic) NSMutableArray *daysNames;
@property (assign, nonatomic) int duration;
@end

static int one_day_seconds = 86400;
static int last_day_seconds = 86399;
static int max_start_day_from_today = 365;
static int max_duration_in_days = 120;
SHPCategory *category;


@implementation SHPWizardStep6Date

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize{
    /********************************/
    [self getTypeAndCategory];
    typeDictionary = [SHPComponents getConfigValueFromWizardPlist:self.applicationContext typeSelected:typeSelected];

    NSDictionary *plistDictionary = [self.applicationContext.plistDictionary objectForKey:@"Wizard"];
    if([plistDictionary valueForKey:@"maxDurationInDays"]){
        max_duration_in_days = [[plistDictionary valueForKey:@"maxDurationInDays"] intValue];
    }

    // SET TITLE NAV BAR
    UIImage *title_image;
    NSString *categoryIconURL = [self.selectedCategory iconURL];
    NSLog(@"....... %@", categoryIconURL);
    UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
    UIImage *staticIcon = [self.selectedCategory getStaticIconFromDisk];
    if (cacheIcon) {
        title_image = cacheIcon;
    }
    else if (staticIcon) {
        title_image = staticIcon;
    }
    [SHPComponents customizeTitleWithImage:title_image vc:self];
    
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    self.durationPicker.delegate = self;
    self.startDatePicker.datePickerMode = UIDatePickerModeDate;

    [self basicSetup];
    [self customStepSetup];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"WizardStepDate type:%@ category:%@", typeSelected, self.selectedCategory.label];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}

-(void)getTypeAndCategory{
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.selectedCategory = (SHPCategory *) [self.wizardDictionary objectForKey:WIZARD_CATEGORY_KEY];
}

-(void)basicSetup {
    NSLog(@"....... basicSetup");
    // init next button
    self.nextButton.title = NSLocalizedString(@"wizardNextButton", nil);
    [self.buttonCellNext setTitle:NSLocalizedString(@"wizardNextButton", nil) forState:UIControlStateNormal];
    [SHPImageUtil arroundImage:5.0 borderWidth:0.5 layer:[self.buttonCellNext layer]];
    // init top message
    NSLog(@"....... self.wizardDictionary: %@",self.wizardDictionary);
    NSString *headerLabel = [[NSString alloc] initWithFormat:@"header-step6-date-%@", typeSelected];
    NSString *hintLabel = [[NSString alloc] initWithFormat:@"hint-step6-date-%@", typeSelected];
    NSString *textHeader = NSLocalizedString(headerLabel, nil);
    NSString *textHint = NSLocalizedString(hintLabel, nil);
    
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHeader toAttributedLabel:self.topMessageLabel];
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHint  toAttributedLabel:self.hintLabel];
    
    self.wh = [[SHPWizardHelper alloc] init];
    [self enableButtonNextStep];
}

-(void)customStepSetup {
    NSLog(@"....... customStepSetup");
    // localize
    self.startDateLabel.text = [[NSString alloc] initWithFormat:@"%@:", NSLocalizedString(@"spanStartDateLabelLKey", nil)];
    self.durationLabel.text = [[NSString alloc] initWithFormat:@"%@:", NSLocalizedString(@"howlong", nil)];
    self.endDateLabel.text = [[NSString alloc] initWithFormat:@"%@:", NSLocalizedString(@"endsOn", nil)];
    
    //DATE-PICKER
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"EEE dd MMMM"];
    [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    [self initDaysArray];
    [self initDates];
}


-(NSString *)durationStringForDays:(int)days {
    if (days == 0) {
        //        NSLog(@"0000000000");
        return [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"SelectDuration", nil)];
    }
    if (days == 1) {
        //        NSLog(@"1111111111");
        return [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"durationOneDay", nil)];
    }
    //    NSLog(@"Altro........33333");
    return [[NSString alloc] initWithFormat:@"%d %@", days, NSLocalizedString(@"durationDays", nil)];
}

-(void)initDaysArray {
    self.daysNames = [[NSMutableArray alloc] init];
    [self.daysNames addObject:NSLocalizedString(@"SelectDuration", nil)];
    NSString *first_day_name = [self durationStringForDays:1];
    [self.daysNames addObject:first_day_name];
    for (int i = 2; i <= max_duration_in_days; i++) {
        NSString *day_name = [self durationStringForDays:i];
        [self.daysNames addObject:day_name];
    }
}

// init dates with now
-(void)initDates {
    NSDate *startDateString;
    NSDate *endDateString;
    
    if ([self.wizardDictionary objectForKey:WIZARD_DATE_START_KEY]) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd/MM/yyyy HH:mm Z"];
        startDateString = [df dateFromString: (NSString *)[self.wizardDictionary objectForKey:WIZARD_DATE_START_KEY]];
        //startDateString = [self getTodayAtMidnight];
        endDateString = [df dateFromString: (NSString *)[self.wizardDictionary objectForKey:WIZARD_DATE_END_KEY]];
        self.duration = (int)[self daysBetweenDate:startDateString andDate:endDateString]+1;
        NSLog(@"Diff = %d", self.duration);
    }
    else{
        // start date
        startDateString = [self getTodayAtMidnight];
        
        self.duration = 0;
    }
    NSLog(@"TODAY: %@", startDateString);
    [self.startDatePicker setDate:startDateString];
    
    NSDate *today = [self getTodayAtMidnight];
    self.startDatePicker.minimumDate = today;
    self.startDatePicker.maximumDate = [[NSDate date] dateByAddingTimeInterval:one_day_seconds * max_start_day_from_today];
    
    [self setStartDate];
    [self setDuration];
}

//-(NSDate *)getTomorrow {
//    NSDate *now = [NSDate date];
//    int daysToAdd = 1;
//
//    // set up date components
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    [components setDay:daysToAdd];
//    //    [components setHour:0];
//    //    [components setMinute:0];
//    //    [components setSecond:0];
//    //    [components setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//
//    // create a calendar
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    //    NSDate *tomorrow = [gregorian dateByAddingComponents:components toDate:now options:0];
//    //    NSLog(@"tomorrow %@", tomorrow);
//
//    NSDate *tomorrow_with_time = [gregorian dateByAddingComponents:components toDate:now options:0];
//    NSLog(@"Clean: %@", tomorrow_with_time); // 2014-03-18 18:36:09 +0000
//    NSString *tomorrow_date_only = [self.date_ddMMyyyy_formatter stringFromDate:tomorrow_with_time];
//    NSLog(@"tomorrow_date_nly %@", tomorrow_date_only); // 18/03/2014
//    NSString *tomorrow_at_00 = [NSString stringWithFormat:@"%@ 00:00", tomorrow_date_only];
//    NSLog(@"tomorrow_at_00 %@", tomorrow_at_00); // 18/03/2014 00:00
//    NSDate *tomorrow = [self.dateToSendFormatter dateFromString:tomorrow_at_00];
//    NSLog(@"tomorrow %@", tomorrow); // 2014-03-18 00:00:00 +0000
//
//    return tomorrow;
//}

-(NSDate *)getTodayAtMidnight {
    NSDate *now = [NSDate date];
    NSLog(@"NOW::::: %@", now);
    
    //    // test ****
    //    NSDateFormatter *date_ddMMyyyy_HH_mm_formatter = [[NSDateFormatter alloc] init];
    //    [date_ddMMyyyy_HH_mm_formatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    //    NSString *today_date_and_time = [date_ddMMyyyy_HH_mm_formatter stringFromDate:now];
    //    NSLog(@"today_date_and_time %@", today_date_and_time); // 18/03/2014 12:33
    
    //    NSString *today_date_only = [self.date_ddMMyyyy_formatter stringFromDate:now];
    //    NSLog(@"today_date_only %@", today_date_only); // 18/03/2014
    //    NSString *today_at_00 = [NSString stringWithFormat:@"%@ 00:00", today_date_only];
    //    NSLog(@"today_at_00 %@", today_at_00); // 18/03/2014 00:00
    //    NSDate *today = [self.dateToSendFormatter dateFromString:today_at_00];
    //    NSLog(@"today %@", today); // 2014-03-18 00:00:00 +0000
    
    NSDate *today_at_midnight = [self midnightForDate:now];
    NSLog(@"today_at_midnight %@", today_at_midnight); // 2014-03-18 23:00:00 +0100
    return today_at_midnight;
}

// date midnight in local timezone is date in UTC?
// now: 2014-03-26 14:46:31 +0000
// now in localtimezone: 26/03/2014 15:46 +0100
// today from now, at midnight: 2014-03-25 23:00:00 +0000 (26 becomes -> 25)
- (NSDate *)midnightForDate:(NSDate *)date {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    //    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    NSDate *midnightUTC = [calendar dateFromComponents:dateComponents];
    return midnightUTC;
}

// forces the date to be "today 00:00 +0000"
- (NSDate *)midnightUTCForDate:(NSDate *)date {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                   fromDate:date];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    NSDate *midnightUTC = [calendar dateFromComponents:dateComponents];
    return midnightUTC;
}

//-(NSDate *)getEndOfDay:(NSDate *)date {
//    NSLog(@"***Clean: %@", date); // 2014-03-18 18:36:09 +0000
//    NSString *date_only = [self.date_ddMMyyyy_formatter stringFromDate:date];
//    NSLog(@"***date_only %@", date_only); // 18/03/2014
//    NSString *date_at_2359 = [NSString stringWithFormat:@"%@ 23:59", date_only];
//    NSLog(@"***date_at_00 %@", date_at_2359); // 18/03/2014 00:00
//    NSDate *day_end = [self.dateToSendFormatter dateFromString:date_at_2359];
//    NSLog(@"***tomorrow %@", day_end); // 2014-03-18 00:00:00 +0000
//
//    return day_end;
//}


- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}



#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return self.daysNames.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    //    NSLog(@"Row %d: %@", (int)row, self.daysNames[row]);
    
    return self.daysNames[row];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    //    self.durationValueLabel.text = [self.daysNames objectAtIndex:(int)row];
    if (row == 0) {
        self.duration = 0;
    }
    else {
        self.duration = (int)(row);
    }
    [self setDuration];
}

#pragma mark -
#pragma mark TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int super_height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    //    NSLog(@"SUPER HEIGHT AT %d - %d %d", (int)indexPath.section, (int)indexPath.row, super_height);
    
    if (indexPath.row == kDateStartRow + 1) {
        if (self.datePickerIndexPath &&
            self.datePickerIndexPath.row == kDateStartRow + 1 ) {
            return super_height;
        } else {
            //            NSLog(@"START - RETURNING 0 FOR ROW %ld", (long)indexPath.row);
            return 0.0;
        }
    }
    if (indexPath.row == kDateEndRow + 1) {
        if (self.datePickerIndexPath &&
            self.datePickerIndexPath.row == kDateEndRow + 1 ) {
            return super_height;
        } else {
            //            NSLog(@"END - RETURNING 0 FOR ROW %ld", indexPath.row);
            return 0.0;
        }
    }
    
    return super_height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    NSLog(@"DID SELECT ROW! ID: %@ for indexPath %@...%d", cell.reuseIdentifier, indexPath, kDateStartRow);
    if (indexPath.row == kDateStartRow ||
        indexPath.row == kDateEndRow ) {
        NSLog(@"displayInlineDatePickerForRowAtIndexPath %d", (int)indexPath.row);
        // always deselect the row containing the start or end date
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        //        // switch off allTheDaySwitch
        //        self.allTheDaySwitch.on = NO;
        //        [self turnAllTheDayOff];
        
        if (self.datePickerIndexPath &&  self.datePickerIndexPath.row == indexPath.row + 1) {
            // hide datePicker
            NSLog(@"HIDING");
            //[SHPImageUtil rotateImageView:self.imageStartDate angle:0.0];
            
            self.datePickerIndexPath = nil;
            if (indexPath.row == kDateStartRow) {
                [SHPImageUtil rotateImageViewWithAnimation:self.imageStartDate duration:0.2 angle:0.0];
                [SHPImageUtil rotateImageView:self.imageEndDate angle:0.0];
                self.startDateValueLabel.textColor = [UIColor blackColor];
                self.durationValueLabel.textColor = [UIColor blackColor];
            } else if (indexPath.row == kDateEndRow) {
                [SHPImageUtil rotateImageViewWithAnimation:self.imageEndDate duration:0.2 angle:0.0];
                [SHPImageUtil rotateImageView:self.imageStartDate angle:0.0];
                self.durationValueLabel.textColor = [UIColor blackColor];
                self.startDateValueLabel.textColor = [UIColor blackColor];
            }
            [self enableButtonNextStep];
        }
        else {
            // show datePicker
            NSLog(@"SHOWING");
            self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            if (indexPath.row == kDateStartRow) {
                [SHPImageUtil rotateImageViewWithAnimation:self.imageStartDate duration:0.12 angle:-90.0];
                [SHPImageUtil rotateImageView:self.imageEndDate angle:0.0];
                self.startDateValueLabel.textColor = [UIColor redColor];
                self.durationValueLabel.textColor = [UIColor blackColor];
            } else if (indexPath.row == kDateEndRow) {
                [SHPImageUtil rotateImageViewWithAnimation:self.imageEndDate duration:0.12 angle:-90.0];
                [SHPImageUtil rotateImageView:self.imageStartDate angle:0.0];
                self.durationValueLabel.textColor = [UIColor redColor];
                self.startDateValueLabel.textColor = [UIColor blackColor];
            }
        }
        
        NSLog(@"self.datePickerIndexPath %@", self.datePickerIndexPath);
        [self.tableView beginUpdates];
        // updates animated the height change of datePickerCell in heightForRowAtIndexPath (who works based
        // on the value of the just updated self.datePickerIndexPath)
        [self.tableView endUpdates];
        
        if (self.datePickerIndexPath) {
            // animate to show the datePickerCell
            [self.tableView scrollToRowAtIndexPath:self.datePickerIndexPath
                                  atScrollPosition:UITableViewScrollPositionBottom
                                          animated:YES];
        }
    }
}


-(void)enableButtonNextStep{
    NSString *checkType = [typeDictionary valueForKey:@"date"];
    NSLog(@"checkType: %@ - valid:%d",checkType, self.duration);
    if([checkType isEqualToString:@"2"]){
    //if(checkDate==true){
        if(self.duration == 0){
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

}


-(void)selectSegue
{
    NSLog(@"typeDictionary %@ - %@",typeDictionary, typeSelected);
//    if(![[typeDictionary valueForKey:@"title"] isEqualToString:@"0"]){
//        [self performSegueWithIdentifier:@"toStepTitle" sender:self];
//    }else if(![[typeDictionary valueForKey:@"poi"] isEqualToString:@"0"]){
//        [self performSegueWithIdentifier:@"toStepPOI" sender:self];
//    }else if(![[typeDictionary valueForKey:@"date"] isEqualToString:@"0"]){
//        [self performSegueWithIdentifier:@"toStepData" sender:self];
//    }else
    if(![[typeDictionary valueForKey:@"price"] isEqualToString:@"0"]){
        [self performSegueWithIdentifier:@"toStepPrice" sender:self];
    }else{
        [self performSegueWithIdentifier:@"toStepFinal" sender:self];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.wizardDictionary setObject:self.selectedStartDateAsStringToSend forKey:WIZARD_DATE_START_KEY];
    [self.wizardDictionary setObject:self.selectedEndDateAsStringToSend forKey:WIZARD_DATE_END_KEY];
    [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:self.wizardDictionary];
    if ([[segue identifier] isEqualToString:@"toStepPrice"]) {
        SHPWizardStep7Price *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toStepFinal"]) {
        SHPWizardStepFinal *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
}

-(void)dismissDatePickers {
    self.datePickerIndexPath = nil;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (IBAction)dateAction:(id)sender {
    UIDatePicker *targetedDatePicker = sender;
    NSLog(@"%@", targetedDatePicker.date);
    if (sender == self.startDatePicker) {
        NSLog(@"START DATE");
        [self setStartDate];
        [self setDuration];
    }
}

-(void)setStartDate {
    NSLog(@"SELECTED DATE: %@", self.startDatePicker.date);
    self.selectedStartDateAsDate = [self midnightForDate:self.startDatePicker.date];
    NSLog(@"self.selectedStartDateAsDate DATE: %@", self.selectedStartDateAsDate);
    self.selectedStartDateAsStringToSend = [self.wh.dateToSendFormatter stringFromDate:self.selectedStartDateAsDate];
    NSLog(@"self.selectedStartDateAsStringToSend DATE: %@", self.selectedStartDateAsStringToSend);
    self.startDateValueLabel.text = [[self.dateFormatter stringFromDate:self.selectedStartDateAsDate] capitalizedString];
}


-(void)setDuration {
    self.durationValueLabel.text = [self durationStringForDays:self.duration];
    if (self.duration == 0) {
        NSLog(@"No duration");
        self.selectedEndDateAsDate = nil;
        //        NSLog(@"final date = %@", self.selectedEndDateAsDate);
        
        self.nextButton.enabled = NO;
        self.buttonCellNext.enabled = NO;
        self.buttonCellNext.alpha = 0.5;

        
        self.selectedEndDateAsStringToSend = nil;
        self.endDateValueLabel.text = @"?";
        NSLog(@"self.dateFormatter %@ %@", self.dateFormatter, self.dateFormatter.timeZone);
        NSLog(@"SELECTED END DATE TO SEND %@", self.selectedEndDateAsStringToSend);
    } else if (self.duration == 1) {
        NSLog(@"duration = 1 day");
        self.selectedEndDateAsDate = [self.selectedStartDateAsDate dateByAddingTimeInterval:last_day_seconds];
        NSLog(@"final date = %@", self.selectedEndDateAsDate);
        
        self.nextButton.enabled = YES;
        self.buttonCellNext.enabled = YES;
        self.buttonCellNext.alpha = 1;
        
        self.selectedEndDateAsStringToSend = [self.wh.dateToSendFormatter stringFromDate:self.selectedEndDateAsDate];
        self.endDateValueLabel.text = [[self.dateFormatter stringFromDate:self.selectedEndDateAsDate] capitalizedString];
        NSLog(@"self.dateFormatter %@ %@", self.dateFormatter, self.dateFormatter.timeZone);
        NSLog(@"SELECTED END DATE TO SEND %@", self.selectedEndDateAsStringToSend);
    } else {
        NSLog(@"duration = %d", self.duration);
        int duration_except_last_day_secs = (self.duration - 1) * one_day_seconds;
        int duration_secs = duration_except_last_day_secs + last_day_seconds;
        NSLog(@"duration_secs %d", duration_secs);
        self.selectedEndDateAsDate = [self.selectedStartDateAsDate dateByAddingTimeInterval:duration_secs];
        NSLog(@"final date = %@", self.selectedEndDateAsDate);
        
        self.nextButton.enabled = YES;
        self.buttonCellNext.enabled = YES;
        self.buttonCellNext.alpha = 1;
        
        self.selectedEndDateAsStringToSend = [self.wh.dateToSendFormatter stringFromDate:self.selectedEndDateAsDate];
        self.endDateValueLabel.text = [[self.dateFormatter stringFromDate:self.selectedEndDateAsDate] capitalizedString];
        NSLog(@"self.dateFormatter %@ %@", self.dateFormatter, self.dateFormatter.timeZone);
        NSLog(@"SELECTED END DATE TO SEND %@", self.selectedEndDateAsStringToSend);
    }
}

- (IBAction)actionButtonCellNext:(id)sender {
    [self selectSegue];
}

- (IBAction)nextAction:(id)sender {
    NSLog(@"Next");
    NSLog(@"dateStart %@", self.selectedStartDateAsStringToSend);
    NSLog(@"dateEnd %@", self.selectedEndDateAsStringToSend);
    [self selectSegue];
}

@end
