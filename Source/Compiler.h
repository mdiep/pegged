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
}

- (void) append;
- (void) beginCapture;
- (void) endCapture;

- (void) parsedAction:(NSString *)literal;
- (void) parsedAlternate;
- (void) parsedClass:(NSString *)class;
- (void) parsedDot;
- (void) parsedIdentifier:(NSString *)identifier;
- (void) parsedLiteral:(NSString *)literal;
- (void) parsedLookAhead;
- (void) parsedNegativeLookAhead;
- (void) parsedPlus;
- (void) parsedQuestion;
- (void) parsedRule:(NSString *)name;
- (void) parsedStar;

@end
