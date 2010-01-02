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
    
    NSString *path = [NSString stringWithUTF8String:argv[1]];
    if (![path isAbsolutePath])
        path = [[[NSFileManager defaultManager]
                 currentDirectoryPath] stringByAppendingPathComponent:path];
    NSError *error = nil;
    NSString *string = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path]
                                                encoding:NSUTF8StringEncoding
                                                   error:&error];
    
    if (error)
    {
        NSLog(@"> %@", [error localizedDescription]);
        return 1;
    }
    Compiler  *compiler = [Compiler new];
    PEGParser *parser   = [PEGParser new];
    parser.compiler = compiler;
    BOOL retval = [parser parseString:string];
    [parser release];
    if (retval)
    {
        NSString *fileWithoutExtension = [path stringByDeletingPathExtension];
        compiler.className  = [fileWithoutExtension lastPathComponent];
        compiler.headerPath = [fileWithoutExtension stringByAppendingPathExtension:@"h"];
        compiler.sourcePath = [fileWithoutExtension stringByAppendingPathExtension:@"m"];
        [compiler compile];
    }
    [compiler release];

    [pool drain];
    return !retval;
}
