//
//  AddLocationViewController.h
//  Snow
//
//  Created by WO on 15/7/3.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddLocationViewControllerDelegate <NSObject>

- (void)didAddLocationWithPlacemark:(CLPlacemark *)placemark;

/**
 Called by a SOLAddLocationViewController when the view controller needs to
 be dismissed.
 */
- (void)dismissAddLocationViewController;
@end

@interface AddLocationViewController : UIViewController<UISearchDisplayDelegate, UITableViewDelegate,
UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate>


@property (weak,nonatomic)id<AddLocationViewControllerDelegate>delegate;
@end
