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

- (NSString *) compile:(NSString *)failLabel
{
    NSMutableString *code = [NSMutableString string];
    
    [code appendFormat:@"    if (%@%@) goto %@;\n",
     self.inverted ? @"" : @"!", [self condition], failLabel];
    
    return code;
}


- (NSString *) condition
{
    return nil;
}


@end
