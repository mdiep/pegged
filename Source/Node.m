//
//  Node.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Node.h"


@implementation Node

@synthesize inverted    = _inverted;

//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) node
{
    return [[[self class] new] autorelease];
}


- (NSString *) compile:(NSString *)parserClassName
{
    return nil;
}


- (void) invert
{
    self.inverted = !self.inverted;
}


@end
