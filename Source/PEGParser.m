//
//  PEGParser.m
//  preggers
//
//  Created by Matt Diephouse on 12/17/09.
//  This code is in the public domain.
//

#import "PEGParser.h"

#import "Compiler.h"

@interface PEGParser ()

- (BOOL) _matchDot;
- (BOOL) _matchChar:(int)c;
- (BOOL) _matchString:(char *)s;
- (BOOL) _matchClass:(unsigned char *)bits;
- (BOOL) matchEndOfLine;
- (BOOL) matchComment;
- (BOOL) matchSpace;
- (BOOL) matchRange;
- (BOOL) matchChar;
- (BOOL) matchIdentCont;
- (BOOL) matchIdentStart;
- (BOOL) matchEND;
- (BOOL) matchBEGIN;
- (BOOL) matchAction;
- (BOOL) matchDOT;
- (BOOL) matchClass;
- (BOOL) matchLiteral;
- (BOOL) matchCLOSE;
- (BOOL) matchOPEN;
- (BOOL) matchPLUS;
- (BOOL) matchSTAR;
- (BOOL) matchQUESTION;
- (BOOL) matchPrimary;
- (BOOL) matchNOT;
- (BOOL) matchSuffix;
- (BOOL) matchAND;
- (BOOL) matchPrefix;
- (BOOL) matchSLASH;
- (BOOL) matchSequence;
- (BOOL) matchExpression;
- (BOOL) matchLEFTARROW;
- (BOOL) matchIdentifier;
- (BOOL) matchEndOfFile;
- (BOOL) matchDefinition;
- (BOOL) matchSpacing;
- (BOOL) matchGrammar;

@end


@implementation PEGParser

@synthesize dataSource = _dataSource;
@synthesize compiler = _compiler;

//==================================================================================================
#pragma mark -
#pragma mark Rules
//==================================================================================================


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define YYRULECOUNT 32

#ifdef matchDEBUG
#define yyprintf(args)	{ fprintf args; fprintf(stderr," @ %s\n",[[_string substringFromIndex:_index] UTF8String]); }
#else
#define yyprintf(args)
#endif

