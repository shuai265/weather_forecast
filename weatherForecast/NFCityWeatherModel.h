//
//  NFCityWeatherModel.h
//  weatherForecast
//
//  Created by 刘帅 on 5/23/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NFCityWeatherModel : NSObject<NSCoding>

@property (nonatomic,copy) NSString *cityName;
@property (nonatomic,strong) NSArray *weathers; //存放weather对象
@property (nonatomic,strong) NSDate *lastDate;//上次刷新时间

@end
