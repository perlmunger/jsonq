//
//  main.m
//  jsonq
//
//  Created by Matt Long on 8/27/13.
//  Copyright (c) 2013 Matt Long. All rights reserved.
//

#import <Foundation/Foundation.h>

void usage();
void parseData(NSData* data, NSString *query);

int main(int argc, const char * argv[])
{

  @autoreleasepool {

    if (argc < 3) {
      usage();
      return 1;
    }

    NSString *filepath = [NSString stringWithUTF8String:argv[1]];

    NSString *query  = [NSString stringWithUTF8String:argv[2]];

    NSData *data = nil;
    if ([filepath hasPrefix:@"http://"] || [filepath hasPrefix:@"https://"]) {
      NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:filepath]];
      [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
      
      NSURLResponse *response = nil;
      data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];

    } else {
      NSFileManager *manager = [NSFileManager defaultManager];
      if (![manager fileExistsAtPath:[NSString stringWithUTF8String:argv[1]] isDirectory:NO]) {
        NSLog(@"File doesn't exist.");
        return 1;
      }
      
      data = [NSData dataWithContentsOfFile:filepath];
      
    }

    parseData(data, query);

  }
  return 0;
}

void parseData(NSData* data, NSString *query)
{
  id items = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  id result = nil;
  if ([items isKindOfClass:[NSDictionary class]]) {
    if ([query rangeOfString:@"."].length > 0) {
      result = [items valueForKeyPath:query];
    } else {
      result = [items valueForKey:query];
    }
  } else if ([items isKindOfClass:[NSArray class]]) {
    result = [items valueForKeyPath:query];
  }
  
  if ([result isKindOfClass:[NSArray class]]) {
    NSLog(@"%@", [result componentsJoinedByString:@"\n"]);
  } else {
    NSLog(@"%@", result);
  }
  
}

void usage()
{
  NSLog(@"usage: jsonq [filename | url] [query]");
}