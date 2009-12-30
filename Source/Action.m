//
//  Action.m
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Action.h"


@implementation Action

@synthesize code = _code;

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    [_code release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) actionWithCode:(NSString *)code
{
    return [[[[self class] alloc] initWithCode:code] autorelease];
}


- (id) initWithCode:(NSString *)code
{
    self = [super init];
    
    if (self)
    {
        _code = [code copy];
    }
    
    return self;
}


@end
