//
//  Rule.m
//  preggers
//
//  Created by Matt Diephouse on 12/28/09.
//  This code is in the public domain.
//

#import "Rule.h"


@implementation Rule

@synthesize name = _name;
@synthesize used = _used;

@synthesize definition = _definition;

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    [_name release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) ruleWithName:(NSString*)name
{
    return [[[[self class] alloc] initWithName:name] autorelease];
}


- (id) initWithName:(NSString*)name
{
    self = [super init];
    
    if (self)
    {
        _name = [name copy];
    }
    
    return self;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Properties
//==================================================================================================

- (BOOL) defined
{
    return self.definition != nil;
}


@end
