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


@interface PEGParser : NSObject
{
    PEGParserDataSource *_dataSource;
    NSString *_string;
    NSUInteger _loc;
    
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

