//
//  NFWeatherService.m
//  weatherForecast
//
//  Created by 刘帅 on 5/24/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "NFWeatherService.h"
#import "NFCity.h"
#import "NFWeatherModel.h"
#import "NFCityWeatherModel.h"

@implementation NFWeatherService

- (NSArray *)searchCityWithCityName:(NSString *)cityName {
    //查询城市列表
    NSString *httpUrl = @"http://apis.baidu.com/apistore/weatherservice/citylist";
    NSString *httpArg = @"cityname=%E6%9C%9D%E9%98%B3";
    httpArg = [httpArg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self request: httpUrl withHttpArg: httpArg];
    
    NSArray *array = [[NSArray alloc]init];
    return array;
}


- (void)searchWeatherForCityWeather:(NFCityWeatherModel *)cityWeatherModel {
    
    if (!cityWeatherModel.cityName) {
        NSLog(@"error: can't get weather, city is nil");
        return;
    }
    
    //查询7天天气
    NSString *httpUrl = @"http://apis.baidu.com/apistore/weatherservice/recentweathers";
    //    NSString *httpArg = @"cityname=%E5%8C%97%E4%BA%AC&cityid=101010100";
    NSString *httpArg = [NSString stringWithFormat:@"cityname=%@",cityWeatherModel.cityName];
    httpArg = [httpArg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NFCityWeatherModel *cityWeatherResult = [self getCityWeatherWithRequest: httpUrl withHttpArg: httpArg];
    
//    cityWeather.weathers = cityWeatherResult.weathers;
//    cityWeather.lastDate = cityWeatherResult.lastDate;
}



-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    
    //查询城市列表，城市名＋id,应当用定位城市名 从城市列表获取城市名和id，再进行天气查询

     NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
     NSURL *url = [NSURL URLWithString: urlStr];
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
     [request setHTTPMethod: @"GET"];
     [request addValue: @"您自己的apikey" forHTTPHeaderField: @"apikey"];
     [NSURLConnection sendAsynchronousRequest: request
     queue: [NSOperationQueue mainQueue]
     completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
     if (error) {
     NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
     } else {
     NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
     NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     NSLog(@"HttpResponseCode:%ld", responseCode);
     NSLog(@"HttpResponseBody %@",responseString);
     }
     }];
 }


-(void)request2: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    
    
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"d03b9f8e708c94bbf71ab4fbc60a4021" forHTTPHeaderField: @"apikey"];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                                   //                                   UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:@"无法获取天气数据" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                                   //                                   [alert show];
                               } else {
                                   //                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   //                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   //                                   NSLog(@"HttpResponseCode:%ld", responseCode);
                                   //                                   NSLog(@"HttpResponseBody %@",responseString);
#pragma mark 解析数据
                                   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                   
                                   //                                   NSLog(@"dict = %@",dict);
                                   
                                   //                                   _weather  = dict2[@"weather"];
                                   //                                   NSLog(@"weather = %@",_weather);
                                   NSDictionary *retData = dict[@"retData"];
                                   NSLog(@"retData = %@",dict);
#warning 此处解析天气数据
                                   NSMutableArray *forecast = [retData[@"forecast"] mutableCopy];
                                   NSDictionary *today = retData[@"today"];
                                   NSMutableArray *history = [retData[@"history"] mutableCopy];
                                   //                                   NSLog(@"%@",todayWeather);
                                   NSLog(@"forecast = %@",forecast);
                                   
                                   
                                   
//                                   self.weathers = [[NSMutableArray alloc]initWithCapacity:7];
                                   //过去两天的数据
                                   for (int i = 0; i < 2; i++) {
                                       NSDictionary *tempDict = history[5+i];
                                       NFWeatherModel *weatherModel = [[NFWeatherModel alloc]init];
                                       weatherModel.type = tempDict[@"type"];
                                       weatherModel.week = tempDict[@"week"];
                                       weatherModel.date = tempDict[@"date"];
                                       weatherModel.hightemp = [tempDict[@"hightemp"] integerValue];
                                       weatherModel.lowtemp = [tempDict[@"lowtemp"]integerValue];
//                                       [self.weathers addObject:weatherModel];
                                       
                                       //                                       [history removeLastObject];
                                   }
                                   
                                   NFWeatherModel *todayWeatherModel = [[NFWeatherModel alloc]init];
                                   todayWeatherModel.week = today[@"week"];
                                   todayWeatherModel.curTemp = [today[@"curTemp"]integerValue];
                                   todayWeatherModel.hightemp = [today[@"hightemp"] integerValue];
                                   todayWeatherModel.lowtemp = [today[@"lowtemp"] integerValue];
                                   todayWeatherModel.type = today[@"type"];
                                   todayWeatherModel.date = today[@"date"];
                                   todayWeatherModel.windType = today[@"fengxiang"];
                                   todayWeatherModel.windForce = today[@"fengli"];
                                   NSLog(@"today[@\"date\"] = '%@'",todayWeatherModel.date);
//                                   [self.weathers addObject:todayWeatherModel];
//                                   self.todayWeather = todayWeatherModel;
                                   
                                   for (int i = 0; i<4; i++) {
                                       NSDictionary *tempDict = forecast[i];
                                       NFWeatherModel *weatherModel = [[NFWeatherModel alloc]init];
                                       weatherModel.type = tempDict[@"type"];
                                       weatherModel.week = tempDict[@"week"];
                                       weatherModel.date = tempDict[@"date"];
                                       weatherModel.hightemp = [tempDict[@"hightemp"] integerValue];
                                       weatherModel.lowtemp = [tempDict[@"lowtemp"]integerValue];
//                                       [self.weathers addObject:weatherModel];
                                   }
                                   
                                   //                                   [self reloadView];
                               }
                           }];
    
    
}
@end
