//
//  Calculator.m
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import "Calculator.h"


typedef CGFloat (^BinaryOp)(CGFloat left, CGFloat right);

@implementation Calculator

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _formatter = [NSNumberFormatter new];
        _stack = [NSMutableArray new];
    }
    
    return self;
}

- (void) dealloc
{
    [_formatter release];
    [_stack release];
    
    [super dealloc];
}

- (void) performBinaryOperation:(BinaryOp)operation
{
    NSNumber *right = [_stack lastObject];
    [_stack removeLastObject];
    NSNumber *left  = [_stack lastObject];
    [_stack removeLastObject];
    CGFloat result = operation([left floatValue], [right floatValue]);
    [_stack addObject:[NSNumber numberWithFloat:result]];
}

- (void) add
{
    [self performBinaryOperation:^(CGFloat left, CGFloat right) {
        return left + right;
    }];
}

- (void) divide
{
    [self performBinaryOperation:^(CGFloat left, CGFloat right) {
        return left / right;
    }];
}

- (void) exponent
{
    [self performBinaryOperation:^(CGFloat left, CGFloat right) {
        return pow(left, right);
    }];
}

- (void) multiply
{
    [self performBinaryOperation:^(CGFloat left, CGFloat right) {
        return left * right;
    }];
}

- (void) subtract
{
    [self performBinaryOperation:^(CGFloat left, CGFloat right) {
        return left - right;
    }];
}

- (void) negative
{
    _negative = !_negative;
}

- (void) pushNumber:(NSString *)text
{
    NSNumber *number = [_formatter numberFromString:text];
    if (_negative)
        number = [NSNumber numberWithFloat:0 - [number floatValue]];
    [_stack addObject:number];
    _negative = NO;
}

- (NSNumber *) result
{
    return [_stack lastObject];
}

@end
