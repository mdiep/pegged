//
//  LookAhead.h
//  preggers
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Node.h"

@interface LookAhead : Node
{
    Node *_node;
}

@property (retain) Node *node;

+ (id) lookAheadWithNode:(Node *)node;
- (id) initWithNode:(Node *)node;

@end
