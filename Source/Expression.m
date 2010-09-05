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

- (NSString *) compile:(NSString *)parserClassName
{
    NSMutableString *code = [NSMutableString string];
    
    NSString *selector = self.inverted ? @"invert" : @"matchOne";
    
    [code appendFormat:@"    if (![parser %@:^(%@ *parser){\n", selector, parserClassName];
    for (Node *node in self.nodes)
    {
        [code appendFormat:@"    if ([parser matchOne:^(%@ *parser){\n", parserClassName];
        [code appendString:[node compile:parserClassName]];
        [code appendString:@"    return YES;"];
        [code appendString:@"    }]) return YES;\n"];
    }
    [code appendString:@"    return NO;"];
    [code appendString:@"    }]) return NO;\n"];
    
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
