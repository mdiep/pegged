//
//  Property.h
//  preggers
//
//  Created by Matt Diephouse on 1/10/10.
//  This code is in the public domain.
//

#import <Foundation/Foundation.h>


@interface Property : NSObject
{
    NSString *_name;
    NSString *_parameters;
    NSString *_stars;
    NSString *_type;
}

@property (copy) NSString *name;
@property (copy) NSString *parameters;
@property (copy) NSString *stars;
@property (copy) NSString *type;

- (NSString *) declaration;
- (NSString *) import;
- (NSString *) property;
- (NSString *) synthesize;
- (NSString *) variable;

@end