- (BOOL) _refill
{
    if (!self.dataSource)
        return NO;
    
    NSString *nextString = [self.dataSource nextString];
    if (nextString)
    {
        nextString = [_string stringByAppendingString:nextString];
        [_string release];
        _string = [nextString retain];
    }
    _limit = [_string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    yyprintf((stderr, "refill"));
    return YES;
}

- (BOOL) _matchDot
{
    if (_index >= _limit && ![self _refill]) return NO;
    ++_index;
    return YES;
}

- (BOOL) _matchChar:(int)c
{
    if (_index >= _limit && ![self _refill]) return NO;
    if ([_string characterAtIndex:_index] == c)
    {
        ++_index;
        yyprintf((stderr, "  ok   _matchChar(%c)", c));
        return YES;
    }
    yyprintf((stderr, "  fail _matchChar(%c)", c));
    return NO;
}

- (BOOL) _matchString:(char *)s
{
    const char *cstring = [_string UTF8String];
    int saved = _index;
    while (*s)
    {
        if (_index >= _limit && ![self _refill]) return NO;
        if (cstring[_index] != *s)
        {
            _index = saved;
            return NO;
        }
        ++s;
        ++_index;
    }
    return YES;
}

- (BOOL) _matchClass:(unsigned char *)bits
{
    if (_index >= _limit && ![self _refill]) return NO;
    int c = [_string characterAtIndex:_index];
    if (bits[c >> 3] & (1 << (c & 7)))
    {
        ++_index;
        yyprintf((stderr, "  ok   _matchClass"));
        return YES;
    }
    yyprintf((stderr, "  fail _matchClass"));
    return NO;
}

- (void) yyDo:(SEL)action from:(int)begin to:(int)end
{
    while (yythunkpos >= yythunkslen)
    {
        yythunkslen *= 2;
        yythunks= realloc(yythunks, sizeof(yythunk) * yythunkslen);
    }
    yythunks[yythunkpos].begin=  begin;
    yythunks[yythunkpos].end=    end;
    yythunks[yythunkpos].action= action;
    ++yythunkpos;
}

- (void) yyText:(int)begin to:(int)end
{
    int len = end - begin;
    if (len <= 0)
    {
        [_text release];
        _text = nil;
    }
    else
    {
        _text = [_string substringWithRange:NSMakeRange(begin, end-begin)];
        [_text retain];
    }
}

- (void) yyDone
{
    int pos;
    for (pos= 0;  pos < yythunkpos;  ++pos)
    {
        yythunk *thunk= &yythunks[pos];
        [self yyText:thunk->begin to:thunk->end];
        yyprintf((stderr, "DO [%d] %s %s\n", pos, [NSStringFromSelector(thunk->action) UTF8String], yytext));
        [self performSelector:thunk->action withObject:_text];
    }
    yythunkpos= 0;
}

- (void) yyCommit
{
    NSString *newString = [_string substringFromIndex:_index];
    [_string release];
    _string = [newString retain];
    _limit -= _index;
    _index = 0;

    yybegin -= _index;
    yyend -= _index;
    yythunkpos= 0;
}

- (void) yy_7_Primary:(NSString *)text
{
    [self.compiler endCapture]; ;
}

- (void) yy_6_Primary:(NSString *)text
{
    [self.compiler beginCapture]; ;
}

- (void) yy_5_Primary:(NSString *)text
{
    [self.compiler parsedAction:text]; ;
}

- (void) yy_4_Primary:(NSString *)text
{
    [self.compiler parsedDot]; ;
}

- (void) yy_3_Primary:(NSString *)text
{
    [self.compiler parsedClass:text]; ;
}

- (void) yy_2_Primary:(NSString *)text
{
    [self.compiler parsedLiteral:text]; ;
}

- (void) yy_1_Primary:(NSString *)text
{
    [self.compiler parsedIdentifier:text]; ;
}

- (void) yy_3_Suffix:(NSString *)text
{
    [self.compiler parsedPlus]; ;
}

- (void) yy_2_Suffix:(NSString *)text
{
    [self.compiler parsedStar]; ;
}

- (void) yy_1_Suffix:(NSString *)text
{
    [self.compiler parsedQuestion]; ;
}

- (void) yy_2_Prefix:(NSString *)text
{
    [self.compiler parsedNegativeLookAhead]; ;
}

- (void) yy_1_Prefix:(NSString *)text
{
    [self.compiler parsedLookAhead]; ;
}

- (void) yy_1_Sequence:(NSString *)text
{
    [self.compiler append]; ;
}

- (void) yy_1_Expression:(NSString *)text
{
    [self.compiler parsedAlternate]; ;
}

- (void) yy_1_Definition:(NSString *)text
{
    [self.compiler startRule:text]; ;
}

- (void) yy_2_Definition:(NSString *)text
{
    [self.compiler parsedRule]; ;
}

- (BOOL) matchEndOfLine
{  int index0 = _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "EndOfLine"));
    {  int index2= _index, yythunkpos2= yythunkpos;  if (![self _matchString:"\r\n"]) goto l3;  goto l2;
    l3:;	  _index= index2; yythunkpos= yythunkpos2;  if (![self _matchChar:'\n']) goto l4;  goto l2;
    l4:;	  _index= index2; yythunkpos= yythunkpos2;  if (![self _matchChar:'\r']) goto l1;
    }
l2:;	
    yyprintf((stderr, "  ok   %s", "EndOfLine"));
    return 1;
l1:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "EndOfLine"));
    return 0;
}

- (BOOL) matchComment
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Comment"));  if (![self _matchChar:'#']) goto l5;
l6:;	
    {  int index7= _index, yythunkpos7= yythunkpos;
        {  int index8= _index, yythunkpos8= yythunkpos;  if (![self matchEndOfLine]) goto l8;  goto l7;
        l8:;	  _index= index8; yythunkpos= yythunkpos8;
        }  if (![self _matchDot]) goto l7;  goto l6;
    l7:;	  _index= index7; yythunkpos= yythunkpos7;
    }  if (![self matchEndOfLine]) goto l5;
    yyprintf((stderr, "  ok   %s", "Comment"));
    return YES;
