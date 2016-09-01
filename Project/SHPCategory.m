//
//  SHPCategory.m
//  Shopper
//
//  Created by andrea sponziello on 09/08/12.
//
//

#import "SHPCategory.h"
#import "SHPServiceUtil.h"
#import "SHPConstants.h"

@implementation SHPCategory

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.oid = [decoder decodeObjectForKey:@"oid"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.label = [decoder decodeObjectForKey:@"label"];
        self.type = [decoder decodeObjectForKey:@"type"];
        self.parent = [decoder decodeObjectForKey:@"parent"];
        self.visibility = [[decoder decodeObjectForKey:@"visibility"] intValue];
    }
    return self;
}

-(NSString *)iconURL {
    NSString *categoryIconURL = [[NSString alloc] initWithFormat:@"%@/imagerepo/service/images/search?url=/%@/category%@/icon.png", [SHPServiceUtil serviceHost], [SHPServiceUtil serviceCategoriesTenant], self.oid];
    return categoryIconURL;
}


-(NSString *)iconAll {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *configDictionary = [plistDictionary objectForKey:@"Config"];
    NSString *serviceHost=[configDictionary objectForKey:@"serviceCategoriesTenant"];
  
//    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
//    NSString *serviceHost = [thisBundle localizedStringForKey:@"service.categories.tenant" value:@"KEY NOT FOUND" table:@"services"];
    NSString *categoryIconURL = [[NSString alloc] initWithFormat:@"%@/imagerepo/service/images/search?url=/%@/category/%@/_all.png", [SHPServiceUtil serviceHost], serviceHost, serviceHost];
    return categoryIconURL;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.oid forKey:@"oid"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.label forKey:@"label"];
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeObject:self.parent forKey:@"parent"];
    //[encoder encodeObject:self.visibility forKey:@"visibility"];
}

-(UIImage *)getStaticIconFromDisk {
    NSString *icon_image_file_name = [self.oid stringByReplacingOccurrencesOfString:@"/" withString:@"__"];
    NSLog(@"icon %@", icon_image_file_name);
    icon_image_file_name = [[NSString alloc] initWithFormat:@"category_icon%@.png", icon_image_file_name];
    NSLog(@"LOOKING FOR ICON:::::::::::::  %@", icon_image_file_name);
    UIImage *icon = [UIImage imageNamed:icon_image_file_name];
    NSLog(@"ICON FOUND????????  %@", icon);
    if(!icon){
        icon = [UIImage imageNamed:@"category_icon_bullet"];
    }
    return icon;
}

-(NSString *)keyForTranslation {
    NSString *key = [self.oid stringByReplacingOccurrencesOfString:@"/" withString:@"__"];
    return key;
}

-(NSString *)localName {
    NSString *localCategoryTranslation = NSLocalizedString([self keyForTranslation], nil);
    if (![localCategoryTranslation isEqualToString:[self keyForTranslation]]) {
        return localCategoryTranslation;
    }
    else {
        return self.label;
    }
}


-(BOOL)getVisibility:(NSString *)listFor{
    if ([listFor isEqualToString:CATEGORY_VISIBILITY_SEARCH]){
        switch (self.visibility) {
            case CATEGORY_VISIBILITY_DELETED:
                break;
            case CATEGORY_VISIBILITY_DISABLED:
                break;
            case CATEGORY_VISIBILITY_SEARCH_ONLY:
                return YES;
            case CATEGORY_VISIBILITY_WIZARD_ONLY:
                break;
            case CATEGORY_VISIBILITY_ALL:
                return YES;
                break;
            default:
                break;
        }
    }
    else if ([listFor isEqualToString:CATEGORY_VISIBILITY_WIZARD]){
        switch (self.visibility) {
            case CATEGORY_VISIBILITY_DELETED:
                break;
            case CATEGORY_VISIBILITY_DISABLED:
                break;
            case CATEGORY_VISIBILITY_SEARCH_ONLY:
                break;
            case CATEGORY_VISIBILITY_WIZARD_ONLY:
                return YES;
                break;
            case CATEGORY_VISIBILITY_ALL:
                return YES;
                break;
            default:
                break;
        }
    }
    return NO;
}

@end
