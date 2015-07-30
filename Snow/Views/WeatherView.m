//
//  WeatherView.m
//  Snow
//
//  Created by WO on 15/7/9.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import "WeatherView.h"


#define LIGHT_FONT      @"HelveticaNeue-Light"
#define ULTRALIGHT_FONT @"HelveticaNeue-UltraLight"

#define ARC4RANDOM_MAX 0x010000000



typedef NS_ENUM(NSInteger, JBLineChartLine){
    JBLineChartLineSolid,
    JBLineChartLineDashed,
    JBLineChartLineCount
};

#define kJBColorLineChartDefaultDashedLineColor [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]
#define kJBColorLineChartDefaultSolidLineColor [UIColor colorWithWhite:1.0 alpha:0.5]

@interface WeatherView ()

@property (strong, nonatomic) UIView                    *container;

@property (strong, nonatomic) UIView                    *ribbon;

@property (strong, nonatomic) UIPanGestureRecognizer    *panGestureRecognizer;

//  Displays the time the weather data for this view was last updated
@property (strong, nonatomic) UILabel                   *updatedLabel;

//  Displays the icon for current conditions
@property (strong, nonatomic) UILabel                   *conditionIconLabel;

//  Displays the description of current conditions
@property (strong, nonatomic) UILabel                   *conditionDescriptionLabel;

//  Displays the location whose weather data is being represented by this weather view
@property (strong, nonatomic) UILabel                   *locationLabel;

//  Displayes the current temperature
@property (strong, nonatomic) UILabel                   *currentTemperatureLabel;

//  Displays both the high and low temperatures for today
@property (strong, nonatomic) UILabel                   *hiloTemperatureLabel;

//  Displays the day of the week for the first forecast snapshot
@property (strong, nonatomic) UILabel                   *todayWeatherDescri;

//  Displays the day of the week for the second forecast snapshot
@property (strong, nonatomic) UILabel                   *forecastDayTwoLabel;

//  Displays the day of the week for the third forecast snapshot
@property (strong, nonatomic) UILabel                   *forecastDayThreeLabel;

//  Displays the icon representing the predicted conditions for the first forecast snapshot
@property (strong, nonatomic) UILabel                   *todayWeatherIcon;

//  Displays the icon representing the predicted conditions for the second forecast snapshot
@property (strong, nonatomic) UILabel                   *forecastIconTwoLabel;

//  Displays the icon representing the predicted conditions for the third forecast snapshot
@property (strong, nonatomic) UILabel                   *forecastIconThreeLabel;


@property (strong, nonatomic) UILabel *updateTimeLabel;
//  Indicates whether data is being downloaded for this weather view
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;


//@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *daysOfWeek;


@property (nonatomic, strong) UIView *dateDescripView;

//



@end


@implementation WeatherView


- (instancetype)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame]) {
        self.chartData = [NSArray new];
        self.container = [[UIView alloc]initWithFrame:self.bounds];
        [self.container setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.container];
        
        self.ribbon = [[UIView alloc]initWithFrame:CGRectMake(0, 0.25 * self.center.y, SCR_WIDTH, SCR_HEIGHT * 0.3)];
        [self.ribbon setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.25]];
        [self.container addSubview:self.ribbon];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(didPan:)];
        self.panGestureRecognizer.minimumNumberOfTouches =  1;
        self.panGestureRecognizer.delegate = self;
        [self.container addGestureRecognizer:self.panGestureRecognizer];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.center = self.center;
        [self.container addSubview:self.activityIndicator];
        
        
        
        [self initializeLineChartView];
        [self initializeDateAndDescription];
        [self initializeUpdatedLabel];
//        [self initializeConditionIconLabel];
//        [self initializeConditionDescriptionLabel];
        [self initializeLocationLabel];
        [self initializeCurrentTemperatureLabel];
        [self initializeHiLoTemperatureLabel];
        [self initializeForecastDayLabels];
        [self initializeForecastIconLabels];
        [self initializeMotionEffects];
        
        
        [self initializeUpdatedTimeLabel];
        
    }
    
    return self;
}

