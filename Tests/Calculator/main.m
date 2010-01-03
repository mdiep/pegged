//
//  main.m
//  preggers
//
//  Created by Matt Diephouse on 12/17/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Compiler.h"
#import "CalcParser.h"

int main (int argc, const char * argv[])
{
    if (argc != 2)
        return 1;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSError *error = nil;
    NSString *file     = [NSString stringWithUTF8String:argv[1]];
    NSString *contents = [[NSString alloc] initWithContentsOfFile: file
                                                         encoding: NSUTF8StringEncoding
                                                            error: &error];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    
    BOOL hadError = NO;
    NSUInteger line = 1;
    for (NSString *equation in [contents componentsSeparatedByString:@"\n"])
    {
        NSArray  *parts      = [equation componentsSeparatedByString:@"="];
        NSString *expression = [parts objectAtIndex:0];
        NSNumber *result     = [formatter numberFromString:[parts lastObject]];
        
        Compiler   *compiler = [Compiler new];
        CalcParser *parser   = [CalcParser new];
        parser.compiler = compiler;
        BOOL retval = [parser parseString:expression];
        [parser release];
        if (!retval || ![result isEqualToNumber:compiler.result])
        {
            NSString *output = [NSString stringWithFormat:@"%@:%u: error: %@!=%@ (== %@)", file, line, expression, result, compiler.result];
            fprintf(stderr, "%s", [output UTF8String]);
            hadError = YES;
        }
        [compiler release];
        line++;
    }
    
    [formatter release];
    
    [pool drain];
    
    return hadError;
}
