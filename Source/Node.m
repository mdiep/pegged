//
//  Node.m
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Node.h"


@implementation Node

@synthesize inverted    = _inverted;
@synthesize lookAhead   = _lookAhead;
@synthesize optional    = _optional;
@synthesize repeats     = _repeats;

//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) node
{
    return [[[self class] new] autorelease];
}


@end
