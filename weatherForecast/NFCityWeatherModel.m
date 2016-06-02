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
 @property (nonatomic,strong) NFWeatherModel *currentWeather;//实时天气
 
 @property (nonatomic,copy) NSString *province_cn;//省
 @property (nonatomic,copy) NSString *district_cn;//市
 @property (nonatomic,copy) NSString *name_cn;////区、县
 @property (nonatomic,copy) NSString *area_id;//城市代码
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
        
        self.province_cn = [aDecoder decodeObjectForKey:@"province_cn"];
        self.district_cn = [aDecoder decodeObjectForKey:@"district_cn"];
        self.name_cn = [aDecoder decodeObjectForKey:@"name_cn"];
        self.area_id = [aDecoder decodeObjectForKey:@"area_id"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cityName forKey:@"CityName"];
    [aCoder encodeObject:self.weathers forKey:@"Weathers"];
    [aCoder encodeObject:self.lastDate forKey:@"LastDate"];
    
    [aCoder encodeObject:self.province_cn forKey:@"province_cn"];
    [aCoder encodeObject:self.district_cn forKey:@"district_cn"];
    [aCoder encodeObject:self.name_cn forKey:@"name_cn"];
    [aCoder encodeObject:self.area_id forKey:@"area_id"];
}
@end
