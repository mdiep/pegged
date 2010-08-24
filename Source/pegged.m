//
//  pegged.m
//  pegged
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
"pegged [--version] [--help] [--output-dir dir] [-d dir] file\n";

static int opt_version;
static int opt_help;
static struct option longopts[] = {
    { "version",    no_argument,        &opt_version,       1 },
    { "help",       no_argument,        &opt_help,          1 },
    { "output-dir", required_argument,  NULL,               'd'},
    { NULL,         0,                  NULL,               0 }
};

int main (int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *outputDir;
    int ch;
    while ((ch = getopt_long(argc, argv, "d:", longopts, NULL)) != -1)
        switch (ch)
        {
            case 'd':
                outputDir = [[[NSString stringWithUTF8String:optarg]
                              stringByExpandingTildeInPath] stringByStandardizingPath];
                break;
            case 0:
                if (opt_version)
                {
                    printf("pegged version %u.%u.%u\n",
                           (unsigned int)PEGGED_VERSION_MAJOR,
                           (unsigned int)PEGGED_VERSION_MINOR,
                           (unsigned int)PEGGED_VERSION_CHANGE);
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
    
    if (argc != 1)
    {
        printf("Usage: %s", usage_string);
        return 1;
    }
    
    NSString *path = [NSString stringWithUTF8String:argv[0]];
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
        if (!outputDir)
            outputDir = [fileWithoutExtension stringByDeletingLastPathComponent];
        outputDir = [outputDir stringByAppendingPathComponent:compiler.className];
        compiler.headerPath = [outputDir stringByAppendingPathExtension:@"h"];
        compiler.sourcePath = [outputDir stringByAppendingPathExtension:@"m"];
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
