//
//  GbSettings+Application.m
//  GBCli
//
//  Created by Tomaž Kragelj on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GBSettings+Application.h"

@implementation GBSettings (Application)

#pragma mark - Initialization & disposal

+ (id)mySettingsWithName:(NSString *)name parent:(GBSettings *)parent {
	id result = [self settingsWithName:name parent:parent];
	if (result) {
	}
	return result;
}

#pragma mark - Project information

GB_SYNTHESIZE_COPY(NSString *, path, setPath, GBSettingKeys.path)
GB_SYNTHESIZE_COPY(NSString *, schema, setSchema, GBSettingKeys.schema)
GB_SYNTHESIZE_COPY(NSString *, query, setQuery, GBSettingKeys.query)

#pragma mark - Debugging aid

GB_SYNTHESIZE_BOOL(printSettings, setPrintSettings, GBSettingKeys.printSettings)
GB_SYNTHESIZE_BOOL(printVersion, setPrintVersion, GBSettingKeys.printVersion)
GB_SYNTHESIZE_BOOL(printHelp, setPrintHelp, GBSettingKeys.printHelp)

@end

#pragma mark - 

@implementation GBSettings (Helpers)

- (void)applyFactoryDefaults {
	self.printSettings = NO;
}

@end

#pragma mark - 

const struct GBSettingKeys GBSettingKeys = {
	.path = @"path",
	.schema = @"schema",
	.query = @"query",
	.printSettings = @"print-settings",
	.printVersion = @"version",
	.printHelp = @"help",
};