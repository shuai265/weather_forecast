//
//  WFCityTableViewController.m
//  weatherForecast
//
//  Created by 刘帅 on 5/25/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "WFCityManageViewController.h"
#import "NFCityWeatherModel.h"
#import "WFSearchViewController.h"
@interface WFCityManageViewController ()<WFSearchViewControllerDelegate,UINavigationControllerDelegate>

@end

@implementation WFCityManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.delegate = self;
//    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];

    self.navigationItem.title = @"城市管理";
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:255 alpha:1]];
    
    UIBarButtonItem *addCityButton = [[UIBarButtonItem alloc]initWithTitle:@"添加城市" style:UIBarButtonItemStylePlain target:self action:@selector(addCityClick:)];
    self.navigationItem.rightBarButtonItem = addCityButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(calcelClick:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"CityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    NFCityWeatherModel *cityWeatherModel = [_cities objectAtIndex:indexPath.row];
    cell.textLabel.text = cityWeatherModel.cityName;
    
    return cell;
}

#pragma mark - table View delegate

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_cities removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



#pragma mark 添加城市
- (void)addCityClick:(UIButton *)button {
    NSLog(@"addCityClick");
    WFSearchViewController *searchVC = [[WFSearchViewController alloc]init];
    searchVC.delegate = self;
    [self.navigationController pushViewController:searchVC animated:YES];
}
- (void)calcelClick:(UIButton *)button {
    
    [self.delegate WFCityTableViewController:self didFinishEditingCities:_cities];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark WFSearchViewControllerDelegate
- (void)WFSearchViewController:(WFSearchViewController *)viewController SelectedCity:(NFCityWeatherModel *)city {
    [self.navigationController popViewControllerAnimated:viewController];
    [self.cities addObject:city];
    NSLog(@"self.cities.count = '%lu'",(unsigned long)self.cities.count);
    [self.tableView reloadData];
}

@end
