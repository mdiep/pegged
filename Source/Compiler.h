//
//  Compiler.h
//  preggers
//
//  Created by Matt Diephouse on 12/18/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>


@interface Compiler : NSObject
{
    NSMutableArray *_stack;
    NSMutableDictionary *_rules;
}

- (void) append;
- (void) beginCapture;
- (void) endCapture;

- (void) parsedAction:(NSString *)code;
- (void) parsedAlternate;
- (void) parsedClass:(NSString *)class;
- (void) parsedDot;
- (void) parsedIdentifier:(NSString *)identifier;
- (void) parsedLiteral:(NSString *)literal;
- (void) parsedLookAhead;
- (void) parsedNegativeLookAhead;
- (void) parsedPlus;
- (void) parsedQuestion;
- (void) parsedRule;
- (void) parsedStar;
- (void) startRule:(NSString *)name;

@end
