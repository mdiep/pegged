//
//  Calculator.h
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>


@interface Calculator : NSObject
{
    NSNumberFormatter *_formatter;
    NSMutableArray *_stack;
    
    BOOL _negative;
}

@property (readonly) NSNumber *result;

- (void) add;
- (void) divide;
- (void) exponent;
- (void) multiply;
- (void) subtract;
- (void) negative;
- (void) pushNumber:(NSString *)text;

@end
