//
//  Compiler.m
//  preggers
//
//  Created by Matt Diephouse on 12/18/09.
//  This code is in the public domain.
//

#import "Compiler.h"


#import "Action.h"
#import "CClass.h"
#import "Dot.h"
#import "Expression.h"
#import "Literal.h"
#import "Node.h"
#import "Rule.h"
#import "Sequence.h"

@implementation Compiler

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _stack = [NSMutableArray new];
        _rules = [NSMutableDictionary new];
    }
    
    return self;
}


- (void) dealloc
{
    [_stack release];
    [_rules release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (void) append
{
    Node *second = [_stack lastObject];
    [_stack removeLastObject];
    Node *first = [_stack lastObject];
    [first retain];
    [_stack removeLastObject];
    
    Sequence *sequence = nil;
    if ([first isKindOfClass:[Sequence class]])
        sequence = (Sequence *)first;
    else
    {
        sequence = [Sequence node];
        [sequence append:first];
    }
    [sequence append:second];
    [_stack addObject:sequence];
    [first release];
}


- (void) beginCapture
{
    [_stack addObject:[Action actionWithCode:@"begin capture"]];
}


- (void) endCapture
{
    [_stack addObject:[Action actionWithCode:@"end capture"]];
}


- (void) parsedAction:(NSString *)code
{
    [_stack addObject:[Action actionWithCode:code]];
}


- (void) parsedAlternate
{
    Node *second = [_stack lastObject];
    [_stack removeLastObject];
    Node *first = [_stack lastObject];
    [_stack removeLastObject];
    
    Expression *expression = nil;
    if ([first isKindOfClass:[Expression class]])
        expression = (Expression *)first;
    else
    {
        expression = [Expression node];
        [expression addAlternative:first];
    }
    [expression addAlternative:second];
    [_stack addObject:expression];
}


- (void) parsedClass:(NSString *)class
{
    [_stack addObject:[CClass cclassFromString:class]];
}


- (void) parsedDot
{
    [_stack addObject:[Dot node]];
}


- (void) parsedIdentifier:(NSString *)identifier
{
    Rule *rule = [_rules objectForKey:identifier];
    if (!rule)
    {
        rule = [Rule ruleWithName:identifier];
        [_rules setObject:rule forKey:identifier];
    }
    
    [_stack addObject:rule];
    rule.used = YES;
}


- (void) parsedLiteral:(NSString *)literal
{
    [_stack addObject:[Literal literalWithString:literal]];
}


- (void) parsedLookAhead
{
    Node *node = [_stack lastObject];
    node.lookAhead = YES;
}


- (void) parsedNegativeLookAhead
{
    Node *node = [_stack lastObject];
    node.inverted   = YES;
    node.lookAhead  = YES;
}


- (void) parsedPlus
{
    Node *node = [_stack lastObject];
    node.optional = NO;
    node.repeats  = YES;
}


- (void) parsedQuestion
{
    Node *node = [_stack lastObject];
    node.optional = YES;
    node.repeats  = NO;
}


- (void) parsedRule
{
    Node *definition = [_stack lastObject];
    [_stack removeLastObject];
    Rule *rule = [_stack lastObject];
    [_stack removeLastObject];
    rule.definition = definition;
}


- (void) parsedStar
{
    Node *node = [_stack lastObject];
    node.optional = YES;
    node.repeats  = YES;
}


- (void) startRule:(NSString *)name
{
    Rule *rule = [_rules objectForKey:name];
    if (!rule)
    {
        rule = [Rule ruleWithName:name];
        [_rules setObject:rule forKey:name];
    }
    
    [_stack addObject:rule];
}


@end
