//
//  CClass.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "CClass.h"

#include <stdlib.h>

static void setbit(unsigned char bitset[], int c, BOOL caseInsensitive, BOOL negative)
{
    if (caseInsensitive)
    {
        if (islower(c))
            setbit(bitset, toupper(c), NO, negative);
        else if (isupper(c))
            setbit(bitset, tolower(c), NO, negative);
    }
    
    if (negative)
        bitset[c >> 3] &= ~(1 << (c & 7));
    else
        bitset[c >> 3] |=  (1 << (c & 7));
}

static int nextchar(const char **cstring)
{
    int c = *(*cstring)++;
    
    if ('\\' == c && 'x' == **cstring)
    {
        ++*cstring;
        char buffer[3] = "\0\0\0";
        if (isxdigit(**cstring))
            buffer[0] = *(*cstring)++;
        if (isxdigit(**cstring))
            buffer[1] = *(*cstring)++;
        sscanf(buffer, "%x", &c);
    }
    else if ('\\' == c && **cstring)
    {
        switch (c = *(*cstring)++)
        {
            case 'a': c = '\a'; break;	/* bel */
            case 'b': c = '\b'; break;	/* bs */
            case 'e': c = '\e'; break;	/* esc */
            case 'f': c = '\f'; break;	/* ff */
            case 'n': c = '\n'; break;	/* nl */
            case 'r': c = '\r'; break;	/* cr */
            case 't': c = '\t'; break;	/* ht */
            case 'v': c = '\v'; break;	/* vt */
            default:		break;
        }
    }
    
    return c;
}

static void setbits(unsigned char bitset[], const char *cstring, BOOL caseInsensitive, BOOL negative)
{
    if (negative)
        cstring++;
    
    int prev=-1;
    while (*cstring)
    {
        int c = nextchar(&cstring);
        if ('-' == c && *cstring && prev >= 0)
        {
            for (c = nextchar(&cstring); prev <= c; ++prev)
                setbit(bitset, prev, caseInsensitive, negative);
            prev = -1;
        }
        else
            setbit(bitset, prev=c, caseInsensitive, negative);
    }
}

@implementation CClass

@synthesize caseInsensitive = _caseInsensitive;
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
        
        unsigned char bitset[32];
        memset(bitset, negative ? 255 : 0, 32);
        
        setbits(bitset, cstring, self.caseInsensitive, negative);
        
        char string[256];
        char *ptr = string;
        for (int c=0;  c < 32;  ++c)
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
