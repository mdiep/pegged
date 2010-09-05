//
//  Compiler.m
//  pegged
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
#import "Property.h"
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
        _stack      = [NSMutableArray new];
        _rules      = [NSMutableDictionary new];
        _properties = [NSMutableArray new];
    }
    
    return self;
}


- (void) dealloc
{
    [_stack release];
    [_rules release];
    [_properties release];
    
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
    
    NSMutableString *properties  = [NSMutableString new];
    NSMutableString *classes     = [NSMutableString new];
    NSMutableString *imports     = [NSMutableString new];
    NSMutableString *synthesizes = [NSMutableString new];
    NSMutableString *variables   = [NSMutableString new];
    for (Property *property in _properties)
    {
        [properties  appendString:[property property]];
        [classes     appendString:[property declaration]];
        [imports     appendString:[property import]];
        [synthesizes appendString:[property synthesize]];
        [variables   appendString:[property variable]];
    }
    
    // Generate the header
    NSString *header = [NSString stringWithFormat:(NSString *)__headerTemplate, PEGGED_VERSION_MAJOR, PEGGED_VERSION_MINOR, PEGGED_VERSION_CHANGE, classes, self.className, self.className, self.className, self.className, self.className, self.className, self.className, self.className, self.className, self.className, variables, self.className, properties, self.className, self.className, self.className, self.className, self.className, self.className, self.className];
    [header writeToFile:self.headerPath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    // Generate the source
    NSMutableString *declarations = [NSMutableString new];
    NSMutableString *definitions  = [NSMutableString new];
    if (self.caseInsensitive)
        [imports appendFormat:@"#define %@_CASE_INSENSITIVE\n", [self.className uppercaseString]];
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
        
        [declarations appendFormat:@"        [self addRule:__%@ withName:@\"%@\"];\n", rule.name, rule.name];
        [definitions appendFormat:@"static %@Rule __%@ = ^(%@ *parser){\n", self.className, rule.name, self.className];
        [definitions appendString:[rule compile:self.className]];
        [definitions appendFormat:@"};\n\n"];
    }
    NSString *source = [NSString stringWithFormat:(NSString *)__sourceTemplate, PEGGED_VERSION_MAJOR, PEGGED_VERSION_MINOR, PEGGED_VERSION_CHANGE, self.className, imports, self.className, self.className, self.className, self.className, self.className, self.className, synthesizes, self.className, self.className, self.className, self.className, self.className, [self.className uppercaseString], self.className, self.className, self.className, self.className, definitions, _startRule.name, declarations, self.className];
    [declarations release];
    [definitions release];
    [source writeToFile:self.sourcePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    
    [properties release];
    [classes release];
    [imports release];
    [synthesizes release];
    [variables release];
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
    [_stack addObject:[Code codeWithString:@"[parser beginCapture]"]];
}


- (void) endCapture
{
    [_stack addObject:[Code codeWithString:@"[parser endCapture]"]];
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
    CClass *cclass = [CClass cclassFromString:class];
    cclass.caseInsensitive = self.caseInsensitive;
    [_stack addObject:cclass];
}


- (void) parsedCode:(NSString *)code
{
    [_stack addObject:[Code codeWithString:code]];
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


- (void) parsedPropertyParameters:(NSString *)parameters
{
    _propertyParameters = [parameters copy];
}


- (void) parsedPropertyStars:(NSString *)stars
{
    _propertyStars = [stars copy];
}


- (void) parsedPropertyType:(NSString *)type
{
    _propertyType = [type copy];
}


- (void) parsedPropertyName:(NSString *)name
{
    Property *property = [Property new];
    property.name = name;
    property.parameters = _propertyParameters;
    property.stars = _propertyStars;
    property.type = _propertyType;
    [_properties addObject:property];
    [property release];
    
    [_propertyParameters release];
    [_propertyStars release];
    [_propertyType release];
}


@end

const NSString *__headerTemplate = @"\
//\n\
//  Generated by pegged %u.%u.%u.\n\
//\n\
\n\
#import <Foundation/Foundation.h>\n\
\n\
\n\
%@\
@class %@;\n\
\n\
\n\
@protocol %@DataSource;\n\
typedef NSObject<%@DataSource> %@DataSource;\n\
typedef BOOL (^%@Rule)(%@ *parser);\n\
typedef void (^%@Action)(%@ *self, NSString *text);\n\
\n\
@interface %@ : NSObject\n\
{\n\
    %@DataSource *_dataSource;\n\
    NSString *_string;\n\
    NSUInteger _index;\n\
    NSUInteger _limit;\n\
    NSMutableDictionary *_rules;\n\
\n\
    BOOL _capturing;\n\
    int	yybegin;\n\
    int	yyend;\n\
    NSMutableArray *_captures;\n\
\n\
%@\
}\n\
\n\
@property (retain) %@DataSource *dataSource;\n\
%@\
\n\
- (void) addRule:(%@Rule)rule withName:(NSString *)name;\n\
\n\
- (void) beginCapture;\n\
- (void) endCapture;\n\
- (void) performAction:(%@Action)action;\n\
\n\
- (BOOL) lookAhead:(%@Rule)rule;\n\
- (BOOL) invert:(%@Rule)rule;\n\
- (BOOL) matchRule:(NSString *)ruleName;\n\
- (BOOL) matchOne:(%@Rule)rule;\n\
- (BOOL) matchMany:(%@Rule)rule;\n\
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
//  Generated by pegged %u.%u.%u.\n\
//\n\
\n\
#import \"%@.h\"\n\
\n\
%@\
\n\
@interface %@Capture : NSObject\n\
{\n\
    NSUInteger _begin;\n\
    NSUInteger _end;\n\
    %@Action _action;\n\
}\n\
@property (assign) NSUInteger begin;\n\
@property (assign) NSUInteger end;\n\
@property (copy) %@Action action;\n\
@end\n\
\n\
@implementation %@Capture\n\
@synthesize begin = _begin;\n\
@synthesize end = _end;\n\
@synthesize action = _action;\n\
- (void) dealloc\n\
{\n\
    [_action release];\n\
    [super dealloc];\n\
}\n\
@end\n\
\n\
@interface %@ ()\n\
\n\
- (BOOL) matchDot;\n\
- (BOOL) matchString:(char *)s;\n\
- (BOOL) matchClass:(unsigned char *)bits;\n\
@end\n\
\n\
\n\
@implementation %@\n\
\n\
@synthesize dataSource = _dataSource;\n\
%@\
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
\n\
- (void) beginCapture\n\
{\n\
    if (_capturing) yybegin = _index;\n\
}\n\
\n\
\n\
- (void) endCapture\n\
{\n\
    if (_capturing) yyend = _index;\n\
}\n\
\n\
\n\
- (BOOL) invert:(%@Rule)rule\n\
{\n\
    return ![self matchOne:rule];\n\
}\n\
\n\
\n\
- (BOOL) lookAhead:(%@Rule)rule\n\
{\n\
    NSUInteger index=_index;\n\
    BOOL capturing = _capturing;\n\
    _capturing = NO;\n\
    BOOL matched = rule(self);\n\
    _capturing = capturing;\n\
    _index=index;\n\
    return matched;\n\
}\n\
\n\
\n\
- (BOOL) matchDot\n\
{\n\
    if (_index >= _limit && ![self _refill]) return NO;\n\
    ++_index;\n\
    return YES;\n\
}\n\
\n\
\n\
- (BOOL) matchOne:(%@Rule)rule\n\
{\n\
    NSUInteger index=_index, captureCount=[_captures count];\n\
    if (rule(self))\n\
        return YES;\n\
    _index=index;\n\
    if ([_captures count] > captureCount)\n\
    {\n\
        NSRange rangeToRemove = NSMakeRange(captureCount, ([_captures count]-1)-captureCount);\n\
        [_captures removeObjectsInRange:rangeToRemove];\n\
    }\n\
    return NO;\n\
}\n\
\n\
\n\
- (BOOL) matchMany:(%@Rule)rule\n\
{\n\
    if (![self matchOne:rule])\n\
        return NO;\n\
    while ([self matchOne:rule])\n\
        ;\n\
    return YES;\n\
}\n\
\n\
\n\
- (BOOL) matchRule:(NSString *)ruleName\n\
{\n\
    NSArray *rules = [_rules objectForKey:ruleName];\n\
    if (![rules count])\n\
        NSLog(@\"Couldn't find rule name \\\"%%@\\\".\", ruleName);\n\
    \n\
    for (%@Rule rule in rules)\n\
        if ([self matchOne:rule])\n\
            return YES;\n\
    return NO;\n\
}\n\
\n\
\n\
- (BOOL) matchString:(char *)s\n\
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
    yyprintf((stderr, \"  fail matchString\"));\n\
            return NO;\n\
        }\n\
        ++s;\n\
        ++_index;\n\
    }\n\
    yyprintf((stderr, \"  ok   matchString\"));\n\
    return YES;\n\
}\n\
\n\
- (BOOL) matchClass:(unsigned char *)bits\n\
{\n\
    if (_index >= _limit && ![self _refill]) return NO;\n\
    int c = [_string characterAtIndex:_index];\n\
    if (bits[c >> 3] & (1 << (c & 7)))\n\
    {\n\
        ++_index;\n\
        yyprintf((stderr, \"  ok   matchClass\"));\n\
        return YES;\n\
    }\n\
    yyprintf((stderr, \"  fail matchClass\"));\n\
    return NO;\n\
}\n\
\n\
- (void) performAction:(%@Action)action\n\
{\n\
    %@Capture *capture = [%@Capture new];\n\
    capture.begin  = yybegin;\n\
    capture.end    = yyend;\n\
    capture.action = action;\n\
    [_captures addObject:capture];\n\
    [capture release];\n\
}\n\
\n\
- (NSString *) yyText:(int)begin to:(int)end\n\
{\n\
    int len = end - begin;\n\
    if (len <= 0)\n\
        return @\"\";\n\
    return [_string substringWithRange:NSMakeRange(begin, len)];\n\
}\n\
\n\
- (void) yyDone\n\
{\n\
    for (%@Capture *capture in _captures)\n\
    {\n\
        capture.action(self, [self yyText:capture.begin to:capture.end]);\n\
    }\n\
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
    [_captures removeAllObjects];\n\
}\n\
\n\
%@\
\n\
- (BOOL) _parse\n\
{\n\
    if (!_string)\n\
    {\n\
        _string = [NSString new];\n\
        _limit = 0;\n\
        _index = 0;\n\
    }\n\
    yybegin= yyend= _index;\n\
    _capturing = YES;\n\
    \n\
    BOOL matched = [self matchRule:@\"%@\"];\n\
    \n\
    if (matched)\n\
        [self yyDone];\n\
    [self yyCommit];\n\
    \n\
    [_string release];\n\
    _string = nil;\n\
    \n\
    return matched;\n\
}\n\
\n\
\n\
//==================================================================================================\n\
#pragma mark -\n\
#pragma mark NSObject Methods\n\
//==================================================================================================\n\
\n\
- (id) init\n\
{\n\
    self = [super init];\n\
    \n\
    if (self)\n\
    {\n\
        _rules = [NSMutableDictionary new];\n\
        _captures = [NSMutableArray new];\n\
%@\
    }\n\
    \n\
    return self;\n\
}\n\
\n\
\n\
- (void) dealloc\n\
{\n\
    [_string release];\n\
    [_rules release];\n\
    [_captures release];\n\
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
- (void) addRule:(%@Rule)rule withName:(NSString *)name\n\
{\n\
    NSMutableArray *rules = [_rules objectForKey:name];\n\
    if (!rules)\n\
    {\n\
        rules = [NSMutableArray new];\n\
        [_rules setObject:rules forKey:name];\n\
        [rules release];\n\
    }\n\
    \n\
    [rules addObject:rule];\n\
}\n\
\n\
\n\
- (BOOL) parse\n\
{\n\
    NSAssert(_dataSource != nil, @\"can't call -parse without specifying a data source\");\n\
    return [self _parse];\n\
}\n\
\n\
\n\
- (BOOL) parseString:(NSString *)string\n\
{\n\
    _string = [string copy];\n\
    _limit  = [_string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];\n\
    _index  = 0;\n\
    BOOL retval = [self _parse];\n\
    [_string release];\n\
    _string = nil;\n\
    return retval;\n\
}\n\
\n\
\n\
@end\n\
\n\
";
