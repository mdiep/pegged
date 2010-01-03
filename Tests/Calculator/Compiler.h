//
//  Compiler.h
//  preggers
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>


@interface Compiler : NSObject
{
    NSNumberFormatter *_formatter;
    NSMutableArray *_stack;
}

@property (readonly) NSNumber *result;

- (void) add;
- (void) divide;
- (void) exponent;
- (void) multiply;
- (void) subtract;
- (void) pushNumber:(NSString *)text;

@end
