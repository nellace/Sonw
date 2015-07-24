//
//  MainViewController.h
//  Snow
//
//  Created by WO on 15/7/3.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddLocationViewController.h"
#import "SettingsViewController.h"
#import "WeatherView.h"
#import "DataDownloader.h"

@interface MainViewController : UIViewController<CLLocationManagerDelegate,UIScrollViewDelegate,WeatherViewDelegate,AddLocationViewControllerDelegate,SettingsViewControllerDelegate>


- (void)updateWeatherData;

@property (nonatomic, readonly) CLLocationManager   *locationManager;
@end
