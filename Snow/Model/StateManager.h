//
//  StateManager.h
//  Snow
//
//  Created by WO on 15/7/6.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeatherData;
typedef enum{
    fahrenheitScale = 0,
    celsiusScale
} TemperatureScale;

@interface StateManager : NSObject

+ (TemperatureScale)temperatureScale;

+ (void)setTemperatureScale:(TemperatureScale)scale;

+ (NSDictionary *)weatherData;

+ (void)setWeatherData:(NSDictionary *)weatherData;

+ (NSArray *)weatherTags;

+ (void)setWeatherTags:(NSArray *)weatherTags;



@end
