//
//  MainViewController.m
//  Snow
//
//  Created by WO on 15/7/3.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import "MainViewController.h"
#import "WeatherData.h"
#import "StateManager.h"
#import "PagingScrollView.h"
#import "UIImage+ImageEffects.h"


/** Constants */
#define MIN_TIME_SINCE_UPDATE          0
#define MAX_NUM_WEATHER_VIEWS          5
#define LOCAL_WEATHER_VIEW_TAG         0
#define DEFAULT_BACKGROUND_GRADIENT    @"gradient5"

@interface MainViewController ()

@property (strong, nonatomic) CLLocationManager     *locationManager;

//  Dictionary of all weather data being managed by the app
@property (strong, nonatomic) NSMutableDictionary   *weatherData;

//  Ordered-List of weather tags
@property (strong, nonatomic) NSMutableArray        *weatherTags;

//  Formats weather data timestamps
@property (strong, nonatomic) NSDateFormatter       *dateFormatter;

@property (assign, nonatomic) BOOL                  isScrolling;

// -----
// @name View Controllers
// -----

//  View controller for changing settings
@property (strong, nonatomic) SettingsViewController     *settingsViewController;

//  View controller for adding new locations
@property (strong, nonatomic) AddLocationViewController  *addLocationViewController;

// -----
// @name Subviews
// -----

//  Dark, semi-transparent view to sit above the homescreen
@property (strong, nonatomic) UIView              *darkenedBackgroundView;

//  Label displaying the Sol° logo
@property (strong, nonatomic) UILabel             *LogoLabel;

//  Label displaying the name of the app
@property (strong, nonatomic) UILabel             *TitleLabel;


@property (strong, nonatomic)  UIImageView        *blurredOverlayView;


@property (strong, nonatomic) UIButton            *settingsButton;


@property (strong, nonatomic) UIButton            *addLocationButton;


@property (strong, nonatomic) UIPageControl       *pageControl;


@property (strong, nonatomic) PagingScrollView *pagingScrollView;

@end

@implementation MainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        NSDictionary *savedWeatherData = [StateManager weatherData];
        if (savedWeatherData) {
            self.weatherData = [NSMutableDictionary dictionaryWithDictionary:savedWeatherData];
        }else
        {
            self.weatherData = [NSMutableDictionary dictionaryWithCapacity:5];
        }
        
        NSArray *savedWeathertags = [StateManager weatherTags];
        if (savedWeathertags) {
            self.weatherTags = [NSMutableArray arrayWithArray:savedWeathertags];
        }else
        {
            self.weatherTags = [NSMutableArray arrayWithCapacity:4];
        }
        
        self.dateFormatter = [[NSDateFormatter alloc]init];
        [self.dateFormatter setDateFormat:@"EEE MMM d, h:mm a"];
        
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.distanceFilter = 3000;
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        [self.locationManager requestWhenInUseAuthorization];
        
        
        [self initializeSubviews];
        [self initializeSettingsButton];
        [self initializeAddLocationButton];
        [self initalizeViewControllers];
        
        
        if ([self.weatherData count] >= MAX_NUM_WEATHER_VIEWS) {
            self.addLocationButton.hidden = YES;
        }
        
        [self.view bringSubviewToFront:self.blurredOverlayView];
    }
    return self;
}

- (void)initalizeViewControllers
{
    self.addLocationViewController =[[AddLocationViewController alloc]init];
    self.addLocationViewController.delegate = self;
    
    self.settingsViewController = [[SettingsViewController alloc]init];
    self.settingsViewController.delegate = self;
    
//    [self initializeNonlocalWeatherViews];
}

