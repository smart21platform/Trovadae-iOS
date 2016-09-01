//
//  SHPPOIOpenStatus.m
//  Salve Smart
//
//  Created by Andrea Sponziello on 12/11/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "SHPPOIOpenStatus.h"

@implementation SHPPOIOpenStatus


+(NSString *)returnWeekDay:(NSInteger)index{
    NSArray *arrayWeekDay = @[@"Domenica",@"Lunedì", @"Martedì", @"Mercoledì", @"Giovedì", @"Venerdì", @"Sabato"];
    NSString *day = arrayWeekDay[index];
    return day;
}

+(BOOL)isOpenForPlan:(NSDictionary *)planStruct onDate:(NSDate *)date {
    // now
    NSDate *now = [[NSDate alloc] init];
    // get today weekday
    NSString *today_key = [SHPPOIOpenStatus weekDayAsString:now];
    
    NSArray *day_intervals = nil;
    if (today_key) {
        day_intervals = [planStruct objectForKey:today_key];
    } else {
        NSLog(@"ERROR: today_key can't be null");
        return NO;
    }
    
    if (day_intervals) {
        for (NSDictionary *interval in day_intervals) {
            NSString *startHour = [interval objectForKey:@"start"];
            NSString *endHour = [interval objectForKey:@"end"];
            //            NSLog(@"start: %@, end: %@", startHour, endHour);
            // is "now" in this interval?
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm"];
            NSString *fake_day = @"2000:01:01";
            
            NSString *_opening_date = [[NSString alloc] initWithFormat:@"%@ %@", fake_day, startHour];
            NSDate *openingDate = [dateFormatter dateFromString:_opening_date];
            NSString *_closing_date = [[NSString alloc] initWithFormat:@"%@ %@", fake_day, endHour];
            NSDate *closingDate = [dateFormatter dateFromString:_closing_date];
            
            BOOL isInInterval = [SHPPOIOpenStatus isTimeOfDate:now betweenStartDate:openingDate endDate:closingDate];
            if (isInInterval) {
                NSLog(@"OK. %@ is in the interval %@ - %@", now, startHour, endHour);
                return YES;
            }
        }
    } else {
        NSLog(@"Day %@ has no intervals", today_key);
        return NO;
    }
    return NO;
}

+(NSMutableDictionary *)compile:(NSString *)plan {
    
    if (!plan) {
        NSLog(@"Opening plan is nil.");
        return nil;
    }
    
    plan = [plan stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (plan.length == 0) {
        NSLog(@"Opening plan is empty.");
        return nil;
    }
    
    NSString *days_separator = @"|"; // 0>9:00-13:00;16:00-20:00 | 1>9:00-13:00;16:00-20:00
    NSString *day_hours_separator = @">"; // 5 > 9:00-12:00
    NSString *intervals_separator = @";"; // 9:00-13:00 ; 16:00-20:00
    NSString *hours_separator = @"-"; // 16:00 - 20:00
    
    NSMutableDictionary *weekdays_dict = [[NSMutableDictionary alloc] init];
    // 0>9:00-13:00;16:00-20:00#1>9:00-13:00;16:00-20:00#5>9:00-12:00
    
    NSArray *days = [plan componentsSeparatedByString:days_separator];
    //    NSLog(@"days: %@",days);
    
    for (NSString *weekday_num in days) {
        NSLog(@"Processing day: %@", weekday_num);
        NSMutableArray *intervals = [[NSMutableArray alloc] init];
        NSArray *day_hours = [weekday_num componentsSeparatedByString:day_hours_separator];
        NSString *day_string = [day_hours objectAtIndex:0];
        NSString *hours_string = [day_hours objectAtIndex:1];
        NSLog(@"day is: %@", day_string);
        NSLog(@"hours are: %@", hours_string);
        NSLog(@"Processing hours: %@", hours_string);
        NSArray *h_intervals = [hours_string componentsSeparatedByString:intervals_separator];
        for (NSString *interval in h_intervals) {
            NSMutableDictionary *interval_dict = [[NSMutableDictionary alloc] init];
            NSLog(@"single interval: %@", interval);
            NSArray *hours_in_interval = [interval componentsSeparatedByString:hours_separator];
            NSString *start =[hours_in_interval objectAtIndex:0];
            NSString *end = [hours_in_interval objectAtIndex:1];
            [interval_dict setValue:start forKey:@"start"];
            [interval_dict setValue:end forKey:@"end"];
            [intervals addObject:interval_dict];
            NSLog(@"opens at %@ and closes at %@", start, end);
        }
        [weekdays_dict setValue:intervals forKey:day_string];
    }
    return weekdays_dict;
}

+ (NSDate *)dateByNeutralizingDateComponentsOfDate:(NSDate *)originalDate {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Get the components for this date
    NSDateComponents *components = [gregorian components:  (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate: originalDate];
    
    // Set the year, month and day to some values (the values are arbitrary)
    [components setYear:2000];
    [components setMonth:1];
    [components setDay:1];
    
    return [gregorian dateFromComponents:components];
}

+(BOOL)isTimeOfDate:(NSDate *)targetDate betweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    if (!targetDate || !startDate || !endDate) {
        return NO;
    }
    
    // Make sure all the dates have the same yyyy:MM:dd component.
    NSDate *newStartDate = [self dateByNeutralizingDateComponentsOfDate:startDate];
    NSDate *newEndDate = [self dateByNeutralizingDateComponentsOfDate:endDate];
    NSDate *newTargetDate = [self dateByNeutralizingDateComponentsOfDate:targetDate];
    
    // Compare the target with the start and end dates
    NSComparisonResult compareTargetToStart = [newTargetDate compare:newStartDate];
    NSComparisonResult compareTargetToEnd = [newTargetDate compare:newEndDate];
    
    return (compareTargetToStart == NSOrderedDescending && compareTargetToEnd == NSOrderedAscending);
}

//+(BOOL)isTimeOfDate:(NSDate *)targetDate greaterThanDate:(NSDate *)date {
//    if (!targetDate || !date) {
//        return NO;
//    }
//
//    // Make sure all the dates have the same yyyy:MM:dd component.
//    NSDate *newDate = [self dateByNeutralizingDateComponentsOfDate:date];
//    NSDate *newTargetDate = [self dateByNeutralizingDateComponentsOfDate:targetDate];
//
//    // Compare the target with the start and end dates
//    NSComparisonResult compareTargetToStart = [newTargetDate compare:newDate];
//    NSComparisonResult compareTargetToEnd = [newTargetDate compare:newEndDate];
//
//    return (compareTargetToStart == NSOrderedDescending && compareTargetToEnd == NSOrderedAscending);
//}

+(NSDate *)nextOpenHourForPlan:(NSDictionary *)planStruct onDate:(NSDate *)date {
    NSLog(@"...nextOpenHourForPlan...");
    //    // get date as weekday
    NSString *day_key = [SHPPOIOpenStatus weekDayAsString:date];
    //
    NSArray *day_intervals = nil;
    if (day_key) {
        day_intervals = [planStruct objectForKey:day_key];
    } else {
        NSLog(@"ERROR: today_key can't be null");
        return nil;
    }
    
    if (day_intervals) {
        NSMutableArray *intervalStarts = [[NSMutableArray alloc] init];
        for (NSDictionary *interval in day_intervals) {
            NSString *startHour = [interval objectForKey:@"start"];
            NSString *endHour = [interval objectForKey:@"end"];
            NSLog(@"start: %@, end: %@", startHour, endHour);
            // Is "now" in this interval?
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm"];
            NSString *fake_day = @"2000:01:01";
            
            NSString *_opening_date = [[NSString alloc] initWithFormat:@"%@ %@", fake_day, startHour];
            NSDate *openingDate = [dateFormatter dateFromString:_opening_date];
            
            NSLog(@"Adding opening %@", openingDate);
            [intervalStarts addObject:openingDate];
        }
        
        NSLog(@"Date: %@", date);
        // gets time from date to compare with intervals-start
        NSDate *newTargetDate = [self dateByNeutralizingDateComponentsOfDate:date];
        NSLog(@"Normalized date: %@", newTargetDate);
        for (NSDate *start in intervalStarts) {
            NSLog(@"Start interval: %@", start);
            if ([start timeIntervalSinceReferenceDate] > [newTargetDate timeIntervalSinceReferenceDate]) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm"];
                NSLog(@"Found start time: %@", [dateFormatter stringFromDate:start]);
                return start;
            }
        }
    } else {
        NSLog(@"Day %@ has no intervals", day_key);
        return nil;
    }
    
    return nil;
}

