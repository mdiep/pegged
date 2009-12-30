//
//  Action.h
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Node.h"

@interface Action : Node
{
    NSString *_code;
}

@property (copy) NSString *code;

+ (id) actionWithCode:(NSString *)code;
- (id) initWithCode:(NSString *)code;

@end
