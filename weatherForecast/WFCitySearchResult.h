//
//  WFCitySearchResult.h
//  weatherForecast
//
//  Created by 刘帅 on 5/27/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WFCitySearchResult : NSObject
@property (nonatomic,strong) NSString *province_cn;

/*
province_cn: "北京",  //省
district_cn: "北京",  //市
name_cn: "朝阳",    //区、县
name_en: "chaoyang",  //城市拼音
area_id: "101010300"  //城市代码
 */
@end
