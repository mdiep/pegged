//
//  CClass.h
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Node.h"

@interface CClass : Node
{
    NSString *_string;
}

@property (readonly) NSString *string;

+ (id) cclassFromString:(NSString *)class;
- (id) initWithString:(NSString *)class;

@end