l5:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Comment"));
    return NO;
}

- (BOOL) matchSpace
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Space"));
    {  int index10= _index, yythunkpos10= yythunkpos;  if (![self _matchChar:' ']) goto l11;  goto l10;
    l11:;	  _index= index10; yythunkpos= yythunkpos10;  if (![self _matchChar:'\t']) goto l12;  goto l10;
    l12:;	  _index= index10; yythunkpos= yythunkpos10;  if (![self matchEndOfLine]) goto l9;
    }
l10:;	
    yyprintf((stderr, "  ok   %s", "Space"));
    return YES;
l9:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Space"));
    return NO;
}

- (BOOL) matchRange
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Range"));
    {  int index14= _index, yythunkpos14= yythunkpos;  if (![self matchChar]) goto l15;  if (![self _matchChar:'-']) goto l15;  if (![self matchChar]) goto l15;  goto l14;
    l15:;	  _index= index14; yythunkpos= yythunkpos14;  if (![self matchChar]) goto l13;
    }
l14:;	
    yyprintf((stderr, "  ok   %s", "Range"));
    return YES;
l13:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Range"));
    return NO;
}

- (BOOL) matchChar
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Char"));
    {  int index17= _index, yythunkpos17= yythunkpos;  if (![self _matchChar:'\\']) goto l18;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\204\000\000\000\000\000\000\070\000\100\024\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l18;  goto l17;
    l18:;	  _index= index17; yythunkpos= yythunkpos17;  if (![self _matchChar:'\\']) goto l19;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\000\000\007\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l19;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l19;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l19;  goto l17;
    l19:;	  _index= index17; yythunkpos= yythunkpos17;  if (![self _matchChar:'\\']) goto l20;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l20;
        {  int index21= _index, yythunkpos21= yythunkpos;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l21;  goto l22;
        l21:;	  _index= index21; yythunkpos= yythunkpos21;
        }
    l22:;	  goto l17;
    l20:;	  _index= index17; yythunkpos= yythunkpos17;
        {  int index23= _index, yythunkpos23= yythunkpos;  if (![self _matchChar:'\\']) goto l23;  goto l16;
        l23:;	  _index= index23; yythunkpos= yythunkpos23;
        }  if (![self _matchDot]) goto l16;
    }
l17:;	
    yyprintf((stderr, "  ok   %s", "Char"));
    return YES;
l16:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Char"));
    return NO;
}

- (BOOL) matchIdentCont
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "IdentCont"));
    {  int index25= _index, yythunkpos25= yythunkpos;  if (![self matchIdentStart]) goto l26;  goto l25;
    l26:;	  _index= index25; yythunkpos= yythunkpos25;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\000\000\377\003\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l24;
    }
l25:;	
    yyprintf((stderr, "  ok   %s", "IdentCont"));
    return YES;
l24:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "IdentCont"));
    return NO;
}

- (BOOL) matchIdentStart
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "IdentStart"));  if (![self _matchClass:(unsigned char *)"\000\000\000\000\000\000\000\000\376\377\377\207\376\377\377\007\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l27;
    yyprintf((stderr, "  ok   %s", "IdentStart"));
    return YES;
l27:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "IdentStart"));
    return NO;
}

- (BOOL) matchEND
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "END"));  if (![self _matchChar:'>']) goto l28;  if (![self matchSpacing]) goto l28;
    yyprintf((stderr, "  ok   %s", "END"));
    return YES;
l28:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "END"));
    return NO;
}

- (BOOL) matchBEGIN
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "BEGIN"));  if (![self _matchChar:'<']) goto l29;  if (![self matchSpacing]) goto l29;
    yyprintf((stderr, "  ok   %s", "BEGIN"));
    return YES;
