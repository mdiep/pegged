//
//  Literal.h
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Terminal.h"

@interface Literal : Terminal
{
    NSString *_string;
    
    BOOL _caseInsensitive;
}

@property (assign) BOOL caseInsensitive;
@property (readonly) NSString *string;

+ (id) literalWithString:(NSString *)string;
- (id) initWithString:(NSString *)string;

@end
