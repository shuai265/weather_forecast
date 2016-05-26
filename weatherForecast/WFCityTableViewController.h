//
//  WFCityTableViewController.h
//  weatherForecast
//
//  Created by 刘帅 on 5/25/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFCityTableViewController;

@protocol  WFCityTableViewControllerDelegate <NSObject>

- (void)WFCityTableViewController:(WFCityTableViewController *)viewController didFinishEditingCities:(NSMutableArray *)cities;

@end

@interface WFCityTableViewController : UITableViewController

@property (nonatomic,strong) NSMutableArray *cities;//城市名
@property (nonatomic,strong) id<WFCityTableViewControllerDelegate> delegate;

@end
