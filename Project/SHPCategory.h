//
//  SHPCategory.h
//  Shopper
//
//  Created by andrea sponziello on 09/08/12.
//
//

#import <Foundation/Foundation.h>

@interface SHPCategory : NSObject <NSCoding>{
    enum {
        CATEGORY_VISIBILITY_DELETED = -100, //categoria cancellata
        CATEGORY_VISIBILITY_DISABLED = -1, // categoria disabilitata
        CATEGORY_VISIBILITY_SEARCH_ONLY = 10, //categoria visibile solo per SEARCH
        CATEGORY_VISIBILITY_WIZARD_ONLY = 20, //categoria visibile solo per WIZARD nuovo contenuto
        CATEGORY_VISIBILITY_ALL = 30 //categoria visibile sempre
    };
}

@property (nonatomic, strong) NSString *oid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *parent;
@property (nonatomic, strong) NSString *allowUserContentCreation;
@property (nonatomic, assign) NSInteger visibility;


-(UIImage *)getStaticIconFromDisk;
-(NSString *)iconURL;
-(NSString *)iconAll;
-(NSString *)localName;
-(BOOL)getVisibility:(NSString *)listFor;

@end
