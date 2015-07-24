//
//  WeatherView.h
//  Snow
//
//  Created by WO on 15/7/9.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBLineChartView.h"

@class WeatherData;
@protocol WeatherViewDelegate <NSObject>

- (BOOL)shouldPanWeatherview;

- (void)didBeginPanningWeatherView;

- (void)didFinishPanningWeatherView;

@end

@interface WeatherView : UIView <UIGestureRecognizerDelegate,JBLineChartViewDataSource,JBLineChartViewDelegate>

@property (strong, nonatomic) id<WeatherViewDelegate> delegate;

@property (assign, nonatomic) BOOL hasData;

@property (assign, nonatomic, getter = isLocal) BOOL local;

@property (strong, nonatomic, readonly) UILabel *updatedLabel;


@property (strong, nonatomic, readonly) UILabel *conditionIconLabel;

//  Displays the description of current conditions
@property (strong, nonatomic, readonly) UILabel *conditionDescriptionLabel;

//  Displays the location whose weather data is being represented by this weather view
@property (strong, nonatomic, readonly) UILabel *locationLabel;

//  Displayes the current temperature
@property (strong, nonatomic, readonly) UILabel *currentTemperatureLabel;

//  Displays both the high and low temperatures for today
@property (strong, nonatomic, readonly) UILabel *hiloTemperatureLabel;

//  Displays the day of the week for the first forecast snapshot
@property (strong, nonatomic, readonly) UILabel *todayWeatherDescri;

//  Displays the day of the week for the second forecast snapshot
@property (strong, nonatomic, readonly) UILabel *forecastDayTwoLabel;

//  Displays the day of the week for the third forecast snapshot
@property (strong, nonatomic, readonly) UILabel *forecastDayThreeLabel;

//  Displays the icon representing the predicted conditions for the first forecast snapshot
@property (strong, nonatomic, readonly) UILabel *todayWeatherIcon;

//  Displays the icon representing the predicted conditions for the second forecast snapshot
@property (strong, nonatomic, readonly) UILabel *forecastIconTwoLabel;

//  Displays the icon representing the predicted conditions for the third forecast snapshot
@property (strong, nonatomic, readonly) UILabel *forecastIconThreeLabel;

@property (strong, nonatomic, readonly) UILabel *updateTimeLabel;

//  Indicates whether data is being downloaded for this weather view
@property (strong, nonatomic, readonly) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSArray *chartData;

@property (nonatomic, strong) JBLineChartView *lineChartView;

@end
