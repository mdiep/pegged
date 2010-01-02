//
//  Sequence.m
//  preggers
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

- (NSString *) compile:(NSString *)failLabel
{
    NSMutableString *code = [NSMutableString string];
    
    NSString *index     = [[Compiler class] unique:@"index"];
    NSString *thunkpos  = [[Compiler class] unique:@"yythunkpos"];
    NSString *label     = failLabel;
    
    if (self.inverted)
    {
        [code appendFormat:@"    NSUInteger %@=_index, %@=yythunkpos;\n", index, thunkpos];
        label = [[Compiler class] unique:@"L"];
    }
    
    for (Node *node in self.nodes)
        [code appendString:[node compile:label]];
    
    if (self.inverted)
    {
        [code appendFormat:@"    goto %@;\n", failLabel];
        [code appendFormat:@"%@:\n", label];
        [code appendFormat:@"    _index=%@; yythunkpos=%@;\n", index, thunkpos];
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
