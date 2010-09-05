//
//  Code.m
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import "Code.h"


@implementation Code

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
#pragma mark Node Methods
//==================================================================================================

- (NSString *) compile:(NSString *)failLabel
{
    return [NSString stringWithFormat:@"    %@;\n", self.code];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) codeWithString:(NSString *)code
{
    return [[[[self class] alloc] initWithString:code] autorelease];
}


- (id) initWithString:(NSString *)code
{
    self = [super init];
    
    if (self)
    {
        _code = [code copy];
    }
    
    return self;
}

@end
