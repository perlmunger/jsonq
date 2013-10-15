//
//  NSObject+Additions.m
//  jsonq
//
//  Created by Matt Long on 10/3/13.
//  Copyright (c) 2013 Matt Long. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Additions.h"

@implementation NSObject (Additions)

//void getAllKeyPathsInObject(id object, NSMutableSet *keyPaths, NSString *previousKeyPath);

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}


- (NSDictionary *)classProperties
{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:propType];
            [results setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

- (NSArray*)keyPaths
{
    NSMutableSet *keyPaths = [NSMutableSet set];
    [self getAllKeyPaths:keyPaths previousKeyPath:nil];
    NSArray *sorted = [keyPaths sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]]];
    return sorted;
}

- (void)getAllKeyPaths:(NSMutableSet*)keyPaths previousKeyPath:(NSString*)previousKeyPath
{
    if ([self isKindOfClass:[NSArray class]]) {
        [(NSArray*)self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj getAllKeyPaths:keyPaths previousKeyPath:previousKeyPath];
        }];
    } else if ([self isKindOfClass:[NSDictionary class]]) {
        [(NSDictionary*)self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *keyPath = (previousKeyPath) ? [NSString stringWithFormat:@"%@.%@", previousKeyPath, key] : key;
            [keyPaths addObject:keyPath];
            [obj getAllKeyPaths:keyPaths previousKeyPath:keyPath];
        }];
    }
    
}

//void getAllKeyPathsInObject(id object, NSMutableSet *keyPaths, NSString *previousKeyPath)
//{
//    if ([object isKindOfClass:[NSArray class]]) {
//        [object enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            getAllKeyPathsInObject(obj, keyPaths, previousKeyPath);
//        }];
//    } else if ([object isKindOfClass:[NSDictionary class]]) {
//        [object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//            NSString *keyPath = (previousKeyPath) ? [NSString stringWithFormat:@"%@.%@", previousKeyPath, key] : key;
//            [keyPaths addObject:keyPath];
//            getAllKeyPathsInObject(obj, keyPaths, keyPath);
//        }];
//    }
//}

@end
