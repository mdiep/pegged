//
//  LookAhead.m
//  preggers
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import "LookAhead.h"

#import "Compiler.h"

@implementation LookAhead

@synthesize node = _node;

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
    
    [code appendFormat:@"    NSUInteger %@=_index, %@=yythunkpos;\n", index, thunkpos];
    [code appendString:[self.node compile:failLabel]];
    [code appendFormat:@"    _index=%@; yythunkpos=%@;\n", index, thunkpos];
    
    return code;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) lookAheadWithNode:(Node *)node
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
