//
//  CClass.h
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Terminal.h"

@interface CClass : Terminal
{
    NSString *_string;
    NSString *_repr;
}

@property (readonly) NSString *string;

+ (id) cclassFromString:(NSString *)class;
- (id) initWithString:(NSString *)class;

@end