l29:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "BEGIN"));
    return NO;
}

- (BOOL) matchAction
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Action"));  if (![self _matchChar:'{']) goto l30;  [self yyText:yybegin to:yyend];  yybegin= _index;
l31:;	
    {  int index32= _index, yythunkpos32= yythunkpos;  if (![self _matchClass:(unsigned char *)"\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\337\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377"]) goto l32;  goto l31;
    l32:;	  _index= index32; yythunkpos= yythunkpos32;
    }  [self yyText:yybegin to:yyend];  yyend= _index;  if (![self _matchChar:'}']) goto l30;  if (![self matchSpacing]) goto l30;
    yyprintf((stderr, "  ok   %s", "Action"));
    return YES;
l30:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Action"));
    return NO;
}

- (BOOL) matchDOT
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "DOT"));  if (![self _matchChar:'.']) goto l33;  if (![self matchSpacing]) goto l33;
    yyprintf((stderr, "  ok   %s", "DOT"));
    return YES;
l33:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "DOT"));
    return NO;
}

- (BOOL) matchClass
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Class"));  if (![self _matchChar:'[']) goto l34;  [self yyText:yybegin to:yyend];  yybegin= _index;
l35:;	
    {  int index36= _index, yythunkpos36= yythunkpos;
        {  int index37= _index, yythunkpos37= yythunkpos;  if (![self _matchChar:']']) goto l37;  goto l36;
        l37:;	  _index= index37; yythunkpos= yythunkpos37;
        }  if (![self matchRange]) goto l36;  goto l35;
    l36:;	  _index= index36; yythunkpos= yythunkpos36;
    }  [self yyText:yybegin to:yyend];  yyend= _index;  if (![self _matchChar:']']) goto l34;  if (![self matchSpacing]) goto l34;
    yyprintf((stderr, "  ok   %s", "Class"));
    return YES;
l34:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Class"));
    return NO;
}

- (BOOL) matchLiteral
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Literal"));
    {  int index39= _index, yythunkpos39= yythunkpos;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\200\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l40;  [self yyText:yybegin to:yyend];  yybegin= _index;
    l41:;	
        {  int index42= _index, yythunkpos42= yythunkpos;
            {  int index43= _index, yythunkpos43= yythunkpos;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\200\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l43;  goto l42;
            l43:;	  _index= index43; yythunkpos= yythunkpos43;
            }  if (![self matchChar]) goto l42;  goto l41;
        l42:;	  _index= index42; yythunkpos= yythunkpos42;
        }  [self yyText:yybegin to:yyend];  yyend= _index;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\200\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l40;  if (![self matchSpacing]) goto l40;  goto l39;
    l40:;	  _index= index39; yythunkpos= yythunkpos39;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l38;  [self yyText:yybegin to:yyend];  yybegin= _index;
    l44:;	
        {  int index45= _index, yythunkpos45= yythunkpos;
            {  int index46= _index, yythunkpos46= yythunkpos;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l46;  goto l45;
            l46:;	  _index= index46; yythunkpos= yythunkpos46;
            }  if (![self matchChar]) goto l45;  goto l44;
        l45:;	  _index= index45; yythunkpos= yythunkpos45;
        }  [self yyText:yybegin to:yyend];  yyend= _index;  if (![self _matchClass:(unsigned char *)"\000\000\000\000\004\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"]) goto l38;  if (![self matchSpacing]) goto l38;
    }
l39:;	
    yyprintf((stderr, "  ok   %s", "Literal"));
    return YES;
l38:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Literal"));
    return NO;
}

- (BOOL) matchCLOSE
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "CLOSE"));  if (![self _matchChar:')']) goto l47;  if (![self matchSpacing]) goto l47;
    yyprintf((stderr, "  ok   %s", "CLOSE"));
    return YES;
l47:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "CLOSE"));
    return NO;
}

- (BOOL) matchOPEN
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "OPEN"));  if (![self _matchChar:'(']) goto l48;  if (![self matchSpacing]) goto l48;
    yyprintf((stderr, "  ok   %s", "OPEN"));
    return YES;
