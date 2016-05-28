//
//  WFSearchViewController.h
//  weatherForecast
//
//  Created by 刘帅 on 5/27/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WFSearchViewController;
@class NFCityWeatherModel;

@protocol  WFSearchViewControllerDelegate <NSObject>

- (void)WFSearchViewController:(WFSearchViewController *)viewController SelectedCity:(NFCityWeatherModel *)city;

@end

@interface WFSearchViewController : UIViewController
@property (nonatomic,weak) id<WFSearchViewControllerDelegate> delegate;
@end
