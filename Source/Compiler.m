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
#import "Code.h"
#import "Condition.h"
#import "Dot.h"
#import "Expression.h"
#import "Literal.h"
#import "LookAhead.h"
#import "Node.h"
#import "Quantifier.h"
#import "Rule.h"
#import "Sequence.h"
#import "Subrule.h"
#import "Version.h"

const NSString *__headerTemplate;
const NSString *__sourceTemplate;

@implementation Compiler

@synthesize caseInsensitive = _caseInsensitive;

@synthesize className  = _className;
@synthesize headerPath = _headerPath;
@synthesize sourcePath = _sourcePath;

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _stack   = [NSMutableArray new];
        _rules   = [NSMutableDictionary new];
        _actions = [NSMutableArray new];
    }
    
    return self;
}


- (void) dealloc
{
    [_stack release];
    [_rules release];
    [_actions release];
    
    [_className release];
    [_headerPath release];
    [_sourcePath release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (NSString *) unique:(NSString *)identifier
{
    static NSUInteger number = 0;
    return [NSString stringWithFormat:@"%@%u", identifier, number++];
}


- (void) compile
{
    NSAssert(self.className != nil,  @"no class name given");
    NSAssert(self.headerPath != nil, @"no path for header file");
    NSAssert(self.sourcePath != nil, @"no path for source file");
    
    NSError *error = nil;
    
    // Generate the header
    NSString *header = [NSString stringWithFormat:(NSString *)__headerTemplate, PREGGERS_VERSION_MAJOR, PREGGERS_VERSION_MINOR, PREGGERS_VERSION_CHANGE, self.className, self.className, self.className, self.className, self.className, self.className, self.className];
    [header writeToFile:self.headerPath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    // Generate the source
    NSMutableString *declarations = [NSMutableString new];
    NSMutableString *definitions  = [NSMutableString new];
    if (self.caseInsensitive)
        [declarations appendFormat:@"#define %@_CASE_INSENSITIVE\n", [self.className uppercaseString]];
    for (Action *action in _actions)
    {
        [definitions appendFormat:@"- (void) %@:(NSString *)text\n{\n%@;\n}\n\n",
         action.selectorName, action.code];
    }
    for (NSString *name in [[_rules allKeys] sortedArrayUsingSelector:@selector(compare:)])
    {
        Rule *rule = [_rules objectForKey:name];
        // Check if that the rule has been both used and defined
        if (rule.defined && !rule.used && rule != _startRule)
            fprintf(stderr, "rule '%s' defined but not used\n", [rule.name UTF8String]);
        if (rule.used && !rule.defined)
        {
            fprintf(stderr, "rule '%s' used but not defined\n", [rule.name UTF8String]);
            continue;
        }
        
        [declarations appendFormat:@"- (BOOL) %@;\n", rule.selectorName];
        [definitions appendFormat:@"- (BOOL) %@\n{\n", rule.selectorName];
        [definitions appendString:[rule compile]];
        [definitions appendFormat:@"}\n\n", rule.selectorName];
    }
    NSString *source = [NSString stringWithFormat:(NSString *)__sourceTemplate, PREGGERS_VERSION_MAJOR, PREGGERS_VERSION_MINOR, PREGGERS_VERSION_CHANGE, self.className, self.className, declarations, self.className, [self.className uppercaseString], definitions, _startRule.selectorName];
    [declarations release];
    [definitions release];
    [source writeToFile:self.sourcePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
}


//==================================================================================================
#pragma mark -
#pragma mark Parser Actions
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
    [_stack addObject:[Code codeWithString:@"yybegin = _index"]];
}


- (void) endCapture
{
    [_stack addObject:[Code codeWithString:@"yyend = _index"]];
}


- (void) parsedAction:(NSString *)code
{
    Action *action = [Action actionWithCode:code];
    action.rule = _currentRule;
    [_stack   addObject:action];
    [_actions addObject:action];
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
    CClass *cclass = [CClass cclassFromString:class];
    cclass.caseInsensitive = self.caseInsensitive;
    [_stack addObject:cclass];
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
    
    [_stack addObject:[Subrule subruleWithRule:rule]];
    rule.used = YES;
}


- (void) parsedLiteral:(NSString *)literal
{
    Literal *node = [Literal literalWithString:literal];
    node.caseInsensitive = self.caseInsensitive;
    [_stack addObject:node];
}


- (void) parsedLookAhead
{
    Node *node = [_stack lastObject];
    LookAhead *lookAhead = [LookAhead lookAheadWithNode:node];
    [_stack removeLastObject];
    
    [_stack addObject:lookAhead];
}


- (void) parsedLookAhead:(NSString *)code
{
    Condition *condition = [Condition conditionWithExpression:code];
    [_stack addObject:condition];
}


- (void) parsedNegativeLookAhead
{
    Node *node = [_stack lastObject];
    LookAhead *lookAhead = [LookAhead lookAheadWithNode:node];
    [_stack removeLastObject];
    
    [node invert];
    [_stack addObject:lookAhead];
}


- (void) parsedNegativeLookAhead:(NSString *)code
{
    Condition *condition = [Condition conditionWithExpression:code];
    [condition invert];
    [_stack addObject:condition];
}


- (void) parsedPlus
{
    Node *node = [_stack lastObject];
    Quantifier *quantifier = [Quantifier quantifierWithNode:node];
    [_stack removeLastObject];
    
    quantifier.optional = NO;
    quantifier.repeats  = YES;
    [_stack addObject:quantifier];
}


- (void) parsedQuestion
{
    Node *node = [_stack lastObject];
    Quantifier *quantifier = [Quantifier quantifierWithNode:node];
    [_stack removeLastObject];
    
    quantifier.optional = YES;
    quantifier.repeats  = NO;
    [_stack addObject:quantifier];
}


- (void) parsedRule
{
    Node *definition = [_stack lastObject];
    [_stack removeLastObject];
    Rule *rule = [_stack lastObject];
    [_stack removeLastObject];
    
    if (rule.defined)
        fprintf(stderr, "rule '%s' redefined\n", [rule.name UTF8String]);
    
    rule.definition = definition;
}


- (void) parsedStar
{
    Node *node = [_stack lastObject];
    Quantifier *quantifier = [Quantifier quantifierWithNode:node];
    [_stack removeLastObject];
    
    quantifier.optional = YES;
    quantifier.repeats  = YES;
    [_stack addObject:quantifier];
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
    if (!_startRule)
        _startRule = rule;
    _currentRule = rule;
}


@end

const NSString *__headerTemplate = @"\
//\n\
//  Generated by preggers %u.%u.%u.\n\
//\n\
\n\
#import <Foundation/Foundation.h>\n\
\n\
\n\
@class Compiler;\n\
\n\
\n\
@protocol %@DataSource;\n\
typedef NSObject<%@DataSource> %@DataSource;\n\
\n\
typedef struct { int begin, end;  SEL action; } yythunk;\n\
\n\
@interface %@ : NSObject\n\
{\n\
    %@DataSource *_dataSource;\n\
    NSString *_string;\n\
    NSUInteger _index;\n\
    NSUInteger _limit;\n\
    NSString *_text;\n\
\n\
    int	yybegin;\n\
    int	yyend;\n\
    yythunk *yythunks;\n\
    int	yythunkslen;\n\
    int yythunkpos;\n\
\n\
    Compiler *_compiler;\n\
}\n\
\n\
@property (retain) %@DataSource *dataSource;\n\
@property (retain) Compiler *compiler;\n\
\n\
- (BOOL) parse;\n\
- (BOOL) parseString:(NSString *)string;\n\
\n\
@end\n\
\n\
\n\
@protocol %@DataSource\n\
\n\
- (NSString *) nextString;\n\
\n\
@end\n\
\n\
";

const NSString *__sourceTemplate = @"\
//\n\
//  Generated by preggers %u.%u.%u.\n\
//\n\
\n\
#import \"%@.h\"\n\
\n\
#import \"Compiler.h\"\n\
\n\
@interface %@ ()\n\
\n\
- (BOOL) _matchDot;\n\
- (BOOL) _matchString:(char *)s;\n\
- (BOOL) _matchClass:(unsigned char *)bits;\n\
%@\n\
@end\n\
\n\
\n\
@implementation %@\n\
\n\
@synthesize dataSource = _dataSource;\n\
@synthesize compiler = _compiler;\n\
\n\
//==================================================================================================\n\
#pragma mark -\n\
#pragma mark Rules\n\
//==================================================================================================\n\
\n\
\n\
#include <stdio.h>\n\
#include <stdlib.h>\n\
#include <string.h>\n\
\n\
#ifdef matchDEBUG\n\
#define yyprintf(args)	{ fprintf args; fprintf(stderr,\" @ %%s\\n\",[[_string substringFromIndex:_index] UTF8String]); }\n\
#else\n\
#define yyprintf(args)\n\
#endif\n\
\n\
- (BOOL) _refill\n\
{\n\
    if (!self.dataSource)\n\
        return NO;\n\
\n\
    NSString *nextString = [self.dataSource nextString];\n\
    if (nextString)\n\
    {\n\
        nextString = [_string stringByAppendingString:nextString];\n\
        [_string release];\n\
        _string = [nextString retain];\n\
    }\n\
    _limit = [_string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];\n\
    yyprintf((stderr, \"refill\"));\n\
    return YES;\n\
}\n\
\n\
- (BOOL) _matchDot\n\
{\n\
    if (_index >= _limit && ![self _refill]) return NO;\n\
    ++_index;\n\
    return YES;\n\
}\n\
\n\
- (BOOL) _matchString:(char *)s\n\
{\n\
#ifndef %@_CASE_INSENSITIVE\n\
    const char *cstring = [_string UTF8String];\n\
#else\n\
    const char *cstring = [[_string lowercaseString] UTF8String];\n\
#endif\n\
    int saved = _index;\n\
    while (*s)\n\
    {\n\
        if (_index >= _limit && ![self _refill]) return NO;\n\
        if (cstring[_index] != *s)\n\
        {\n\
            _index = saved;\n\
    yyprintf((stderr, \"  fail _matchString\"));\n\
            return NO;\n\
        }\n\
        ++s;\n\
        ++_index;\n\
    }\n\
    yyprintf((stderr, \"  ok   _matchString\"));\n\
    return YES;\n\
}\n\
\n\
- (BOOL) _matchClass:(unsigned char *)bits\n\
{\n\
    if (_index >= _limit && ![self _refill]) return NO;\n\
    int c = [_string characterAtIndex:_index];\n\
    if (bits[c >> 3] & (1 << (c & 7)))\n\
    {\n\
        ++_index;\n\
        yyprintf((stderr, \"  ok   _matchClass\"));\n\
        return YES;\n\
    }\n\
    yyprintf((stderr, \"  fail _matchClass\"));\n\
    return NO;\n\
}\n\
\n\
- (void) yyDo:(SEL)action\n\
{\n\
    while (yythunkpos >= yythunkslen)\n\
    {\n\
        yythunkslen *= 2;\n\
        yythunks= realloc(yythunks, sizeof(yythunk) * yythunkslen);\n\
    }\n\
    yythunks[yythunkpos].begin=  yybegin;\n\
    yythunks[yythunkpos].end=    yyend;\n\
    yythunks[yythunkpos].action= action;\n\
    ++yythunkpos;\n\
}\n\
\n\
- (void) yyText:(int)begin to:(int)end\n\
{\n\
    int len = end - begin;\n\
    if (len <= 0)\n\
    {\n\
        [_text release];\n\
        _text = nil;\n\
    }\n\
    else\n\
    {\n\
        _text = [_string substringWithRange:NSMakeRange(begin, end-begin)];\n\
        [_text retain];\n\
    }\n\
}\n\
\n\
- (void) yyDone\n\
{\n\
    int pos;\n\
    for (pos= 0;  pos < yythunkpos;  ++pos)\n\
    {\n\
        yythunk *thunk= &yythunks[pos];\n\
        [self yyText:thunk->begin to:thunk->end];\n\
        yyprintf((stderr, \"DO [%%d] %%s %%s\\n\", pos, [NSStringFromSelector(thunk->action) UTF8String], [_text UTF8String]));\n\
        [self performSelector:thunk->action withObject:_text];\n\
    }\n\
    yythunkpos= 0;\n\
}\n\
\n\
- (void) yyCommit\n\
{\n\
    NSString *newString = [_string substringFromIndex:_index];\n\
    [_string release];\n\
    _string = [newString retain];\n\
    _limit -= _index;\n\
    _index = 0;\n\
\n\
    yybegin -= _index;\n\
    yyend -= _index;\n\
    yythunkpos= 0;\n\
}\n\
\n\
%@\
- (BOOL) yyparsefrom:(SEL)startRule\n\
{\n\
    BOOL yyok;\n\
    if (!yythunkslen)\n\
    {\n\
        yythunkslen= 32;\n\
        yythunks= malloc(sizeof(yythunk) * yythunkslen);\n\
        yybegin= yyend= yythunkpos= 0;\n\
    }\n\
    if (!_string)\n\
    {\n\
        _string = [NSString new];\n\
        _limit = 0;\n\
        _index = 0;\n\
    }\n\
    yybegin= yyend= _index;\n\
    yythunkpos= 0;\n\
\n\
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:startRule];\n\
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];\n\
    [invocation setTarget:self];\n\
    [invocation setSelector:startRule];\n\
    [invocation invoke];\n\
    [invocation getReturnValue:&yyok];\n\
    if (yyok) [self yyDone];\n\
    [self yyCommit];\n\
\n\
    [_string release];\n\
    _string = nil;\n\
    [_text release];\n\
    _text = nil;\n\
\n\
    return yyok;\n\
}\n\
\n\
- (BOOL) yyparse\n\
{\n\
    return [self yyparsefrom:@selector(%@)];\n\
}\n\
\n\
\n\
//==================================================================================================\n\
#pragma mark -\n\
#pragma mark NSObject Methods\n\
//==================================================================================================\n\
\n\
- (void) dealloc\n\
{\n\
    free(yythunks);\n\
\n\
    [_string release];\n\
\n\
    [super dealloc];\n\
}\n\
\n\
\n\
//==================================================================================================\n\
#pragma mark -\n\
#pragma mark Public Methods\n\
//==================================================================================================\n\
\n\
- (BOOL) parse\n\
{\n\
    NSAssert(_dataSource != nil, @\"can't call -parse without specifying a data source\");\n\
    return [self yyparse];\n\
}\n\
\n\
\n\
- (BOOL) parseString:(NSString *)string\n\
{\n\
    _string = [string copy];\n\
    _limit  = [_string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];\n\
    _index  = 0;\n\
    BOOL retval = [self yyparse];\n\
    [_string release];\n\
    _string = nil;\n\
    return retval;\n\
}\n\
\n\
\n\
@end\n\
\n\
";
