//
//  Quantifier.h
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Node.h"

@interface Quantifier : Node
{
    Node *_node;
    
    BOOL _optional;
    BOOL _repeats;
}

@property (retain) Node *node;

@property (assign) BOOL optional;
@property (assign) BOOL repeats;

+ (id) quantifierWithNode:(Node *)node;
- (id) initWithNode:(Node *)node;

@end
