//
//  Terminal.m
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import "Terminal.h"

#import "Compiler.h"

@implementation Terminal

//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (NSString *) compile:(NSString *)parserClassName
{
    NSMutableString *code = [NSMutableString string];
    
    [code appendFormat:@"    if (%@%@) return NO;\n",
     self.inverted ? @"" : @"!", [self condition]];
    
    return code;
}


- (NSString *) condition
{
    return nil;
}


@end