- (void)initializeSubviews
{
    self.darkenedBackgroundView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.darkenedBackgroundView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
    [self.view addSubview:self.darkenedBackgroundView];
    
    self.LogoLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCR_WIDTH / 2  , SCR_HEIGHT / 2)];
    self.LogoLabel.center =CGPointMake(self.view.center.x, 0.5 * self.view.center.y);
    self.LogoLabel.font = [UIFont fontWithName:CLIMACONS_FONT size:200];
    self.LogoLabel.backgroundColor = [UIColor clearColor];
    self.LogoLabel.textColor = [UIColor whiteColor];
    self.LogoLabel.textAlignment = NSTextAlignmentCenter;
    self.LogoLabel.text = [NSString stringWithFormat:@"%c", ClimaconSun];
    [self.view addSubview:self.LogoLabel];
    
    self.TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64)];
    self.TitleLabel.center = self.view.center;
    self.TitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:64];
    self.TitleLabel.backgroundColor = [UIColor clearColor];
    self.TitleLabel.textColor = [UIColor whiteColor];
    self.TitleLabel.textAlignment = NSTextAlignmentCenter;
    self.TitleLabel.text = @"Snow";
    [self.view addSubview:self.TitleLabel];
    
    self.pagingScrollView = [[PagingScrollView alloc]initWithFrame:self.view.bounds];
    self.pagingScrollView.delegate = self;
    self.pagingScrollView.bounces = NO;
    [self.view addSubview:self.pagingScrollView];
    
    self.pageControl = [[UIPageControl alloc]initWithFrame: CGRectMake(0, SCR_HEIGHT - 32,
                                                                       SCR_WIDTH, 32)];
    [self.pageControl setHidesForSinglePage:YES];
    [self.view addSubview:self.pageControl];
    
    self.blurredOverlayView = [[UIImageView alloc]initWithImage:[[UIImage alloc]init]];
    self.blurredOverlayView.alpha = 0.0;
    [self.blurredOverlayView setFrame:self.view.bounds];
//    [self.view addSubview:self.blurredOverlayView];
    
}

- (void)initializeSettingsButton
{
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [self.settingsButton setTintColor:[UIColor whiteColor]];
    [self.settingsButton setFrame:CGRectMake(4, CGRectGetHeight(self.view.bounds) - 48, 44, 44)];
    [self.settingsButton setShowsTouchWhenHighlighted:YES];
    [self.settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingsButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SettingsButton Methods

- (void)settingsButtonPressed
{
    NSMutableArray *location = [[NSMutableArray alloc]initWithCapacity:4
                                ];
    for (WeatherView*weatherView in self.pagingScrollView.subviews) {
        if (weatherView.tag != LOCAL_WEATHER_VIEW_TAG) {
            NSArray *locationMetaData = @[weatherView.locationLabel.text,[NSNumber numberWithInteger:weatherView.tag]];
            [location addObject:locationMetaData];
        }
    }
    self.settingsViewController.locations = location;
    [self presentViewController:self.settingsViewController animated:YES completion:nil];
    
    if ([self.pagingScrollView.subviews count] > 0) {
        [self showBlurredOverlayView:YES];
    }else
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.LogoLabel.alpha = 0.0;
            self.TitleLabel.alpha = 0.0;
        }];
    }
}

- (void)initializeLocalWeatherView
{
    WeatherView *localWeatherView = [[WeatherView alloc]initWithFrame:self.view.bounds];
    localWeatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:DEFAULT_BACKGROUND_GRADIENT]];
    localWeatherView.local  = YES;
    localWeatherView.delegate = self;
    localWeatherView.tag = LOCAL_WEATHER_VIEW_TAG;
    [self.pagingScrollView addSubview:localWeatherView];
    self.pageControl.numberOfPages += 1;
    
    WeatherData *localWeatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:LOCAL_WEATHER_VIEW_TAG]];
    if (localWeatherData) {
        [self updateWeatherView:localWeatherView withData:localWeatherData];
    }
}

- (void)initializeNonlocalWeatherViews
{
    for (NSNumber *tagNumber in self.weatherTags) {
        WeatherData *weatherData = [self.weatherData objectForKey:tagNumber];
        if (weatherData) {
            WeatherView *weatherView =[[WeatherView alloc]initWithFrame:self.view.bounds];
            weatherView.delegate = self;
            weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient5.png"]];
            weatherView.tag = tagNumber.integerValue;
            weatherView.local = NO;
            self.pageControl.numberOfPages += 1;
            [self.pagingScrollView addSubview:weatherView isLaunch:YES];
            [self updateWeatherView:weatherView withData:weatherData];
        }
    }
}

#pragma mark Using a MainViewController

- (void)showBlurredOverlayView:(BOOL)show
{
    [UIView animateWithDuration:0.25 animations:^{
        self.blurredOverlayView.alpha = (show) ? 1.0 : 0.0;
    }];
}

- (void)setBlurredOverlayImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.view.layer renderInContext:context];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImage *blurred = [image applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:0.15 alpha:0.5] saturationDeltaFactor:1.5 maskImage:nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.blurredOverlayView.image = blurred;
        });
    });
}

