//
//  Action.m
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Action.h"

#import "Rule.h"

@implementation Action

@synthesize code = _code;
@synthesize rule = _rule;

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    [_selectorName release];
    [_code release];
    [_rule release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Node Methods
//==================================================================================================

- (NSString *) compile:(NSString *)failLabel
{
    return [NSString stringWithFormat:@"    [self yyDo:@selector(%@:)];\n",
            self.selectorName];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) actionWithCode:(NSString *)code
{
    return [[[[self class] alloc] initWithCode:code] autorelease];
}


- (id) initWithCode:(NSString *)code
{
    self = [super init];
    
    if (self)
    {
        _code = [code copy];
    }
    
    return self;
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (NSString *) selectorName
{
    if (!_selectorName)
        _selectorName = [[self.rule nextActionSelectorName] retain];
    return _selectorName;
}


@end
