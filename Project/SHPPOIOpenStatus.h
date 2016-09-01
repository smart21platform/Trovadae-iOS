//
//  SHPPOIOpenStatus.h
//  Salve Smart
//
//  Created by Andrea Sponziello on 12/11/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHPPOIOpenStatus : NSObject

+(NSString *)returnWeekDay:(NSInteger)index;
+(BOOL)isOpenForPlan:(NSDictionary *)planStruct onDate:(NSDate *)date;
+(NSMutableDictionary *)compile:(NSString *)plan;
+ (NSDate *)dateByNeutralizingDateComponentsOfDate:(NSDate *)originalDate;
+(BOOL)isTimeOfDate:(NSDate *)targetDate betweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+(NSDate *)nextOpenHourForPlan:(NSDictionary *)planStruct onDate:(NSDate *)date; // 1,2,...
+(NSDictionary *)nextOpenWeekDayForPlan:(NSDictionary *)plan onDate:(NSDate *)date; // 1 = Sunday, 2 = Monday
+(NSString *)weekDayAsString:(NSDate *)date;
+(NSInteger)weekDayAsInt:(NSDate *)date;
+(NSDictionary *)dayAndTimeOpeningForWeekday:(NSInteger)weekday inPlan:(NSDictionary *)plan;

@end
