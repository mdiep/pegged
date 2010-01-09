//
//  Condition.m
//  preggers
//
//  Created by Matt Diephouse on 1/8/10.
//  This code is in the public domain.
//

#import "Condition.h"


@implementation Condition

@synthesize expression = _expression;

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    [_expression release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Terminal Methods
//==================================================================================================

- (NSString *) condition
{
    return [NSString stringWithFormat:@"(%@)", _expression];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) conditionWithExpression:(NSString *)expression
{
    return [[[[self class] alloc] initWithExpression:expression] autorelease];
}


- (id) initWithExpression:(NSString *)expression
{
    self = [super init];
    
    if (self)
    {
        _expression = [expression copy];
    }
    
    return self;
}


@end
