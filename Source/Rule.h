//
//  Rule.h
//  preggers
//
//  Created by Matt Diephouse on 12/28/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Node.h"

@interface Rule : Node
{
    NSString *_name;
    BOOL _used;
    
    Node *_definition;
}

@property (copy) NSString *name;
@property (readonly) BOOL defined;
@property (assign) BOOL used;

@property (retain) Node *definition;

+ (id) ruleWithName:(NSString*)name;
- (id) initWithName:(NSString*)name;

@end
