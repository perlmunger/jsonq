//
//  main.m
//  jsonq
//
//  Created by Matt Long on 8/27/13.
//  Copyright (c) 2013 Matt Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Additions.h"

#import "GBSettings+Application.h"
#import "GBCommandLineParser.h"
#import "GBOptionsHelper.h"

void usage();
void parseData(NSData* data, NSString *query);
void showSchema(NSData* data);

void registerOptions(GBOptionsHelper *options) {
	GBOptionDefinition definitions[] = {
		{ 0,	nil,							@"PROJECT INFO",											GBOptionSeparator },
		{ 'p',	GBSettingKeys.path,		@"Path",										GBValueRequired },
        { 's',	GBSettingKeys.schema,	@"Print schema of document at path",							GBValueNone },
        { 'q',	GBSettingKeys.query,	@"Key path to use for query",							GBValueRequired },

		{ 0,	nil,							@"MISCELLANEOUS",											GBOptionSeparator },
		{ 0,	GBSettingKeys.printSettings,	@"Print settings for current run",							GBValueNone },
		{ 'v',	GBSettingKeys.printVersion,		@"Display version and exit",								GBValueNone|GBOptionNoPrint },
		{ '?',	GBSettingKeys.printHelp,		@"Display this help and exit",								GBValueNone|GBOptionNoPrint },
		
		{ 0, nil, nil, 0 }
	};
	[options registerOptionsFromDefinitions:definitions];
}

int main(int argc, const char * argv[])
{

  @autoreleasepool {

      GBSettings *factoryDefaults = [GBSettings mySettingsWithName:@"Factory" parent:nil];
      GBSettings *fileSettings = [GBSettings mySettingsWithName:@"File" parent:factoryDefaults];
      GBSettings *settings = [GBSettings mySettingsWithName:@"CmdLine" parent:fileSettings];
      [factoryDefaults applyFactoryDefaults];

      GBOptionsHelper *options = [[GBOptionsHelper alloc] init];
      options.applicationVersion = ^{ return @"1.0"; };
      options.applicationBuild = ^{ return @"100"; };
      options.printValuesHeader = ^{ return @"%APPNAME version %APPVERSION (build %APPBUILD)\n"; };
      options.printValuesArgumentsHeader = ^{ return @"Running with arguments:\n"; };
      options.printValuesOptionsHeader = ^{ return @"Running with options:\n"; };
      options.printValuesFooter = ^{ return @"\nEnd of values print...\n"; };
      options.printHelpHeader = ^{ return @"Usage %APPNAME [-p path, -s schema, -q query] <arguments separated by space>"; };
      options.printHelpFooter = ^{ return @"\nSwitches that don't accept value can use negative form with --no-<name> or --<name>=0 prefix."; };
      registerOptions(options);
      
      
      // Initialize command line parser and register it with all options from helper. Then parse command line.
      GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
      [options registerOptionsToCommandLineParser:parser];
      __block BOOL commandLineValid = YES;
      [parser parseOptionsWithArguments:(char**)argv count:argc block:^(GBParseFlags flags, NSString *option, id value, BOOL *stop) {
          switch (flags) {
              case GBParseFlagUnknownOption:
                  printf("Unknown command line option %s, try --help!\n", option.UTF8String);
                  commandLineValid = NO;
                  break;
              case GBParseFlagMissingValue:
                  printf("Missing value for command line option %s, try --help!\n", option.UTF8String);
                  commandLineValid = NO;
                  break;
              case GBParseFlagArgument:
                  [settings addArgument:value];
                  break;
              case GBParseFlagOption:
                  [settings setObject:value forKey:option];
                  break;
          }
      }];
      if (!commandLineValid) return 1;
      
      // NOTE: from here on, you can forget about GBOptionsHelper or GBCommandLineParser and only deal with GBSettings...
      
      // Print help or version if instructed - print help if there's no cmd line argument also...
      if (settings.printHelp || argc == 1) {
          [options printHelp];
          return 0;
      }
      if (settings.printVersion) {
          [options printHelp];
          return 0;
      }		
      
      // Print settings if necessary.
      if (settings.printSettings) {
          [options printValuesFromSettings:settings];
      }
      
      NSString *filepath = [settings valueForKey:@"path"];
      
      NSString *query  = [settings valueForKey:@"query"];
      
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
      
      if ([settings valueForKey:@"schema"]) {
          showSchema(data);
      } else {
          parseData(data, query);
      }
      
  }
    return 0;
}

void showSchema(NSData *data)
{
    id items = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSLog(@"Key Paths: %@", [items keyPaths]);
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