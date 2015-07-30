//
//  WeatherData.m
//  Snow
//
//  Created by WO on 15/7/6.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import "WeatherData.h"

static const NSInteger _num_forecast_snapshots = 3;

@implementation WeatherSnapshot

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.icon = [aDecoder decodeObjectForKey:@"icon"];
        self.dayOfWeek = [aDecoder decodeObjectForKey:@"day_of_week"];
        self.conditionDescriptionDay = [aDecoder decodeObjectForKey:@"condition_description_day"];
        self.conditionDescriptionNight = [aDecoder decodeObjectForKey:@"condition_description_night"];
        self.currentTemperature = TemperatureMake([aDecoder decodeFloatForKey:@"c_temp_f"], [aDecoder decodeFloatForKey:@"c_temp_c"]);
        self.highTemperature = TemperatureMake([aDecoder decodeFloatForKey:@"h_temp_f"], [aDecoder decodeFloatForKey:@"h_temp_c"]);
        
        self.todayWeatherDescri =[aDecoder decodeObjectForKey:@"today_weather_descri"];
        self.highTemArray = [aDecoder decodeObjectForKey:@"h_temp_a" ];
        self.lowTemArray = [aDecoder decodeObjectForKey:@"l_temp_a"];
        self.weatherDescripCode = [aDecoder decodeObjectForKey:@"w_desc_c"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.icon forKey:@"icon"];
    [aCoder encodeObject:self.dayOfWeek forKey:@"day_of_week"];
    [aCoder encodeObject:self.conditionDescriptionDay  forKey:@"condition_description_day"];
    [aCoder encodeObject:self.conditionDescriptionDay  forKey:@"condition_description_night"];
    [aCoder encodeFloat:self.currentTemperature.fahrenheit forKey:@"c_temp_f"];
    [aCoder encodeFloat:self.currentTemperature.celsius forKey:@"c_temp_c"];
    [aCoder encodeFloat:self.highTemperature.fahrenheit forKey:@"h_temp_f"];
    [aCoder encodeFloat:self.highTemperature.celsius forKey:@"h_temp_c"];
    [aCoder encodeFloat:self.lowTemperature.fahrenheit forKey:@"l_temp_f"];
    [aCoder encodeFloat:self.lowTemperature.celsius forKey:@"l_temp_c"];
    
    [aCoder encodeObject:self.highTemArray forKey:@"h_temp_a"];
    [aCoder encodeObject:self.lowTemArray forKey:@"l_temp_a"];
    [aCoder encodeObject:self.todayWeatherDescri forKey:@"today_weather_descri"];
    [aCoder encodeObject:self.weatherDescripCode forKey:@"w_desc_c"];
}

@end

@implementation WeatherData

- (instancetype)init
{
    if (self = [super init]) {
        self.currentSnapshots = [[WeatherSnapshot alloc]init];
        self.forecastSnapshots = [[NSMutableArray alloc]init];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.placemark = [aDecoder decodeObjectForKey:@"placemark"];
        self.timeStamp = [aDecoder decodeObjectForKey:@"timestamp"];
        self.currentSnapshots = [aDecoder decodeObjectForKey:@"current_snapshot"];
        self.forecastSnapshots = [[NSMutableArray alloc]initWithCapacity:5];
        for (int i = 0; i < _num_forecast_snapshots; i++) {
            NSString *key =[NSString stringWithFormat:@"forecast_snapshot%d",i];
            WeatherSnapshot *snapshot = [aDecoder decodeObjectForKey:key];
            if (snapshot) {
                [self.forecastSnapshots addObject:snapshot];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.placemark forKey:@"placemark"];
    [aCoder encodeObject:self.timeStamp forKey:@"timestamp"];
    [aCoder encodeObject:self.currentSnapshots forKey:@"current_snapshot"];
    
    NSInteger count = [self.forecastSnapshots count];
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithFormat:@"forecast_snapshot%d",i];
        [aCoder encodeObject:[self.forecastSnapshots objectAtIndex:i] forKey:key];
    }
}
@end
