//
//  Expression.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Expression.h"

#import "Compiler.h"

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
#pragma mark Node Methods
//==================================================================================================

- (NSString *) compile:(NSString *)failLabel
{
    // add support for quantifiers
    NSMutableString *code = [NSMutableString string];
    
    NSString *index    = [[Compiler class] unique:@"index"];
    NSString *thunkpos = [[Compiler class] unique:@"yythunkpos"];
    NSString *success  = [[Compiler class] unique:@"L"];
    NSString *label     = failLabel;
    
    if (self.inverted)
    {
        label = [[Compiler class] unique:@"L"];
    }
    
    NSString *next     = nil;
    [code appendFormat:@"    NSUInteger %@=_index, %@=yythunkpos;\n", index, thunkpos];
    for (Node *node in self.nodes)
    {
        if (next)
        {
            [code appendFormat:@"%@:;\n", next];
            [code appendFormat:@"    _index=%@; yythunkpos=%@;\n", index, thunkpos];
        }
        next = node == [self.nodes lastObject] ? label : [[Compiler class] unique:@"L"];
        [code appendString:[node compile:next]];
        [code appendFormat:@"    goto %@;\n", success];
    }
    
    [code appendFormat:@"%@:;\n", success];
    
    if (self.inverted)
    {
        [code appendFormat:@"    goto %@;\n", failLabel];
        [code appendFormat:@"%@:;\n", label];
        [code appendFormat:@"    _index=%@; yythunkpos=%@;\n", index, thunkpos];
    }
    
    return code;
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