l48:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "OPEN"));
    return NO;
}

- (BOOL) matchPLUS
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "PLUS"));  if (![self _matchChar:'+']) goto l49;  if (![self matchSpacing]) goto l49;
    yyprintf((stderr, "  ok   %s", "PLUS"));
    return YES;
l49:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "PLUS"));
    return NO;
}

- (BOOL) matchSTAR
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "STAR"));  if (![self _matchChar:'*']) goto l50;  if (![self matchSpacing]) goto l50;
    yyprintf((stderr, "  ok   %s", "STAR"));
    return YES;
l50:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "STAR"));
    return NO;
}

- (BOOL) matchQUESTION
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "QUESTION"));  if (![self _matchChar:'?']) goto l51;  if (![self matchSpacing]) goto l51;
    yyprintf((stderr, "  ok   %s", "QUESTION"));
    return YES;
l51:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "QUESTION"));
    return NO;
}

- (BOOL) matchPrimary
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Primary"));
    {  int index53= _index, yythunkpos53= yythunkpos;  if (![self matchIdentifier]) goto l54;
        {  int index55= _index, yythunkpos55= yythunkpos;  if (![self matchLEFTARROW]) goto l55;  goto l54;
        l55:;	  _index= index55; yythunkpos= yythunkpos55;
        }  [self yyDo:@selector(yy_1_Primary:) from:yybegin to:yyend];  goto l53;
    l54:;	  _index= index53; yythunkpos= yythunkpos53;  if (![self matchOPEN]) goto l56;  if (![self matchExpression]) goto l56;  if (![self matchCLOSE]) goto l56;  goto l53;
    l56:;	  _index= index53; yythunkpos= yythunkpos53;  if (![self matchLiteral]) goto l57;  [self yyDo:@selector(yy_2_Primary:) from:yybegin to:yyend];  goto l53;
    l57:;	  _index= index53; yythunkpos= yythunkpos53;  if (![self matchClass]) goto l58;  [self yyDo:@selector(yy_3_Primary:) from:yybegin to:yyend];  goto l53;
    l58:;	  _index= index53; yythunkpos= yythunkpos53;  if (![self matchDOT]) goto l59;  [self yyDo:@selector(yy_4_Primary:) from:yybegin to:yyend];  goto l53;
    l59:;	  _index= index53; yythunkpos= yythunkpos53;  if (![self matchAction]) goto l60;  [self yyDo:@selector(yy_5_Primary:) from:yybegin to:yyend];  goto l53;
    l60:;	  _index= index53; yythunkpos= yythunkpos53;  if (![self matchBEGIN]) goto l61;  [self yyDo:@selector(yy_6_Primary:) from:yybegin to:yyend];  goto l53;
    l61:;	  _index= index53; yythunkpos= yythunkpos53;  if (![self matchEND]) goto l52;  [self yyDo:@selector(yy_7_Primary:) from:yybegin to:yyend];
    }
l53:;	
    yyprintf((stderr, "  ok   %s", "Primary"));
    return YES;
l52:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Primary"));
    return NO;
}

- (BOOL) matchNOT
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "NOT"));  if (![self _matchChar:'!']) goto l62;  if (![self matchSpacing]) goto l62;
    yyprintf((stderr, "  ok   %s", "NOT"));
    return YES;
l62:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "NOT"));
    return NO;
}

- (BOOL) matchSuffix
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Suffix"));  if (![self matchPrimary]) goto l63;
    {  int index64= _index, yythunkpos64= yythunkpos;
        {  int index66= _index, yythunkpos66= yythunkpos;  if (![self matchQUESTION]) goto l67;  [self yyDo:@selector(yy_1_Suffix:) from:yybegin to:yyend];  goto l66;
        l67:;	  _index= index66; yythunkpos= yythunkpos66;  if (![self matchSTAR]) goto l68;  [self yyDo:@selector(yy_2_Suffix:) from:yybegin to:yyend];  goto l66;
        l68:;	  _index= index66; yythunkpos= yythunkpos66;  if (![self matchPLUS]) goto l64;  [self yyDo:@selector(yy_3_Suffix:) from:yybegin to:yyend];
        }
    l66:;	  goto l65;
    l64:;	  _index= index64; yythunkpos= yythunkpos64;
    }