- (void)initializeMotionEffects
{
    UIInterpolatingMotionEffect *verticalInterpolation = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalInterpolation.minimumRelativeValue = @(-15);
    verticalInterpolation.maximumRelativeValue = @(15);
    
    UIInterpolatingMotionEffect *horizontalInterpolation = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalInterpolation.minimumRelativeValue = @(-15);
    horizontalInterpolation.maximumRelativeValue = @(15);
    
    [self.conditionIconLabel addMotionEffect:verticalInterpolation];
    [self.conditionIconLabel addMotionEffect:horizontalInterpolation];
}


- (void)initializeUpdatedLabel
{
    static const NSInteger fontSize = 16;
    self.updatedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, -1.5 * fontSize, SCR_WIDTH, 1.5 * fontSize)];
    [self.updatedLabel setNumberOfLines:0];
    [self.updatedLabel setAdjustsFontSizeToFitWidth:YES];
    [self.updatedLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [self.updatedLabel setTextColor:[UIColor whiteColor]];
    [self.updatedLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.updatedLabel];
}

- (void)initializeConditionIconLabel
{
    const NSInteger fontSize = 180;
    self.conditionIconLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, fontSize)];
    [self.conditionIconLabel setCenter:CGPointMake(self.container.center.x, 0.5 * self.center.y)];
    [self.conditionIconLabel setFont:[UIFont fontWithName:CLIMACONS_FONT size:fontSize]];
    [self.conditionIconLabel setBackgroundColor:[UIColor clearColor]];
    [self.conditionIconLabel setTextColor:[UIColor whiteColor]];
    [self.conditionIconLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.conditionIconLabel];
}

- (void)initializeConditionDescriptionLabel
{
    const NSInteger fontSize = 48;
    self.conditionDescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0.75 * self.bounds.size.width, 1.5 * fontSize)];
    [self.conditionDescriptionLabel setNumberOfLines:0];
    [self.conditionDescriptionLabel setAdjustsFontSizeToFitWidth:YES];
    [self.conditionDescriptionLabel setCenter:CGPointMake(self.container.center.x, self.center.y)];
    [self.conditionDescriptionLabel setFont:[UIFont fontWithName:ULTRALIGHT_FONT size:fontSize]];
    [self.conditionDescriptionLabel setBackgroundColor:[UIColor clearColor]];
    [self.conditionDescriptionLabel setTextColor:[UIColor whiteColor]];
    [self.conditionDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.conditionDescriptionLabel];
}

- (void)initializeLocationLabel
{
    const NSInteger fontSize = 18;
    self.locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1.5 * fontSize)];
    [self.locationLabel setAdjustsFontSizeToFitWidth:YES];
    [self.locationLabel setCenter:CGPointMake(self.container.center.x, 0.2 * self.center.y)];
    [self.locationLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [self.locationLabel setBackgroundColor:[UIColor clearColor]];
    [self.locationLabel setTextColor:[UIColor whiteColor]];
    [self.locationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.locationLabel];
}

- (void)initializeCurrentTemperatureLabel
{
    const NSInteger fontSize = 52;
    self.currentTemperatureLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.305 * self.center.y, 0.4 * self.bounds.size.width, fontSize)];
    [self.currentTemperatureLabel setFont:[UIFont fontWithName:ULTRALIGHT_FONT size:fontSize]];
    [self.currentTemperatureLabel setBackgroundColor:[UIColor clearColor]];
    [self.currentTemperatureLabel setTextColor:[UIColor whiteColor]];
    [self.currentTemperatureLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.currentTemperatureLabel];
}

- (void)initializeHiLoTemperatureLabel
{
    const NSInteger fontSize = 18;
    self.hiloTemperatureLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    [self.hiloTemperatureLabel setFrame:CGRectMake(0, 0, 0.375 * self.bounds.size.width, fontSize)];
    [self.hiloTemperatureLabel setCenter:CGPointMake(self.currentTemperatureLabel.center.x - 4,
                                                     self.currentTemperatureLabel.center.y + 0.5 * self.currentTemperatureLabel.bounds.size.height + 12)];
    [self.hiloTemperatureLabel setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [self.hiloTemperatureLabel setBackgroundColor:[UIColor clearColor]];
    [self.hiloTemperatureLabel setTextColor:[UIColor whiteColor]];
    [self.hiloTemperatureLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.hiloTemperatureLabel];
}

- (void)initializeDateAndDescription
{
    NSDateComponents *componets = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSInteger weekday = [componets weekday];
    NSArray *array = [self resortTheWeekDays:weekday];
    
    
    self.dateDescripView =[[UIView alloc]initWithFrame:CGRectMake(0, 0.43 * SCR_HEIGHT , SCR_WIDTH, 60)];
    for (int i = 0; i < 6; i++) {
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCR_WIDTH / 6 )* i, 0, SCR_WIDTH / 6 , 20)];
        UILabel *descLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCR_WIDTH / 6) * i, 20, SCR_WIDTH / 6, 30)];
        
        
        
        
        dateLabel.text = [array objectAtIndex:i];
        dateLabel.font = [UIFont systemFontOfSize:11];
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        
        descLabel.textColor = [UIColor whiteColor];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.tag = 1000 + i;
        
        
        
        [self.dateDescripView addSubview:dateLabel];
        [self.dateDescripView addSubview:descLabel];
        
    }
    
    [self.container addSubview:self.dateDescripView];
}

