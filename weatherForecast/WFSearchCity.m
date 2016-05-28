//
//  WFSearchCity.m
//  weatherForecast
//
//  Created by 刘帅 on 5/27/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "WFSearchCity.h"
#import "NFCityWeatherModel.h"

static NSOperationQueue *queue = nil;

@interface WFSearchCity ()
//@property (nonatomic, readwrite, strong) NSMutableArray *searchResults;
@end

@implementation WFSearchCity

+ (void)initialize {
    if (self == [WFSearchCity class]) {
        queue = [[NSOperationQueue alloc]init];
    }
}

- (void)dealloc {
    NSLog(@"dealloc %@",self);
}

- (void)performSearchForText:(NSString *)text completion:(SearchBlock)block {
    if ([text length] > 0) {
        [queue cancelAllOperations];
        
        self.isLoading = YES;
        self.searchResult = [NSMutableArray arrayWithCapacity:10];
        
        //查询城市列表
//        NSString *httpUrl = @"http://apis.baidu.com/apistore/weatherservice/citylist";
//        NSString *httpArg = @"cityname=%E6%9C%9D%E9%98%B3";
//        NSString *httpArg = [NSString stringWithFormat:@"cityname=%@",text];
//        httpArg = [httpArg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        

        NSString *httpUrl = @"http://apis.baidu.com/apistore/weatherservice/citylist";
//        NSString *httpArg = @"cityname=%E6%9C%9D%E9%98%B3";
        NSString *httpArg = [NSString stringWithFormat:@"cityname=%@",text];
        httpArg = [httpArg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        [self request: httpUrl withHttpArg: httpArg];
        NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, httpArg];
        NSURL *url = [NSURL URLWithString: urlStr];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
        [request setHTTPMethod: @"GET"];
        [request addValue: @"d03b9f8e708c94bbf71ab4fbc60a4021" forHTTPHeaderField: @"apikey"];
        [NSURLConnection sendAsynchronousRequest: request
                                           queue: [NSOperationQueue mainQueue]
                               completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                                   if (error) {
                                       NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                                       self.isLoading = NO;
                                       block(NO);
                                   } else {
                                       NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                       NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                       NSLog(@"HttpResponseCode:%ld", responseCode);
                                       NSLog(@"HttpResponseBody %@",[responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
                                       NSDictionary *searchResultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       [self parseDictionary:searchResultDict];
                                       
                                       self.isLoading = NO;
                                       block(YES);
                                   }
                               }];
        
        

    }
}


-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 200];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"d03b9f8e708c94bbf71ab4fbc60a4021" forHTTPHeaderField: @"apikey"];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"HttpResponseCode:%ld", responseCode);
                                   NSLog(@"HttpResponseBody %@",[responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
                                   NSDictionary *searchResultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   [self parseDictionary:searchResultDict];
                                   
                                   self.isLoading = NO;

                               }
                           }];
}

- (void)parseDictionary:(NSDictionary *)dictionary {
    NSArray *array = dictionary[@"retData"];
//    NSLog(@"search result array= '%@'",array);
    
    if (array == nil) {
        NSLog(@"期望 搜索结果 array");
        return;
    }

    for (NSDictionary *resultDict in array) {
//        NSLog(@"search result dic in array = '%@'",resultDict);
        NFCityWeatherModel *city = [[NFCityWeatherModel alloc]init];
        city.cityName = resultDict[@"name_cn"];
        city.province_cn = resultDict[@"province_cn"];
        city.district_cn = resultDict[@"district_cn"];
        city.name_cn = resultDict[@"name_cn"];
        city.area_id = resultDict[@"area_id"];
        
        if (city) {
            [self.searchResult addObject:city];
        }
    }
    NSLog(@"解析完成，self.searchResult.count = '%ld'",[self.searchResult count]);

}

@end
