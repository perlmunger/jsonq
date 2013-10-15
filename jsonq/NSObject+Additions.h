//
//  NSObject+Additions.h
//  jsonq
//
//  Created by Matt Long on 10/3/13.
//  Copyright (c) 2013 Matt Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Additions)

- (NSDictionary *)classProperties;
- (NSArray*)keyPaths;

@end
