//
//  Sequence.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Sequence.h"

#import "Compiler.h"

@implementation Sequence

@synthesize nodes = _nodes;

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
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
#pragma mark Node Methods
//==================================================================================================

- (NSString *) compile:(NSString *)parserClassName
{
    NSMutableString *code = [NSMutableString string];
    
    if (self.inverted)
    {
        [code appendFormat:@"    [parser invert:^(%@ *parser){\n"];
    }
    
    for (Node *node in self.nodes)
        [code appendString:[node compile:parserClassName]];
    
    if (self.inverted)
    {
        [code appendString:@"    }];\n"];
    }
    
    return code;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (void) append:(Node *)node
{
    [_nodes addObject:node];
}


@end
