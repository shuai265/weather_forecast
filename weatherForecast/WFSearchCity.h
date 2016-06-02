//
//  WFSearchCity.h
//  weatherForecast
//
//  Created by 刘帅 on 5/27/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NFCityWeatherModel;
typedef void (^SearchBlock)(BOOL success,NSArray *searchResult);

@interface WFSearchCity : NSObject
@property (nonatomic,assign) BOOL isLoading;
//@property (nonatomic,readonly,strong) NSMutableArray *searchResult;
@property (nonatomic,strong) NSMutableArray *searchResult;

- (void)performSearchForText:(NSString *)text completion:(SearchBlock)block;
@end
