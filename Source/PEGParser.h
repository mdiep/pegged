//
//  PEGParser.h
//  preggers
//
//  Created by Matt Diephouse on 12/17/09.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>


@class Compiler;


@protocol PEGParserDataSource;
typedef NSObject<PEGParserDataSource> PEGParserDataSource;

typedef struct _yythunk { int begin, end;  SEL action;  struct _yythunk *next; } yythunk;

@interface PEGParser : NSObject
{
    PEGParserDataSource *_dataSource;
    NSString *_string;
    NSUInteger _loc;
    
    char *yybuf;
    int yybuflen;
    int	yypos;
    int	yylimit;
    char * yytext;
    int	yytextlen;
    int	yybegin;
    int	yyend;
    yythunk *yythunks;
    int	yythunkslen;
    int yythunkpos;
    
    Compiler *_compiler;
}

@property (retain) PEGParserDataSource *dataSource;
@property (retain) Compiler *compiler;

- (BOOL) parse;
- (BOOL) parseString:(NSString *)string;

@end


@protocol PEGParserDataSource

- (NSString *) nextString;

@end

