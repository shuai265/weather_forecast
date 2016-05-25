//
//  NFWeatherService.h
//  weatherForecast
//
//  Created by 刘帅 on 5/24/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NFCityWeatherModel;
/**
 *  天气查询类
 */
@interface NFWeatherService : NSObject

- (NSArray *)searchCityWithCityName:(NSString *)cityName;
- (void)searchWeatherForCityWeather:(NFCityWeatherModel *)cityWeatherModel;

@end