l65:;	
    yyprintf((stderr, "  ok   %s", "Suffix"));
    return YES;
l63:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Suffix"));
    return NO;
}

- (BOOL) matchAND
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "AND"));  if (![self _matchChar:'&']) goto l69;  if (![self matchSpacing]) goto l69;
    yyprintf((stderr, "  ok   %s", "AND"));
    return YES;
l69:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "AND"));
    return NO;
}

- (BOOL) matchPrefix
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Prefix"));
    {  int index71= _index, yythunkpos71= yythunkpos;  if (![self matchAND]) goto l72;  if (![self matchSuffix]) goto l72;  [self yyDo:@selector(yy_1_Prefix:) from:yybegin to:yyend];  goto l71;
    l72:;	  _index= index71; yythunkpos= yythunkpos71;  if (![self matchNOT]) goto l73;  if (![self matchSuffix]) goto l73;  [self yyDo:@selector(yy_2_Prefix:) from:yybegin to:yyend];  goto l71;
    l73:;	  _index= index71; yythunkpos= yythunkpos71;  if (![self matchSuffix]) goto l70;
    }
l71:;	
    yyprintf((stderr, "  ok   %s", "Prefix"));
    return YES;
l70:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Prefix"));
    return NO;
}

- (BOOL) matchSLASH
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "SLASH"));  if (![self _matchChar:'/']) goto l74;  if (![self matchSpacing]) goto l74;
    yyprintf((stderr, "  ok   %s", "SLASH"));
    return YES;
l74:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "SLASH"));
    return NO;
}

- (BOOL) matchSequence
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Sequence"));
    {  int index76= _index, yythunkpos76= yythunkpos;  if (![self matchPrefix]) goto l76;  goto l77;
    l76:;	  _index= index76; yythunkpos= yythunkpos76;
    }
l77:;	
l78:;	
    {  int index79= _index, yythunkpos79= yythunkpos;  if (![self matchPrefix]) goto l79;  [self yyDo:@selector(yy_1_Sequence:) from:yybegin to:yyend];  goto l78;
    l79:;	  _index= index79; yythunkpos= yythunkpos79;
    }
    yyprintf((stderr, "  ok   %s", "Sequence"));
    return YES;
l75:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Sequence"));
    return NO;
}

- (BOOL) matchExpression
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Expression"));  if (![self matchSequence]) goto l80;
l81:;	
    {  int index82= _index, yythunkpos82= yythunkpos;  if (![self matchSLASH]) goto l82;  if (![self matchSequence]) goto l82;  [self yyDo:@selector(yy_1_Expression:) from:yybegin to:yyend];  goto l81;
    l82:;	  _index= index82; yythunkpos= yythunkpos82;
    }
    yyprintf((stderr, "  ok   %s", "Expression"));
    return YES;
l80:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Expression"));
    return NO;
}

- (BOOL) matchLEFTARROW
{
    int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "LEFTARROW"));  if (![self _matchString:"<-"]) goto l83;  if (![self matchSpacing]) goto l83;
    yyprintf((stderr, "  ok   %s", "LEFTARROW"));
    return YES;
l83:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "LEFTARROW"));
    return NO;
}

- (BOOL) matchIdentifier
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Identifier"));  [self yyText:yybegin to:yyend];  yybegin= _index;
    if (![self matchIdentStart]) goto l84;
l85:;	
    {  int index86= _index, yythunkpos86= yythunkpos;  if (![self matchIdentCont]) goto l86;  goto l85;
    l86:;	  _index= index86; yythunkpos= yythunkpos86;
    }  [self yyText:yybegin to:yyend];  yyend= _index;  if (![self matchSpacing]) goto l84;
    yyprintf((stderr, "  ok   %s", "Identifier"));
    return YES;
