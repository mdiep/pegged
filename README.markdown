
# Pegged

Pegged is a tool for generating Objective-C recursive-decent parsers from Parsing Expression Grammars (PEGs).

This code, along with the code it generates, is in the public domain.

## SYNOPSIS

    pegged [--version] [--help] [--output-dir directory] file

## DESCRIPTION

Pegged generates Objective-C parsers from PEG grammars. The parsers it generates are re-entrant, thread-safe, and do not leak memory: they are suitable for inclusion in other programs.

Pegged reads the grammar specified in file and will create a class of the same name. A .h and a .m file will then be created in the output directory, which may be specified from the command line and defaults to the directory containing the PEG grammar. The parser class adheres to a simple interface:

    @protocol ParserDataSource;
    typedef NSObject<ParserDataSource> ParserDataSource;
    @interface Parser : NSObject
    {
    }
    @property (retain) ParserDataSource *dataSource;
    - (BOOL) parse;
    - (BOOL) parseString:(NSString *)string;
    @end
    
    @protocol ParserDataSource
    - (NSString *) nextString;
    @end

The data to be parsed may either be provided via a data source (which responds to a single selector, -nextString) or via the -parseString: selector.

## OPTIONS

    --version    Print version information and exit
    --help        Print help and exit
    --output-dir    Write generated files to the specified directory

## AN EXAMPLE

Provided here is a simple example: a basic calculator.

    @property (retain) Calculator *calculator;
    
    Equation <- Sum EndOfFile
    
    Sum <- Product ( PLUS  Product { [self.calculator add]; }
                   / MINUS Product { [self.calculator subtract]; }
                   )*

    Product <- Terminal ( MUL Terminal { [self.calculator multiply]; }
                        / DIV Terminal { [self.calculator divide];   }
                        )*
    
    Terminal <- OPEN Primary CLOSE
              / Number { [self.calculator pushNumber:text]; }
    
    Number <- < [0-9+] > _
    
    OPEN      <- '(' _
    CLOSE     <- ')' _
    
    MUL       <- '*' _
    DIV       <- '/' _
    PLUS      <- '+' _
    MINUS     <- '-' _
    _         <- ' '*
    EndOfFile <- !.

The grammar begins by specifying an options and any desired Objective-C properties. These properties are added to the generated parser class, along with the requisite member variables, @class declarations, and #imports.

It continues with a series of rules, some of which actions. These actions are performed after parsing has completed. In the case of the calculator, numbers are added to the stack and basic operations are performed through the Calculator object that was added as a property.
