//
//  Expression.m
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Expression.h"


@implementation Expression

@synthesize nodes = _nodes;

//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _nodes = [NSMutableArray new];
    }
    
    return self;
}


- (void) dealloc
{
    [_nodes release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (void) addAlternative:(Node *)node
{
    [_nodes addObject:node];
}


@end