- (void)initializeAddLocationButton
{
    self.addLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UILabel *plusLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [plusLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:40]];
    [plusLabel setTextAlignment:NSTextAlignmentCenter];
    [plusLabel setTextColor:[UIColor whiteColor]];
    [plusLabel setText:@"+"];
    [self.addLocationButton addSubview:plusLabel];
    [self.addLocationButton addSubview:plusLabel];
    [self.addLocationButton setFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 44, CGRectGetHeight(self.view.bounds) - 54, 44, 44)];
    [self.addLocationButton setShowsTouchWhenHighlighted:YES];
    [self.addLocationButton addTarget:self action:@selector(addLocationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addLocationButton];
    
}

#pragma mark locationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self initializeLocalWeatherView];
        [self initializeNonlocalWeatherViews];
        [self setBlurredOverlayImage];
        [self updateWeatherData];
    }else if (status != kCLAuthorizationStatusNotDetermined)
    {
        [self initializeNonlocalWeatherViews];
        [self setBlurredOverlayImage];
        [self updateWeatherData];
    }else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        if ([self.pagingScrollView.subviews count] == 0) {
            [self presentViewController:self.addLocationViewController animated:YES completion:nil];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (WeatherView *weatherView in self.pagingScrollView.subviews) {
        if (weatherView.local == YES) {
            WeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
            if ([[NSDate date] timeIntervalSinceDate:weatherData.timeStamp] >= MIN_TIME_SINCE_UPDATE || !weatherView.hasData) {
                if (weatherView.hasData) {
                    weatherView.activityIndicator.center = CGPointMake(weatherView.center.x, 1.8 * weatherView.center.y);
                }
                [weatherView.activityIndicator startAnimating];
                [[DataDownloader sharedDownloader]dataForLocation:[locations lastObject] withTag:weatherView.tag completion:^(WeatherData *data, NSError *error) {
                    if (data) {
                        [self downloadDidFinishWithData:data withTag:weatherView.tag];
                        
                    }else
                    {
                        [self downloadDidFailForWeatherViewWithTag:weatherView.tag];
                    }
                }];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    for (WeatherView *weartherView in self.pagingScrollView.subviews) {
        if (weartherView.local ==YES && !weartherView.hasData) {
            weartherView.conditionIconLabel.text = @"☹";
            weartherView.conditionDescriptionLabel.text  = @"Update Failed";
            weartherView.locationLabel.text = @"Check your network connection";
        }
    }
}

- (void)addLocationButtonPressed
{
    //  Only show the blurred overlay view if weather views have been added
    if([self.pagingScrollView.subviews count] > 0) {
        [self showBlurredOverlayView:YES];
    } else {
        
        //  Fade out the logo and app name when there are no weather views
        [UIView animateWithDuration:0.3 animations: ^ {
            self.LogoLabel.alpha = 0.0;
            self.TitleLabel.alpha = 0.0;
        }];
    }
    
    //  Transition to the add location view controller
    [self presentViewController:self.addLocationViewController animated:YES completion:nil];
}

#pragma mark SettingsViewControllerDelegate Methods

- (void)didMoveWeatherViewAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex
{
    NSNumber *weatherTag = [self.weatherTags objectAtIndex:sourceIndex];
    [self.weatherTags removeObjectAtIndex:sourceIndex];
    [self.weatherTags insertObject:weatherTag atIndex:destinationIndex];
    
    [StateManager setWeatherTags:self.weatherTags];
    
    if ([self.weatherData objectForKey:[NSNumber numberWithInteger:LOCAL_WEATHER_VIEW_TAG]]) {
        destinationIndex += 1 ;
    }
    
    for (WeatherView *weatherView in self.pagingScrollView.subviews) {
        if (weatherView.tag == weatherTag.integerValue) {
            [self.pagingScrollView removeSubview:weatherView];
            [self.pagingScrollView insertSubview:weatherView atIndex:destinationIndex];
            break;
        }
    }
}

- (void)didRemoveWeatherViewWithTag:(NSInteger)tag
{
    for (WeatherView *weatherView in self.pagingScrollView.subviews) {
        if (weatherView.tag == tag) {
            [self.pagingScrollView removeSubview:weatherView];
            self.pageControl.numberOfPages -= 1;
        }
    }
    
    [self.weatherData removeObjectForKey:[NSNumber numberWithInteger:tag ]];
    
    [self.weatherTags removeObject:[NSNumber numberWithInteger:tag]];
    
    if ([self.weatherData count] < MAX_NUM_WEATHER_VIEWS) {
        self.addLocationButton.hidden = NO;
    }
    
    [StateManager setWeatherData:self.weatherData];
    [StateManager setWeatherTags:self.weatherTags];
    
}

- (void)didChangeTemperatureScale:(TemperatureScale)scale
{
    for (WeatherView *weatherView in self.pagingScrollView.subviews) {
        WeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
        [self updateWeatherView:weatherView withData:weatherData];
        
    }
}

- (void)dismissSettingsViewController
{
    [self showBlurredOverlayView:NO];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.LogoLabel.alpha = 1.0;
        self.TitleLabel.alpha = 1.0;
    }];
    
    [self.settingsViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isScrolling = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
    [self setBlurredOverlayImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.isScrolling = YES;
    
    float fractionalPage = self.pagingScrollView.contentOffset.x / self.pagingScrollView.frame.size.width;
    self.pageControl.currentPage = lround(fractionalPage);
}

#pragma mark Updating Weather Data

- (void)updateWeatherData
{
    for (WeatherView *weatherView in self.pagingScrollView.subviews) {
        if (weatherView.local == NO) {
            WeatherData *weatherData = [self.weatherData objectForKey:[NSNumber numberWithInteger:weatherView.tag]];
            if ([[NSDate date]timeIntervalSinceDate:weatherData.timeStamp] >= MIN_TIME_SINCE_UPDATE || !weatherView.hasData) {
                if (weatherView.hasData) {
                    weatherView.activityIndicator.center = CGPointMake(weatherView.center.x, 1.8 * weatherView.center.y);
                }
                [weatherView.activityIndicator startAnimating];
                
                [[DataDownloader sharedDownloader]dataForPlacemark:weatherData.placemark withTag:weatherView.tag completion:^(WeatherData *data, NSError *error) {
                    if (data) {
                        [self downloadDidFinishWithData:data withTag:weatherView.tag];
                    }else
                    {
                        [self downloadDidFailForWeatherViewWithTag:weatherView.tag];
                    }
                    [self setBlurredOverlayImage];
                }];
            }
        }
    }
}

- (void)downloadDidFinishWithData:(WeatherData *)data withTag:(NSInteger)tag
{
    for (WeatherView *weatherView in self.pagingScrollView.subviews) {
        if (weatherView.tag == tag) {
            [self.weatherData setObject:data forKey:[NSNumber numberWithInteger:tag]];
            [self updateWeatherView:weatherView withData:data];
            [weatherView.activityIndicator stopAnimating];
        }
    }
    
    [StateManager setWeatherData:self.weatherData];
    if ([self.weatherData count] >= MAX_NUM_WEATHER_VIEWS) {
        self.addLocationButton.hidden  = YES;
    }
}

- (void)downloadDidFailForWeatherViewWithTag:(NSInteger)tag
{
    for (WeatherView* weatherView in self.pagingScrollView.subviews) {
        if (weatherView.tag == tag) {
            if (!weatherView.hasData) {
                weatherView.conditionIconLabel.text = @"☹";
                weatherView.conditionDescriptionLabel.text = @"Update Failed";
                weatherView.locationLabel.text = @"Check your network connection";
            }
            [weatherView.activityIndicator stopAnimating];
        }
    }
}

- (void)updateWeatherView:(WeatherView *)weatherView withData:(WeatherData *)data
{
    if (!data) {
        return;
    }
    weatherView.hasData = YES;
    
    weatherView.chartData = [[NSArray alloc]init];
//    weatherView.chartData = @[@[@"31",@"35",@"36",@"33",@"34",@"37",@"32"],@[@"28",@"21",@"21",@"24",@"25",@"29",@"18"]];
    weatherView.chartData = [NSArray arrayWithObjects:data.currentSnapshots.highTemArray,data.currentSnapshots.lowTemArray, nil];
    
    weatherView.updatedLabel.text = [NSString stringWithFormat:@"Updated %@",[self.dateFormatter stringFromDate:data.timeStamp]];
    
    weatherView.conditionIconLabel.text = data.currentSnapshots.icon;
    weatherView.conditionDescriptionLabel.text = data.currentSnapshots.conditionDescriptionDay;
    weatherView.todayWeatherDescri.text = data.currentSnapshots.todayWeatherDescri;
    
    NSString *city = data.placemark.locality;
    NSString *state = data.placemark.administrativeArea;
    NSString *country = data.placemark.country;
    
    if ([[country lowercaseString] isEqualToString:@"united states"]) {
        weatherView.locationLabel.text = [NSString stringWithFormat:@"%@,  %@",city, state];
    }else
    {
        weatherView.locationLabel.text = [NSString stringWithFormat:@"%@,  %@",city, country];
    }
    
    Temperature currentTemperature = data.currentSnapshots.currentTemperature;
    Temperature highTemperature = data.currentSnapshots.highTemperature;
    Temperature lowTemperature = data.currentSnapshots.lowTemperature;
    
    if ([StateManager temperatureScale] == fahrenheitScale) {
        weatherView.currentTemperatureLabel.text = [NSString stringWithFormat:@"%.0f°", currentTemperature.fahrenheit];
        weatherView.hiloTemperatureLabel.text = [NSString stringWithFormat:@"H %.0f  L %.0f", highTemperature.fahrenheit, lowTemperature.fahrenheit];
    }else
    {
        weatherView.currentTemperatureLabel.text = [NSString stringWithFormat:@"%.0f°", currentTemperature.celsius];
        weatherView.hiloTemperatureLabel.text = [NSString stringWithFormat:@"H %.0f  L %.0f", highTemperature.celsius, lowTemperature.celsius];
    }
    
//    WeatherSnapshot *forecastDayOneSnapshot =[data.forecastSnapshots objectAtIndex:0 ];
//    WeatherSnapshot *forecastDayTwoSnapshot =[data.forecastSnapshots objectAtIndex:1];
//    WeatherSnapshot *forecastDayThreeSnapshot = [data.forecastSnapshots objectAtIndex:2];
    
//    weatherView.forecastDayOneLabel.text = [forecastDayOneSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3) ];
//    weatherView.forecastDayTwoLabel.text = [forecastDayOneSnapshot.dayOfWeek
//                                            substringWithRange:NSMakeRange(0, 3)];
//    weatherView.forecastDayThreeLabel.text = [forecastDayOneSnapshot.dayOfWeek substringWithRange:NSMakeRange(0, 3)];
//    
//    weatherView.forecastIconOneLabel.text = forecastDayOneSnapshot.icon;
//    weatherView.forecastIconTwoLabel.text = forecastDayTwoSnapshot.icon;
//    weatherView.forecastIconThreeLabel.text = forecastDayThreeSnapshot.icon;
    
    CGFloat fahrenheit = MIN(MAX(0, currentTemperature.fahrenheit), 99);
    NSString *gradientImageName =[NSString stringWithFormat:@"gradient%d.png", (int)floor(fahrenheit / 10.0)];
    weatherView.backgroundColor =[UIColor colorWithPatternImage:[UIImage imageNamed:gradientImageName]];
    [weatherView.lineChartView reloadData];
}

#pragma mark AddLocationViewControllerDelegate Methods
- (void)didAddLocationWithPlacemark:(CLPlacemark *)placemark
{
    WeatherData *weatherData =[self.weatherData objectForKey:[NSNumber numberWithInteger:placemark.locality.hash]];
    if (!weatherData) {
        WeatherView *weatherView = [[WeatherView alloc]initWithFrame:self.view.bounds];
        weatherView.delegate = self;
        weatherView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:DEFAULT_BACKGROUND_GRADIENT]];
        [weatherView setLocal:NO];
        [weatherView setTag:placemark.locality.hash];
        [weatherView.activityIndicator startAnimating];
        
        self.pageControl.numberOfPages += 1;
        [self.pagingScrollView addSubview:weatherView
                                 isLaunch:NO];
        [self.weatherTags addObject:[NSNumber numberWithInteger:weatherView.tag]];
        [StateManager setWeatherTags:self.weatherTags];
        
        
        [[DataDownloader sharedDownloader]dataForPlacemark:placemark withTag:weatherView.tag completion:^(WeatherData *data, NSError *error) {
            if (data) {
                [self downloadDidFinishWithData:data withTag:weatherView.tag];
            }else
            {
                [self downloadDidFailForWeatherViewWithTag:weatherView.tag];
                
            }
            [self setBlurredOverlayImage];
        }];
    }
    if ([self.pagingScrollView.subviews count] >= MAX_NUM_WEATHER_VIEWS) {
        
        self.addLocationButton.hidden = YES;
    }
    NSLog(@"%d",[self.pagingScrollView.subviews count]);
}

- (void)dismissAddLocationViewController
{
    [self showBlurredOverlayView:NO];
    [UIView animateWithDuration:0.3 animations:^{
        self.LogoLabel.alpha = 1.0;
        self.TitleLabel.alpha = 1.0;
    }];
    [self.addLocationViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark WeatherViewDelegate Methods

- (BOOL)shouldPanWeatherview
{
    return !self.isScrolling;
}

- (void)didBeginPanningWeatherView
{
    self.pagingScrollView.scrollEnabled = NO;
}

- (void)didFinishPanningWeatherView
{
    self.pagingScrollView.scrollEnabled = YES;
}

@end
