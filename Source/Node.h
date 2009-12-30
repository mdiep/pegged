//
//  Node.h
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>


@interface Node : NSObject
{
    BOOL _inverted;
    BOOL _lookAhead;
    BOOL _optional;
    BOOL _repeats;
}

@property (assign) BOOL inverted;
@property (assign) BOOL lookAhead;
@property (assign) BOOL optional;
@property (assign) BOOL repeats;

+ (id) node;

@end
