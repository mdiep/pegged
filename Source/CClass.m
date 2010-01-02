//
//  CClass.m
//  preggers
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "CClass.h"

#include <stdlib.h>

static void setbit (unsigned char bitset[], int c, BOOL negative)
{
    if (negative)
        bitset[c >> 3] &= ~(1 << (c & 7));
    else
        bitset[c >> 3] |=  (1 << (c & 7));
}

@implementation CClass

@synthesize string = _string;

//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    [_string release];
    [_repr release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Terminal Methods
//==================================================================================================

- (NSString *) condition
{
    if (!_repr)
    {
        const char *cstring = [_string UTF8String];
        BOOL negative = *cstring == '^';
        if (negative)
            cstring++;
        
        unsigned char bitset[32];
        memset(bitset, negative ? 255 : 0, 32);
        
        int c, prev=-1;
        while ((c= *cstring++))
        {
            if ('-' == c && *cstring && prev >= 0)
            {
                for (c= *cstring++;  prev <= c;  ++prev)
                    setbit(bitset, prev, negative);
                prev = -1;
            }
            else if ('\\' == c && *cstring)
            {
                switch (c = *cstring++)
                {
                    case 'a':  c= '\a'; break;	/* bel */
                    case 'b':  c= '\b'; break;	/* bs */
                    case 'e':  c= '\e'; break;	/* esc */
                    case 'f':  c= '\f'; break;	/* ff */
                    case 'n':  c= '\n'; break;	/* nl */
                    case 'r':  c= '\r'; break;	/* cr */
                    case 't':  c= '\t'; break;	/* ht */
                    case 'v':  c= '\v'; break;	/* vt */
                    default:		break;
                }
                setbit(bitset, prev=c, negative);
            }
            else
                setbit(bitset, prev=c, negative);
        }
        
        char string[256];
        char *ptr = string;
        for (c=0;  c < 32;  ++c)
            ptr += sprintf(ptr, "\\%03o", bitset[c]);
        _repr = [NSString stringWithUTF8String:string];
    }
    return [NSString stringWithFormat:@"[self _matchClass:(unsigned char *)\"%@\"]", _repr];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

+ (id) cclassFromString:(NSString *)class;
{
    return [[[[self class] alloc] initWithString:class] autorelease];
}


- (id) initWithString:(NSString *)class
{
    self = [super init];
    
    if (self)
    {
        _string   = [class copy];
    }
    
    return self;
}


@end