- (void)initializeForecastDayLabels
{
    const NSInteger fontSize = 18;
    
    self.todayWeatherDescri = [[UILabel alloc]initWithFrame:CGRectZero];
//    self.forecastDayTwoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//    self.forecastDayThreeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//    NSArray *forecastDayLabels = @[self.forecastDayOneLabel, self.forecastDayTwoLabel, self.forecastDayThreeLabel];
    
    
//    UILabel *forecastDayLabel = [forecastDayLabels objectAtIndex:0];
    [self.todayWeatherDescri setFrame:CGRectMake(0.425 * self.bounds.size.width + (64 * 0), 0.5 * self.center.y, 6 * fontSize, fontSize)];
    [self.todayWeatherDescri setFont:[UIFont fontWithName:LIGHT_FONT size:fontSize]];
    [self.todayWeatherDescri setBackgroundColor:[UIColor clearColor]];
    [self.todayWeatherDescri setTextColor:[UIColor whiteColor]];
    [self.todayWeatherDescri setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.todayWeatherDescri];
    
}

- (void)initializeForecastIconLabels
{
    const NSInteger fontSize = 40;
    
    self.todayWeatherIcon = [[UILabel alloc]initWithFrame:CGRectZero];
//    self.forecastIconTwoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//    self.forecastIconThreeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//    
//    NSArray *forecastIconLabels = @[self.forecastIconOneLabel, self.forecastIconTwoLabel, self.forecastIconThreeLabel];
//    
//    UILabel *forecastIconLabel = [forecastIconLabels objectAtIndex:0];
    [self.todayWeatherIcon setFrame:CGRectMake(0.425 * self.bounds.size.width + (64 * 0), 0.33 * self.center.y, fontSize, fontSize)];
    [self.todayWeatherIcon setFont:[UIFont fontWithName:CLIMACONS_FONT size:fontSize]];
    [self.todayWeatherIcon setBackgroundColor:[UIColor clearColor]];
    [self.todayWeatherIcon setTextColor:[UIColor whiteColor]];
    [self.todayWeatherIcon setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.todayWeatherIcon];
    
}

- (void)initializeUpdatedTimeLabel
{
    const NSInteger fontSize = 20;
    self.updateTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCR_WIDTH * 0.55, 0.305 * self.center.y, 0.4 * self.bounds.size.width, fontSize)];
    [self.updateTimeLabel setFont:[UIFont fontWithName:ULTRALIGHT_FONT size:fontSize]];
    [self.updateTimeLabel setBackgroundColor:[UIColor clearColor]];
    [self.updateTimeLabel setTextColor:[UIColor whiteColor]];
    [self.updateTimeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.container addSubview:self.updateTimeLabel];
}

- (void)initializeLineChartView
{
    CGFloat LINECHARTWIDTH = SCR_WIDTH - 40;
    self.lineChartView = [[JBLineChartView alloc]initWithFrame:CGRectMake(20, SCR_HEIGHT * 0.58, LINECHARTWIDTH, SCR_HEIGHT * 0.20)];
    self.lineChartView.dataSource = self;
    self.lineChartView.delegate = self;
    self.lineChartView.showsVerticalSelection = NO;
    
    
    for (int i = 0; i < 6; i++) {
        
        
        UILabel *dayHighLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCR_WIDTH / 6) * i, SCR_HEIGHT * 0.53, SCR_WIDTH / 6, 20)];
        
        UILabel *dayLowLabel =[[UILabel alloc]initWithFrame:CGRectMake((SCR_WIDTH / 6) * i, SCR_HEIGHT * 0.78, SCR_WIDTH / 6, 20)];
        
        dayHighLabel.textColor = [UIColor whiteColor];
        dayHighLabel.font = [UIFont systemFontOfSize:11];
        dayHighLabel.textAlignment = NSTextAlignmentCenter;
        dayHighLabel.tag = 2000 + i;
        
        dayLowLabel.textColor = [UIColor whiteColor];
        dayLowLabel.font = [UIFont systemFontOfSize:11];
        dayLowLabel.textAlignment = NSTextAlignmentCenter;
        dayLowLabel.tag = 3000 + i;
        
        
        [self.container addSubview:dayLowLabel];
        [self.container addSubview:dayHighLabel];
    }
    
    
    [self.container addSubview:self.lineChartView];
    
    
}

