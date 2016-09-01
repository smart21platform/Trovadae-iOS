//
//  SHPMapAnnotation.m
//  Soleto
//
//  Created by dario de pascalis on 05/11/14.
//
//

#import "SHPMapAnnotation.h"

@implementation SHPMapAnnotation

-(id)initWithTitle:(NSString *)title andCoordinate:
(CLLocationCoordinate2D)coordinate2d andOid:(NSString *)oid{
    self.oid = oid;
    self.title = title;
    self.coordinate =coordinate2d;
    return self;
}
@end


