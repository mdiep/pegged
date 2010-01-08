//
//  Quantifier.m
//  preggers
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import "Quantifier.h"

#import "Compiler.h"

@implementation Quantifier

@synthesize node = _node;
@synthesize optional = _optional;
@synthesize repeats = _repeats;

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    [_node release];
    
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
    
    if (self.optional && self.repeats)
    {
        NSString *loop = [[Compiler class] unique:@"L"];
        NSString *exit = [[Compiler class] unique:@"L"];
        [code appendFormat:@"    ;\n"];
        [code appendFormat:@"    NSUInteger %@, %@;\n", index, thunkpos];
        [code appendFormat:@"%@:\n", loop];
        [code appendFormat:@"    %@=_index; %@=yythunkpos;\n", index, thunkpos];
        [code appendString:[self.node compile:exit]];
        [code appendFormat:@"    goto %@;\n", loop];
        [code appendFormat:@"%@:\n", exit];
        [code appendFormat:@"    _index=%@; yythunkpos=%@;\n", index, thunkpos];
    }
    else if (self.optional)
    {
        NSString *failure = [[Compiler class] unique:@"L"];
        NSString *success = [[Compiler class] unique:@"L"];
        [code appendFormat:@"    NSUInteger %@=_index, %@=yythunkpos;\n", index, thunkpos];
        [code appendString:[self.node compile:failure]];
        [code appendFormat:@"    goto %@;\n", success];
        [code appendFormat:@"%@:\n", failure];
        [code appendFormat:@"    _index=%@; yythunkpos=%@;\n", index, thunkpos];
        [code appendFormat:@"%@:\n", success];
    }
    else if (self.repeats)
    {
        [code appendString:[self.node compile:failLabel]];
        
        NSString *loop = [[Compiler class] unique:@"L"];
        NSString *exit = [[Compiler class] unique:@"L"];
        [code appendFormat:@"    ;\n"];
        [code appendFormat:@"    NSUInteger %@, %@;\n", index, thunkpos];
        [code appendFormat:@"%@:\n", loop];
        [code appendFormat:@"    %@=_index; %@=yythunkpos;\n", index, thunkpos];
        [code appendString:[self.node compile:exit]];
        [code appendFormat:@"    goto %@;\n", loop];
        [code appendFormat:@"%@:\n", exit];
        [code appendFormat:@"    _index=%@; yythunkpos=%@;\n", index, thunkpos];
    }
    else
        return [self.node compile:failLabel];
    
    return code;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) quantifierWithNode:(Node *)node
{
    return [[[[self class] alloc] initWithNode:node] autorelease];
}


- (id) initWithNode:(Node *)node
{
    self = [super init];
    
    if (self)
    {
        _node = [node retain];
    }
    
    return self;
}


@end