#pragma mark - JBChartViewDataSource

- (BOOL)shouldExtendSelectionViewIntoHeaderPaddingForChartView:(JBChartView *)chartView
{
    return YES;
}

- (BOOL)shouldExtendSelectionViewIntoFooterPaddingForChartView:(JBChartView *)chartView
{
    return NO;
}

#pragma mark LineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return [self.chartData count]; // number of lines in chart
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [[self.chartData objectAtIndex:lineIndex] count]; // number of values for a line
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    
    return YES;
    
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    
    return  YES;
}

#pragma mark - JBLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [[[self.chartData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] floatValue]; // y-position (y-axis) of point at horizontalIndex (x-axis)
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return kJBColorLineChartDefaultSolidLineColor;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return kJBColorLineChartDefaultSolidLineColor;
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 1.0;
}



#pragma mark Pan Gesture Recognizer Methods

- (void)didPan:(UIPanGestureRecognizer *)gestureRecognizer
{
    static CGFloat initialCenterY = 0.0;
    CGPoint translatedPoint = [gestureRecognizer translationInView:self.container];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        //  Save the inital Y to reuse later
        initialCenterY = self.container.center.y;
        
        //  Alert the delegate that panning has begun
        [self.delegate didBeginPanningWeatherView];
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        //  Alert the delegate that panning finished
        [self.delegate didFinishPanningWeatherView];
        
        //  Return the container back to its original position
        [UIView animateWithDuration:0.3 animations: ^ {
            self.container.center = CGPointMake(self.container.center.x, initialCenterY);
        }];
        
    } else if(translatedPoint.y <= 50 && translatedPoint.y > 0) {
        //  Translate the container
        self.container.center = CGPointMake(self.container.center.x, self.center.y + translatedPoint.y);
    }
}

/*- (void)initFakeData
{
    NSMutableArray *mutableLineCharts = [NSMutableArray array];
    
    for (int lineIndex=0; lineIndex<2; lineIndex++)
    {
        NSMutableArray *mutableChartData = [NSMutableArray array];
        for (int i=0; i<7; i++)
        {
            [mutableChartData addObject:[NSNumber numberWithFloat:((double)arc4random() / ARC4RANDOM_MAX)]]; // random number between 0 and 1
        }
        [mutableLineCharts addObject:mutableChartData];
    }
    _chartData = [NSArray arrayWithArray:mutableLineCharts];
    _chartData = @[@[@"31",@"35",@"36",@"33",@"34",@"37",@"32"],@[@"28",@"21",@"21",@"24",@"25",@"29",@"18"]];
    _daysOfWeek = [[[NSDateFormatter alloc] init] shortWeekdaySymbols];
}*/

#pragma mark UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        //  We only want to register vertial pans
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panGestureRecognizer velocityInView:self.container];
        return fabsf(velocity.y) > fabsf(velocity.x);
    }
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (NSArray*)resortTheWeekDays:(NSInteger)todayInt
{
    NSArray *array = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",];
    NSMutableArray *weekdayArray = [NSMutableArray arrayWithArray:array];
    
    for (int i = 0 ; i <  todayInt - 1; i++) {
        id object = [weekdayArray objectAtIndex:0];
        [weekdayArray removeObjectAtIndex:0];
        [weekdayArray insertObject:object atIndex:WEEKDAYS-1];
        
    }
    [weekdayArray replaceObjectAtIndex:0 withObject:@"今天"];
    [weekdayArray replaceObjectAtIndex:1 withObject:@"明天"];
    
    return weekdayArray;
}
@end
