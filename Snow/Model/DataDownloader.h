//
//  DataDownloader.h
//  Snow
//
//  Created by WO on 15/7/6.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeatherData;
typedef void(^WeatherDataDownloadCompletion)(WeatherData *data, NSError* error);

@interface DataDownloader : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

+ (DataDownloader *)sharedDownloader;

- (void)dataForLocation:(CLLocation *)location withTag:(NSInteger)tag completion:(WeatherDataDownloadCompletion)completion;

- (void)dataForPlacemark:(CLPlacemark *)placemark withTag:(NSInteger)tag completion:(WeatherDataDownloadCompletion)completion;
@end
