//
//  SettingsViewController.h
//  Snow
//
//  Created by WO on 15/7/3.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StateManager.h"

@protocol SettingsViewControllerDelegate <NSObject>

- (void)didMoveWeatherViewAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;


- (void)didRemoveWeatherViewWithTag:(NSInteger)tag;



- (void)didChangeTemperatureScale:(TemperatureScale)scale;


- (void)dismissSettingsViewController;

@end

@interface SettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak,nonatomic) id<SettingsViewControllerDelegate>delegate;

@property (strong,nonatomic)NSMutableArray      *locations;

@end
