//
//  Rule.h
//  preggers
//
//  Created by Matt Diephouse on 12/28/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

@class Node;

@interface Rule : NSObject
{
    NSString *_name;
    BOOL _used;
    
    Node *_definition;
    
    NSUInteger _nextSelectorNumber;
}

@property (copy) NSString *name;
@property (readonly) BOOL defined;
@property (assign) BOOL used;

@property (readonly) NSString *selectorName;
@property (retain) Node *definition;

+ (id) ruleWithName:(NSString*)name;
- (id) initWithName:(NSString*)name;

- (NSString *) compile;
- (NSString *) nextActionSelectorName;

@end
