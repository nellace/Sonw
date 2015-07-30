//
//  DataDownloader.m
//  Snow
//
//  Created by WO on 15/7/6.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import "DataDownloader.h"
#import "Climacons.h"
#import "WeatherData.h"
#import "NSString+Substring.h"



@interface DataDownloader ()

//  Used by the downloader to determine the names of locations based on coordinates
@property (nonatomic) CLGeocoder    *geocoder;

//  API key
@property (nonatomic) NSString      *key;

@end
@implementation DataDownloader

- (instancetype)init
{
    [NSException raise:@"ingletonException" format:@"cannot be initialized using init"   ];
    return nil;
}

+(DataDownloader*)sharedDownloader
{
    static DataDownloader *shareDownloader;
    static dispatch_once_t onceTime ;
    
    dispatch_once(&onceTime, ^{
#warning Project bundle must contain a file name "API_KEY" containing a valid Wunderground API key
        NSString *path = [[NSBundle mainBundle]pathForResource:@"API_KEY" ofType:@""];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSString *apiKey = [content stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        shareDownloader = [[DataDownloader
                             alloc]initWithAPIKey:apiKey];
    });
    return shareDownloader;
}

- (instancetype)initWithAPIKey:(NSString *)key
{
    if (self = [super init]) {
        self.key = key;
        self.geocoder = [[CLGeocoder alloc]init];
    }
    return self;
}

#pragma mark Using a Downloader
- (void)dataForLocation:(CLLocation *)location placemark:(CLPlacemark *)placemark withTag:(NSInteger)tag completion:(WeatherDataDownloadCompletion)completion
{
    if (!location || !completion) {
        return;
    }
    
    NSURLRequest *request = [self urlRequestForLocation:location];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            completion(nil, connectionError);
        }else
        {
            @try {
                NSDictionary *JSON = [self serializedData:data];
                WeatherData *weatherData = [self dataFromJSON:JSON];
                if (placemark) {
                    weatherData.placemark = placemark;
                    completion (weatherData, connectionError);
                }else{
                    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                        if (placemarks) {
                            weatherData.placemark = [placemarks lastObject];
                            completion (weatherData, error);
                        }else if (error)
                        {
                            completion(nil, error);
                        }
                    }];
                }
            }
            @catch (NSException *exception) {
                completion(nil, [NSError errorWithDomain:@"WundergroundDownloader Internal State Error" code:-1 userInfo:nil]);
            }
            @finally {
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            }
        }
    }];
}

- (void)dataForLocation:(CLLocation *)location withTag:(NSInteger)tag completion:(WeatherDataDownloadCompletion)completion
{
    [self dataForLocation:location placemark:nil withTag:tag completion:completion];
}

- (void)dataForPlacemark:(CLPlacemark *)placemark withTag:(NSInteger)tag completion:(WeatherDataDownloadCompletion)completion
{
    [self dataForLocation:placemark.location placemark:placemark withTag:tag completion:completion];
}

- (NSURLRequest *)urlRequestForLocation:(CLLocation *)location
{
    static NSString *baseUrl = @"http://api.wunderground.com/api/";
    static NSString *parameters = @"/forecast/conditions/q/";
    CLLocationCoordinate2D coordinates = location.coordinate;
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@%@%f,%f.json",baseUrl,self.key, parameters, coordinates.latitude, coordinates.longitude];
    //
    NSURL *url = [NSURL URLWithString:API_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return request;
}

- (NSDictionary *)serializedData:(NSData *)data
{
    NSError *JSONSerializationError;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&JSONSerializationError];
    if (JSONSerializationError) {
        [NSException raise:@"JSON Serialization Error" format:@"Failed to parse weather data"];
    }
    return JSON;
}

