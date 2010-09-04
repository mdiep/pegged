//
//  LookAhead.m
//  pegged
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

- (NSString *) compile:(NSString *)parserClassName
{
    NSMutableString *code = [NSMutableString string];
    
    [code appendFormat:@"    if (![parser lookAhead:^(%@ *parser){\n", parserClassName];
    [code appendString:[self.node compile:parserClassName]];
    [code appendString:@"    return YES;"];
    [code appendFormat:@"    }]) return NO;\n"];
    
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
