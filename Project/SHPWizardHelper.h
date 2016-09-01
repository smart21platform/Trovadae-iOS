//
//  SHPWizardHelper.h
//  San Vito dei Normanni
//
//  Created by Dario De pascalis on 18/07/14.
//
//

#import <Foundation/Foundation.h>
@class SHPCategory;
@class SHPApplicationContext;

@interface SHPWizardHelper : NSObject

@property (nonatomic, strong) NSDateFormatter *dateToSendFormatter;

+(NSMutableDictionary *)initializeWizardContext:(NSMutableDictionary *)wizardDictionary withTranslationsForCategory:(SHPCategory *)selectedCategory;

@end
