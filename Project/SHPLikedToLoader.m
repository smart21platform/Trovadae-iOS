//
//  SHPLikedToLoader.m
//  Ciaotrip
//
//  Created by Dario De Pascalis on 14/02/14.
//
//

#import "SHPLikedToLoader.h"
#import "SHPUserDC.h"

@implementation SHPLikedToLoader

- (id) init
{
    self = [super init];
    
    if (self != nil) {
        self.userDC = [[SHPUserDC alloc] init];
    }
    return self;
}

// extends
-(void)loadUsers {
    [self.userDC likedTo:self.product];
}

@end
