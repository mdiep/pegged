//
//  Sequence.h
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Node.h"

@interface Sequence : Node
{
    NSMutableArray *_nodes;
}

@property (readonly) NSArray *nodes;

- (void) append:(Node *)node;

@end