- (WeatherData *)dataFromJSON:(NSDictionary *)JSON
{
    
    NSArray *forecastday = [[[JSON objectForKey:@"HeWeather data service 3.0"]firstObject]objectForKey:@"daily_forecast"];
    NSDictionary *nowCondition =[[[JSON objectForKey:@"HeWeather data service 3.0"]firstObject]objectForKey:@"now"];
    
//    NSArray *currentObservation = [JSON objectForKey:@"current_observation"];
//    NSArray *forecast = [JSON objectForKey:@"forecast"];
//    NSArray *simpleforecast = [forecast valueForKey:@"simpleforecast"];
//    NSArray *forecastday = [simpleforecast valueForKey:@"forecastday"];
    NSDictionary *forecastday0                       = [forecastday      objectAtIndex:0];
//    NSArray *forecastday1                       = [forecastday      objectAtIndex:1];
//    NSArray *forecastday2                       = [forecastday      objectAtIndex:2];
//    NSArray *forecastday3                       = [forecastday      objectAtIndex:3];
    
    
    
    WeatherData *data =[[WeatherData alloc]init];
    data.currentSnapshots.highTemArray = [[NSMutableArray alloc]init];
    data.currentSnapshots.lowTemArray = [[NSMutableArray alloc]init];
    data.currentSnapshots.weatherDescripCode  = [NSMutableArray new];
    
    for (int i = 0; i < ALL_FORCAST_DAY; i++) {
        NSArray *forecastArray = [forecastday objectAtIndex:i];
        NSString *highTem = [[forecastArray valueForKey:@"tmp"]  valueForKey:@"max"];
        NSString *lowTem = [[forecastArray valueForKey:@"tmp"]  valueForKey:@"min"];
        NSString *weatherIconCode = [[forecastArray valueForKey:@"cond"]valueForKey:@"code_d"];
        
        [data.currentSnapshots.highTemArray addObject:highTem];
        [data.currentSnapshots.lowTemArray addObject:lowTem];
        [data.currentSnapshots.weatherDescripCode addObject:weatherIconCode];
    }
    
    CGFloat currentHighTemperatureF             = [[[forecastday0 valueForKey:@"tmp"]  valueForKey:@"max"]doubleValue];
    CGFloat currentLowTemperatureF              = [[[forecastday0 valueForKey:@"tmp"]   valueForKey:@"min"]doubleValue];
    CGFloat currentTemperatureF                 = [[nowCondition objectForKey:@"tmp"]doubleValue];
    
    NSString *todayDayDescription = [[forecastday0 objectForKey:@"cond"]objectForKey:@"txt_d"];
    NSString *todayNightDescription = [[forecastday0 objectForKey:@"cond"]objectForKey:@"txt_n"];
    if ([todayDayDescription isEqualToString:todayNightDescription]) {
        data.currentSnapshots.todayWeatherDescri = todayDayDescription;
    }else
    {
        data.currentSnapshots.todayWeatherDescri = [NSString stringWithFormat:@"%@转%@",todayDayDescription,todayNightDescription];
    }
    
    data.currentSnapshots.dayOfWeek = [forecastday0 valueForKey:@"date"];
//    data.currentSnapshots.conditionDescriptionDay = [[nowCondition objectForKey:@"cond"] objectForKey:@"txt_d"];
//    data.currentSnapshots.conditionDescriptionNight = [[nowCondition objectForKey:@"cond"] objectForKey:@"txt_n"];
//    data.currentSnapshots.icon = [self iconForCondition:data.currentSnapshots.conditionDescription];
    data.currentSnapshots.highTemperature = TemperatureMake(currentHighTemperatureF, 0);
    data.currentSnapshots.lowTemperature = TemperatureMake(currentLowTemperatureF, 0);
    data.currentSnapshots.currentTemperature = TemperatureMake(currentTemperatureF, 0);
    
//    WeatherSnapshot *forecastOne = [[WeatherSnapshot alloc]init];
//    forecastOne.conditionDescriptionDay = [[forecastday1 valueForKey:@"cond"]objectForKey:@"txt_d"];
//    forecastOne.conditionDescriptionNight = [[forecastday1 valueForKey:@"cond"]objectForKey:@"txt_n"];
//    
////    forecastOne.icon = [self iconForCondition:forecastOne.conditionDescription];
//    forecastOne.dayOfWeek = [forecastday1 valueForKey:@"date"] ;
//    [data.forecastSnapshots addObject:forecastOne];
//    
//    WeatherSnapshot *forecastTwo = [[WeatherSnapshot alloc]init];
//    forecastTwo.conditionDescriptionDay = [[forecastday2 valueForKey:@"cond"]objectForKey:@"txt_d"];
//    forecastTwo.conditionDescriptionNight = [[forecastday2 valueForKey:@"cond"]objectForKey:@"txt_n"];
////    forecastTwo.icon                            = [self iconForCondition:forecastTwo.conditionDescription];
//    forecastTwo.dayOfWeek                       = [forecastday2 valueForKey:@"date"] ;
//    [data.forecastSnapshots addObject:forecastTwo];
//    
//    WeatherSnapshot *forecastThree           = [[WeatherSnapshot alloc]init];
//    forecastThree.conditionDescriptionDay = [[forecastday3 valueForKey:@"cond"]objectForKey:@"txt_d"];
//    forecastThree.conditionDescriptionNight = [[forecastday3 valueForKey:@"cond"]objectForKey:@"txt_n"];
////    forecastThree.icon                          = [self iconForCondition:forecastThree.conditionDescription];
//    forecastThree.dayOfWeek                     = [forecastday3 valueForKey:@"date"] ;
//    [data.forecastSnapshots addObject:forecastThree];
    
    data.timeStamp = [NSDate date];
    
    return data;
}

- (NSString *)iconForCondition:(NSString *)condition
{
    NSString *iconName = [NSString stringWithFormat:@"%c", ClimaconSun];
    NSString *lowercaseCondition = [condition lowercaseString];
    
    if([lowercaseCondition contains:@"clear"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconSun];
    } else if([lowercaseCondition contains:@"cloud"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconCloud];
    } else if([lowercaseCondition contains:@"drizzle"]  ||
              [lowercaseCondition contains:@"rain"]     ||
              [lowercaseCondition contains:@"thunderstorm"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconRain];
    } else if([lowercaseCondition contains:@"snow"]     ||
              [lowercaseCondition contains:@"hail"]     ||
              [lowercaseCondition contains:@"ice"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconSnow];
    } else if([lowercaseCondition contains:@"fog"]      ||
              [lowercaseCondition contains:@"overcast"] ||
              [lowercaseCondition contains:@"smoke"]    ||
              [lowercaseCondition contains:@"dust"]     ||
              [lowercaseCondition contains:@"ash"]      ||
              [lowercaseCondition contains:@"mist"]     ||
              [lowercaseCondition contains:@"haze"]     ||
              [lowercaseCondition contains:@"spray"]    ||
              [lowercaseCondition contains:@"squall"]) {
        iconName = [NSString stringWithFormat:@"%c", ClimaconHaze];
    }
    return iconName;
}

@end
