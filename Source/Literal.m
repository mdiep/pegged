//
//  Literal.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Literal.h"


@implementation Literal

@synthesize caseInsensitive = _caseInsensitive;
@synthesize string = _string;

//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (void) dealloc
{
    [_string release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Terminal Methods
//==================================================================================================

- (NSString *) condition
{
    NSString *string = self.caseInsensitive ? [self.string lowercaseString] : self.string;
    return [NSString stringWithFormat:@"[parser matchString:\"%@\"]", string];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) literalWithString:(NSString *)string
{
    return [[[[self class] alloc] initWithString:string] autorelease];
}


- (id) initWithString:(NSString *)string
{
    self = [super init];
    
    if (self)
    {
        _string = [string copy];
    }
    
    return self;
}


@end
