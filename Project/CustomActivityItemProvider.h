//
//  CustomActivityItemProvider.h
//  Secondamano
//
//  Created by Andrea Sponziello on 22/02/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomActivityItemProvider : UIActivityItemProvider

@property (strong, nonatomic) NSString *emailSubject;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *twit;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) UIImage *image;


- (id)initWithText:(NSString *)text twitText:(NSString *)twitText urlText:(NSURL *)urlText image:(UIImage *)image emailSubject:(NSString *)emailSubject;

@end
