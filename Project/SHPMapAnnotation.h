//
//  SHPMapAnnotation.h
//  Soleto
//
//  Created by dario de pascalis on 05/11/14.
//
//

//#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface SHPMapAnnotation : NSObject <MKAnnotation>
    @property (nonatomic, strong) NSString *oid;
    @property (nonatomic, strong) NSString *title;
    @property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

-(id)initWithTitle:(NSString *)title andCoordinate:(CLLocationCoordinate2D)coordinate2d andOid:(NSString *)oid;
@end
