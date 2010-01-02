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
}

@property (assign) BOOL inverted;

+ (id) node;

- (NSString *) compile:(NSString *)failLabel;
- (void) invert;

@end
