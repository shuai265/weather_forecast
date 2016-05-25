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

- (void)WFCityTableViewController:(WFCityTableViewController *)viewController didFinishEditingWeathers:(NSArray *)weathers;

@end

@interface WFCityTableViewController : UITableViewController

@property (nonatomic,strong) NSMutableArray *weathers;
@property (nonatomic,strong) id<WFCityTableViewControllerDelegate> delegate;

@end