+(NSDictionary *)nextOpenWeekDayForPlan:(NSDictionary *)plan onDate:(NSDate *)date {
    // 1: SUNDAY, 2: MONDAY, ...
    NSLog(@"...nextOpenWeekDayForPlan...");
    NSDictionary *dayAndTimeOpening = nil;
    NSInteger weekday = [SHPPOIOpenStatus weekDayAsInt:date];
    
    if (weekday > 1 && weekday < 7) {
        for (NSInteger day = weekday + 1; day < 7; day++) { // from weekday+1 to 7
            dayAndTimeOpening = [SHPPOIOpenStatus dayAndTimeOpeningForWeekday:day inPlan:plan];
            if (dayAndTimeOpening) return dayAndTimeOpening;
        }
        for (int day = 1; day < weekday; day++) { // from 1 to weekday-1
            dayAndTimeOpening = [SHPPOIOpenStatus dayAndTimeOpeningForWeekday:day inPlan:plan];
            if (dayAndTimeOpening) return dayAndTimeOpening;
        }
    } else if (weekday == 1) {
        dayAndTimeOpening = [SHPPOIOpenStatus dayAndTimeOpeningForWeekday:weekday inPlan:plan];
        if (dayAndTimeOpening) return dayAndTimeOpening;
    } else if (weekday == 7) {
        dayAndTimeOpening = [SHPPOIOpenStatus dayAndTimeOpeningForWeekday:weekday inPlan:plan];
        if (dayAndTimeOpening) return dayAndTimeOpening;
    }
    
    return nil;
}

+(NSDictionary *)dayAndTimeOpeningForWeekday:(NSInteger)weekday inPlan:(NSDictionary *)plan {
    NSDictionary *dayAndTimeOpening = nil;
    NSString *day_key = [[NSString alloc] initWithFormat:@"%ld", weekday];
    NSArray *day_intervals = [plan objectForKey:day_key];
    if (day_intervals && day_intervals.count > 0) {
        NSDictionary *firstInterval = [day_intervals objectAtIndex:0];
        NSString *startHour = [firstInterval objectForKey:@"start"];
        dayAndTimeOpening = [[NSMutableDictionary alloc] init];
        [dayAndTimeOpening setValue:startHour forKey:@"start"];
        [dayAndTimeOpening setValue:day_key forKey:@"weekday"];
    }
    return dayAndTimeOpening;
}

+(NSString *)weekDayAsString:(NSDate *)date {
    NSInteger weekday = [SHPPOIOpenStatus weekDayAsInt:date];
    NSString *day_key = [[NSString alloc] initWithFormat:@"%ld", weekday]; // 1 = Sunday, 2 = Monday
    return day_key;
}

+(NSInteger)weekDayAsInt:(NSDate *)date {
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger weekday = [comp weekday]; // 1 = Sunday, 2 = Monday
    return weekday;
}

@end