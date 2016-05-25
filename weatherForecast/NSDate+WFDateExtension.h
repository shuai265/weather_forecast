//
//  NSDate+WFDateExtension.h
//  weatherForecast
//
//  Created by 刘帅 on 5/22/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  获取日期需要的拓展
 */
@interface NSDate(WFDateExtension)

/**
 *  获取当月的天数
 */
- (NSUInteger)WFDateNumberOfDaysInCurrentMonth;

/**
 *  获取本月第一天
 */
- (NSDate *)WFDateFirstDayOfCurrentMonth;

/**
 *  获取时间是周几
 */
- (int)WFDateWeekly;

- (int)getYear;
- (int)getMonth;
- (int)getDay;
- (int)getHour;
- (int)getMinute;
- (int)getSecond;


@end
