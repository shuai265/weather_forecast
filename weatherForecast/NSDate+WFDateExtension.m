//
//  NSDate+WFDateExtension.m
//  weatherForecast
//
//  Created by 刘帅 on 5/22/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "NSDate+WFDateExtension.h"

@implementation NSDate(WFDateExtension)
- (NSUInteger)WFDateNumberOfDaysInCurrentMonth {
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

- (NSDate *)WFDateFirstDayOfCurrentMonth {
    NSDate *startDate = nil;
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth startDate:&startDate interval:nil forDate:self];
    NSAssert1(ok, @"Failed to calculate the first day of the month based on %@", self);
    return startDate;
}

- (int)WFDateWeekly {
    return (int)[[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitCalendar inUnit:NSCalendarUnitWeekday forDate:self];
}

- (int)getYear {
    //
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags = NSCalendarUnitYear;
    
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:self];
    return (int)dateComponent.year;
    
}

- (int)getMonth {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute |NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:self];
    return  (int)dateComponent.month;
}

- (int)getDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlages = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlages fromDate:self];
    return (int)dateComponent.day;
}

- (int)getHour {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlages = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlages fromDate:self];
    return (int)dateComponents.hour;
}

-(int)getMinute {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:self];
    return (int)dateComponents.minute;
}

- (int)getSecond {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *compontents = [calendar components:unitFlags fromDate:self];
    return (int)compontents.second;
}

@end
