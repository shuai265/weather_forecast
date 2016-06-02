//
//  WFCityTableViewController.h
//  weatherForecast
//
//  Created by 刘帅 on 5/25/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFCityManageViewController;

@protocol  WFCityManageViewControllerDelegate <NSObject>

- (void)WFCityTableViewController:(WFCityManageViewController *)viewController didFinishEditingCities:(NSMutableArray *)cities;
- (void)WFCityTableViewController:(WFCityManageViewController *)viewController didSelectedRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface WFCityManageViewController : UITableViewController

@property (nonatomic,strong) NSMutableArray *cities;//城市名
@property (nonatomic,strong) id<WFCityManageViewControllerDelegate> delegate;

@end
