//
//  Condition.h
//  pegged
//
//  Created by Matt Diephouse on 1/8/10.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Terminal.h"

@interface Condition : Terminal
{
    NSString *_expression;
}

@property (copy) NSString *expression;

+ (id) conditionWithExpression:(NSString *)expression;
- (id) initWithExpression:(NSString *)expression;

@end
