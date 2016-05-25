//
//  NFWeatherModel.h
//  weatherForecast
//
//  Created by 刘帅 on 5/19/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFWeatherModel : NSObject<NSCoding>

//@property (nonatomic ,strong) NSDate *date;
@property (nonatomic, copy) NSString *date;//日期
@property (nonatomic, copy) NSString *week;//周几
@property (nonatomic, copy) NSString *type;//天气
@property (nonatomic, assign) NSUInteger lowtemp;
@property (nonatomic, assign) NSUInteger hightemp;
@property (nonatomic, assign) NSUInteger aqi;//pm
@property (nonatomic, assign) NSUInteger curTemp;//当前温度
@property (nonatomic, copy) NSString *windType;//风向
@property (nonatomic, copy) NSString *windForce;//风力
@property (nonatomic, copy) NSString *icon;

@end
