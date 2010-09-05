//
//  Compiler.h
//  pegged
//
//  Created by Matt Diephouse on 12/18/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

@class Rule;

@interface Compiler : NSObject
{
    NSMutableArray *_stack;
    NSMutableDictionary *_rules;
    Rule *_startRule;
    Rule *_currentRule;
    
    NSMutableArray *_properties;
    NSString *_propertyParameters;
    NSString *_propertyStars;
    NSString *_propertyType;
    
    BOOL _caseInsensitive;
    
    NSString *_className;
    NSString *_headerPath;
    NSString *_sourcePath;
}

@property (assign) BOOL caseInsensitive;

@property (copy) NSString *className;
@property (copy) NSString *headerPath;
@property (copy) NSString *sourcePath;

+ (NSString *) unique:(NSString *)identifier;

- (void) compile;

- (void) append;
- (void) beginCapture;
- (void) endCapture;

- (void) parsedAction:(NSString *)code;
- (void) parsedAlternate;
- (void) parsedClass:(NSString *)class;
- (void) parsedCode:(NSString *)code;
- (void) parsedDot;
- (void) parsedIdentifier:(NSString *)identifier;
- (void) parsedLiteral:(NSString *)literal;
- (void) parsedLookAhead;
- (void) parsedLookAhead:(NSString *)code;
- (void) parsedNegativeLookAhead;
- (void) parsedNegativeLookAhead:(NSString *)code;
- (void) parsedPlus;
- (void) parsedQuestion;
- (void) parsedRule;
- (void) parsedStar;
- (void) startRule:(NSString *)name;

- (void) parsedPropertyParameters:(NSString *)parameters;
- (void) parsedPropertyStars:(NSString *)stars;
- (void) parsedPropertyType:(NSString *)type;
- (void) parsedPropertyName:(NSString *)name;

@end
