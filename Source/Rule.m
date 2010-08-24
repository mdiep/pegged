//
//  Rule.m
//  pegged
//
//  Created by Matt Diephouse on 12/28/09.
//  This code is in the public domain.
//

#import "Rule.h"

#import "Compiler.h"
#import "Node.h"

@implementation Rule

@synthesize name = _name;
@synthesize used = _used;

@synthesize definition = _definition;

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    [_name release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) ruleWithName:(NSString*)name
{
    return [[[[self class] alloc] initWithName:name] autorelease];
}


- (id) initWithName:(NSString*)name
{
    self = [super init];
    
    if (self)
    {
        _name = [name copy];
    }
    
    return self;
}


- (NSString *) compile
{
    NSMutableString *code = [NSMutableString string];
    
    NSString *index     = [[Compiler class] unique:@"index"];
    NSString *thunkpos  = [[Compiler class] unique:@"yythunkpos"];
    NSString *failLabel = [[Compiler class] unique:@"L"];
    
    [code appendFormat:@"    NSUInteger %@=_index, %@=yythunkpos;\n", index, thunkpos];
    [code appendFormat:@"    yyprintf((stderr, \"%%s\", \"%@\"));\n", self.name];
    [code appendString:[self.definition compile:failLabel]];
    [code appendFormat:@"    yyprintf((stderr, \"  ok   %%s\", \"%@\"));\n", self.name];
    [code appendFormat:@"    return YES;\n"];
    [code appendFormat:@"%@:;\n", failLabel];
    [code appendFormat:@"    _index=%@; yythunkpos=%@;\n", index, thunkpos];
    [code appendFormat:@"    yyprintf((stderr, \"  fail %%s\", \"%@\"));\n", self.name];
    [code appendFormat:@"    return NO;\n"];
    
    return code;
}


- (NSString *) nextActionSelectorName
{
    return [NSString stringWithFormat:@"yy_%u_%@", ++_nextSelectorNumber, self.name];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Properties
//==================================================================================================

- (BOOL) defined
{
    return self.definition != nil;
}


- (NSString *) selectorName
{
    return [NSString stringWithFormat:@"match%@", self.name];
}


@end
