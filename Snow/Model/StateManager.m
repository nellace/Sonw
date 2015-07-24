//
//  StateManager.m
//  Snow
//
//  Created by WO on 15/7/6.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import "StateManager.h"

@implementation StateManager

+ (TemperatureScale)temperatureScale{
    return (TemperatureScale)[[NSUserDefaults standardUserDefaults]integerForKey:@"temp_scale"];
}

+ (void)setTemperatureScale:(TemperatureScale)scale
{
    [[NSUserDefaults standardUserDefaults]setInteger:scale forKey:@"temp_scale"];
}

+ (NSDictionary *)weatherData
{
    NSData *encodeWeatherData = [[NSUserDefaults standardUserDefaults]objectForKey:@"weather_data"];
    if (encodeWeatherData) {
        return (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:encodeWeatherData];
    }
    return nil;
}

+ (void)setWeatherData:(NSDictionary *)weatherData
{
    NSData *encodedWeatherData = [NSKeyedArchiver archivedDataWithRootObject:weatherData];
    [[NSUserDefaults standardUserDefaults]setObject:encodedWeatherData forKey:@"weather_data"];
}
+ (NSArray *)weatherTags
{
    NSData *encodeWeatherTags = [[NSUserDefaults standardUserDefaults]objectForKey:@"weather_tags"];
    if (encodeWeatherTags) {
        return (NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:encodeWeatherTags];
    }
    return nil;
}


+ (void)setWeatherTags:(NSArray *)weatherTags
{
    NSData *encodedWeatherTags = [NSKeyedArchiver archivedDataWithRootObject:weatherTags];
    [[NSUserDefaults standardUserDefaults]setObject:encodedWeatherTags forKey:@"weather_tags"];
}
@end
