//
//  NFCityWeatherModel.m
//  weatherForecast
//
//  Created by 刘帅 on 5/23/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "NFCityWeatherModel.h"

@implementation NFCityWeatherModel

/*
 @property (nonatomic,copy) NSString *cityName;
 @property (nonatomic,strong) NSArray *weathers; //存放weather对象
 @property (nonatomic,strong) NSDate *lastDate;//上次刷新时间
 */

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.cityName = [aDecoder decodeObjectForKey:@"CityName"];
        self.weathers = [aDecoder decodeObjectForKey:@"Weathers"];
        self.lastDate = [aDecoder decodeObjectForKey:@"LastDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cityName forKey:@"CityName"];
    [aCoder encodeObject:self.weathers forKey:@"Weathers"];
    [aCoder encodeObject:self.lastDate forKey:@"LastDate"];
}
@end
