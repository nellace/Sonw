//
//  WeatherData.h
//  Snow
//
//  Created by WO on 15/7/6.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    CGFloat fahrenheit;
    CGFloat celsius;
}Temperature;

static inline Temperature TemperatureMake(CGFloat fahrenheit, CGFloat celsius){
    return (Temperature){fahrenheit, celsius};
}

@interface WeatherSnapshot : NSObject<NSCoding>

@property (strong, nonatomic) NSString *icon;

@property (strong, nonatomic) NSString *dayOfWeek;

@property (strong, nonatomic) NSString *conditionDescriptionDay;

@property (strong, nonatomic) NSString *conditionDescriptionNight;

@property (assign, nonatomic) Temperature currentTemperature;

@property (assign, nonatomic) Temperature highTemperature;

@property (assign, nonatomic) Temperature lowTemperature;

@property (nonatomic, retain) NSMutableArray *highTemArray;

@property (nonatomic, strong) NSMutableArray *lowTemArray;

@property (nonatomic, strong) NSString *todayWeatherDescri;

@property (nonatomic, strong) NSMutableArray *weatherDescripCode;


@end

@interface WeatherData : NSObject <NSCoding>

@property (strong, nonatomic) CLPlacemark *placemark;

@property (strong, nonatomic) WeatherSnapshot *currentSnapshots;

@property (strong, nonatomic) NSMutableArray *forecastSnapshots;

@property (strong ,nonatomic) NSDate *timeStamp;

@end
