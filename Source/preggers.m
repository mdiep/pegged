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
#import "Version.h"

#include <getopt.h>

static const char *usage_string =
"preggers [--version] [--help] file\n";

static int opt_version;
static int opt_help;
static struct option longopts[] = {
    { "version",    no_argument, &opt_version, 1 },
    { "help",       no_argument, &opt_help,    1 },
    { NULL,         0,           NULL,         0 }
};

int main (int argc, char *argv[])
{
    int ch;
    while ((ch = getopt_long(argc, argv, "", longopts, NULL)) != -1)
        switch (ch)
        {
            case 0:
                if (opt_version)
                {
                    printf("preggers version %u.%u.%u\n",
                           (unsigned int)PREGGERS_VERSION_MAJOR,
                           (unsigned int)PREGGERS_VERSION_MINOR,
                           (unsigned int)PREGGERS_VERSION_CHANGE);
                    return 0;
                }
                else if (opt_help)
                {
                    printf("Usage: %s", usage_string);
                    return 0;
                }
                break;
            default:
                break;
        }
    argc -= optind;
    argv += optind;
    
    if (argc != 2)
    {
        printf("Usage: %s", usage_string);
        return 1;
    }
    
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
    else
    {
        fprintf(stderr, "syntax error\n");
    }

    [compiler release];

    [pool drain];
    return !retval;
}
