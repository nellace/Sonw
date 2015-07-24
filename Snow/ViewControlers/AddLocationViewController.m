//
//  AddLocationViewController.m
//  Snow
//
//  Created by WO on 15/7/3.
//  Copyright (c) 2015年 sg. All rights reserved.
//

#import "AddLocationViewController.h"

@interface AddLocationViewController ()

@property (strong, nonatomic) CLGeocoder *geocoder;

@property (strong, nonatomic) NSMutableArray *searchResult;

@property (strong, nonatomic) UISearchDisplayController *searchController;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) UINavigationBar *navigationBar;

@property (strong, nonatomic) UIBarButtonItem *doneButton;



@end

@implementation AddLocationViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil ]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.view.backgroundColor = [UIColor clearColor];
        self.view.opaque = NO;
        
        self.geocoder = [[CLGeocoder alloc]init];
        self.searchResult = [[NSMutableArray alloc]initWithCapacity:5];
        
        self.navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, SCR_WIDTH, 64)];
        
        [self.view addSubview:self.navigationBar];
        
        self.doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneButtonPressed)];
        
        self.searchBar =[[ UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCR_WIDTH, 44)];
        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchBar.placeholder = @"城市";
        self.searchBar.delegate = self;
        
        
        self.searchController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
        self.searchController.delegate = self;
        self.searchController.searchResultsDelegate = self;
        self.searchController.searchResultsDataSource = self;
        self.searchController.searchResultsTitle = @"Add Location";
        self.searchController.displaysSearchBarInNavigationBar = YES;
        self.searchController.navigationItem.rightBarButtonItems = @[self.doneButton];
        self.navigationBar.items = @[self.searchController.navigationItem];
        
        
        //这里是searchcontroller的问题
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [self.searchController setActive:YES animated:NO];
    [self.searchController.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self.searchController setActive:NO animated:NO];
    [self.searchController.searchBar resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate dismissAddLocationViewController];
}

#pragma mark DoneButton Methods

- (void)doneButtonPressed
{
    [self.delegate dismissAddLocationViewController];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.geocoder geocodeAddressString:searchString completionHandler:^(NSArray *placemarks, NSError *error) {
        self.searchResult = [[NSMutableArray alloc]initWithCapacity:1];
        for (CLPlacemark *placemark in placemarks) {
            if (placemark.locality) {
                [self.searchResult addObject:placemark];
            }
        }
        [controller.searchResultsTableView reloadData];
    }];
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [tableView setFrame:CGRectMake(0, CGRectGetHeight(self.navigationBar.bounds), SCR_WIDTH, SCR_HEIGHT - CGRectGetHeight(self.navigationBar.bounds))];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate =self;
    [self.view bringSubviewToFront:self.navigationBar];
}

#pragma mark UITableViewDelegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier =  @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (tableView == self.searchController.searchResultsTableView) {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        CLPlacemark *placemark  = [self.searchResult objectAtIndex:indexPath.row];
        NSString *city = placemark.locality;
        NSString *country = placemark.country;
        NSString *cellText =[ NSString stringWithFormat:@"%@, %@",city,country ] ;
        if ([[country lowercaseString] isEqualToString:@"united states"]) {
            NSString *state = placemark.administrativeArea;
            cellText = [NSString stringWithFormat:@"%@, %@",city, state];
        }
        cell.textLabel.text = cellText;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchController.searchResultsTableView) {
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        CLPlacemark *placemark = [self.searchResult objectAtIndex:indexPath.row];
        [self.delegate didAddLocationWithPlacemark:placemark];
        [self.delegate dismissAddLocationViewController];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResult count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.navigationBar.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, CGRectGetWidth(self.navigationBar.frame),
                                          CGRectGetHeight(self.navigationBar.frame));
}
@end
