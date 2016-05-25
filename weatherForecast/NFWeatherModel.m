//
//  NFWeatherModel.m
//  weatherForecast
//
//  Created by 刘帅 on 5/19/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "NFWeatherModel.h"

@implementation NFWeatherModel

/*
 @property (nonatomic, copy) NSString *date;//日期
 @property (nonatomic, copy) NSString *week;//周几
 @property (nonatomic, copy) NSString *type;//天气
 @property (nonatomic, assign) NSUInteger lowtemp;
 @property (nonatomic, assign) NSUInteger hightemp;
 @property (nonatomic, assign) NSUInteger aqi;//pm
 @property (nonatomic, assign) NSUInteger curTemp;//当前温度
 @property (nonatomic, copy) NSString *windType;//风向
 @property (nonatomic, copy) NSString *windForce;//风力
 */

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.date = [aDecoder decodeObjectForKey:@"Date"];
        self.week = [aDecoder decodeObjectForKey:@"Week"];
        self.type = [aDecoder decodeObjectForKey:@"Type"];
        self.windType = [aDecoder decodeObjectForKey:@"WindType"];
        self.windForce = [aDecoder decodeObjectForKey:@"WindForce"];
        self.lowtemp = [aDecoder decodeIntegerForKey:@"Lowtemp"];
        self.hightemp = [aDecoder decodeIntegerForKey:@"Hightemp"];
        self.aqi = [aDecoder decodeIntegerForKey:@"Aqi"];
        self.curTemp = [aDecoder decodeIntegerForKey:@"CurTemp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.date forKey:@"Date"];
    [aCoder encodeObject:self.week forKey:@"Week"];
    [aCoder encodeObject:self.type forKey:@"Type"];
    [aCoder encodeObject:self.windType forKey:@"WindType"];
    [aCoder encodeObject:self.windForce forKey:@"WindForce"];
    [aCoder encodeInteger:self.lowtemp forKey:@"Lowtemp"];
    [aCoder encodeInteger:self.hightemp forKey:@"Hightemp"];
    [aCoder encodeInteger:self.aqi forKey:@"Aqi"];
    [aCoder encodeInteger:self.curTemp forKey:@"CurTemp"];
}

@end
