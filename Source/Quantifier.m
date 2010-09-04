//
//  Quantifier.m
//  pegged
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

- (NSString *) compile:(NSString *)parserClassName
{
    NSMutableString *code = [NSMutableString string];
    
    NSString *selector = self.repeats ? @"matchMany" : @"matchOne";
    
    if (self.optional)
    {
        [code appendString:@"    "];
    }
    else
    {
        [code appendString:@"    if (!"];
    }
    
    [code appendFormat:@"[parser %@:^(%@ *parser){\n", selector, parserClassName];
    [code appendString:[self.node compile:parserClassName]];
    [code appendString:@"    return YES;"];
    [code appendString:@"    }]"];
    
    if (self.optional)
    {
        [code appendFormat:@";\n"];
    }
    else
    {
        [code appendFormat:@") return NO;\n"];
    }
    
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