l84:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Identifier"));
    return NO;
}

- (BOOL) matchEndOfFile
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "EndOfFile"));
    {  int index88= _index, yythunkpos88= yythunkpos;  if (![self _matchDot]) goto l88;  goto l87;
    l88:;	  _index= index88; yythunkpos= yythunkpos88;
    }
    yyprintf((stderr, "  ok   %s", "EndOfFile"));
    return YES;
l87:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "EndOfFile"));
    return NO;
}

- (BOOL) matchDefinition
{  int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Definition"));  if (![self matchIdentifier]) goto l89;  [self yyDo:@selector(yy_1_Definition:) from:yybegin to:yyend];  if (![self matchLEFTARROW]) goto l89;  if (![self matchExpression]) goto l89;  [self yyDo:@selector(yy_2_Definition:) from:yybegin to:yyend];
    yyprintf((stderr, "  ok   %s", "Definition"));
    return YES;
l89:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Definition"));
    return NO;
}

- (BOOL) matchSpacing
{
    yyprintf((stderr, "%s", "Spacing"));
l91:;	
    {  int index92= _index, yythunkpos92= yythunkpos;
        {  int index93= _index, yythunkpos93= yythunkpos;  if (![self matchSpace]) goto l94;  goto l93;
        l94:;	  _index= index93; yythunkpos= yythunkpos93;  if (![self matchComment]) goto l92;
        }
    l93:;	  goto l91;
    l92:;	  _index= index92; yythunkpos= yythunkpos92;
    }
    yyprintf((stderr, "  ok   %s", "Spacing"));
    return YES;
}

- (BOOL) matchGrammar
{
    int index0= _index, yythunkpos0= yythunkpos;
    yyprintf((stderr, "%s", "Grammar"));  if (![self matchSpacing]) goto l95;  if (![self matchDefinition]) goto l95;
l96:;	
    {  int index97= _index, yythunkpos97= yythunkpos;  if (![self matchDefinition]) goto l97;  goto l96;
    l97:;	  _index= index97; yythunkpos= yythunkpos97;
    }  if (![self matchEndOfFile]) goto l95;
    yyprintf((stderr, "  ok   %s", "Grammar"));
    return YES;
l95:;	  _index= index0; yythunkpos= yythunkpos0;
    yyprintf((stderr, "  fail %s", "Grammar"));
    return NO;
}

- (BOOL) yyparsefrom:(SEL)startRule
{
    BOOL yyok;
    if (!yythunkslen)
    {
        yythunkslen= 32;
        yythunks= malloc(sizeof(yythunk) * yythunkslen);
        yybegin= yyend= yythunkpos= 0;
    }
    if (!_string)
    {
        _string = [NSString new];
        _limit = 0;
        _index = 0;
    }
    yybegin= yyend= _index;
    yythunkpos= 0;
    
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:startRule];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self];
    [invocation setSelector:startRule];
    [invocation invoke];
    [invocation getReturnValue:&yyok];
    if (yyok) [self yyDone];
    [self yyCommit];
    
    [_string release];
    _string = nil;
    [_text release];
    _text = nil;
    
    return yyok;
}

- (BOOL) yyparse
{
    return [self yyparsefrom:@selector(matchGrammar)];
}


//==================================================================================================
#pragma mark -
#pragma mark NSObject Methods
//==================================================================================================

- (void) dealloc
{
    free(yythunks);
    
    [_string release];
    
    [super dealloc];
}


//==================================================================================================
#pragma mark -
#pragma mark Public Methods
//==================================================================================================

- (BOOL) parse
{
    NSAssert(_dataSource != nil, @"can't call -parse without specifying a data source");
    return [self yyparse];
}


- (BOOL) parseString:(NSString *)string
{
    _string = [string copy];
    _limit  = [_string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    _index  = 0;
    BOOL retval = [self yyparse];
    [_string release];
    _string = nil;
    return retval;
}


@end
