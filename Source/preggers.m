//
//  preggers.m
//  preggers
//
//  Created by Matt Diephouse on 12/17/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>

#import "Compiler.h"
#import "PEGParser.h"

int main (int argc, const char * argv[])
{
    if (argc != 2)
        return 1;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *curDir = [[NSFileManager defaultManager] currentDirectoryPath];
    NSString *path = [curDir stringByAppendingPathComponent:[NSString stringWithUTF8String:argv[1]]];
    NSError *error = nil;
    NSString *string = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path]
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
    
    if (error)
    {
        NSLog(@"> %@", [error localizedDescription]);
        return 1;
    }
    PEGParser *parser = [PEGParser new];
    parser.compiler   = [Compiler new];
    BOOL retval = [parser parseString:string];
    [parser release];

    [pool drain];
    return !retval;
}
