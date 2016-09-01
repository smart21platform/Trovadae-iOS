//
//  SHPProduct.h
//  BirdWatching
//
//  Created by andrea sponziello on 26/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHPProduct : NSObject

@property (nonatomic, strong) NSString *oid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *longDescription;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *categoryLabel;
@property (nonatomic, strong) NSString *categoryType;
@property (nonatomic, strong) NSString *shop;
@property (nonatomic, strong) NSString *shopName;
@property (nonatomic, assign) double shopLat;
@property (nonatomic, assign) double shopLon;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *httpURL;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *startprice;
@property (nonatomic, strong) NSString *distance;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) BOOL userLiked;
@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, assign) BOOL sponsored;
@property (nonatomic, strong) NSDate *createdOn;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *createdBy;
@property (nonatomic, assign) float imageHeight;
@property (nonatomic, assign) float imageWidth;
@property (nonatomic, strong) NSDictionary *properties;

@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *available;
@property (nonatomic, strong) NSString *personalCod;
@property (nonatomic, strong) NSString *orderable;
@property (nonatomic, strong) NSString *prezzorivenditore;
@property (nonatomic, strong) NSString *prezzosubunitario;
@property (nonatomic, strong) NSString *prezzosubunitariolistino;
@property (nonatomic, strong) NSString *unitamisura;
@property (nonatomic, strong) NSString *codiceOriginale;
@property (nonatomic, strong) NSString *quickReference;
@property (nonatomic, strong) NSString *urlPath;

-(NSString *)httpTinyURL;
-(NSString *)returnProperty:(NSString*)label;
+(NSDictionary *)setProperties:(NSString*)label displayName:(NSString *)displayName oid:(NSString *)idProperty values:(NSArray *)values;
@end
