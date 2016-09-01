//
//  SHPPushNoAnimationSegue.m
//  AnimaeCuore
//
//  Created by Dario De pascalis on 19/06/14.
//
//

#import "SHPPushNoAnimationSegue.h"

@implementation SHPPushNoAnimationSegue


- (void)perform
{
    [[[self sourceViewController] navigationController] pushViewController:[self destinationViewController] animated:NO];
    //[[self sourceViewController] presentModalViewController:[self destinationViewController] animated:NO];
}
@end
