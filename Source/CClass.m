//
//  CClass.m
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "CClass.h"


@implementation CClass

@synthesize string = _string;

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    [_string release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) cclassFromString:(NSString *)class;
{
    return [[[[self class] alloc] initWithString:class] autorelease];
}

- (id) initWithString:(NSString *)class
{
    self = [super init];
    
    if (self)
    {
        _string = [class copy];
    }
    
    return self;
}


@end
