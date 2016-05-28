//
//  WFScrollView.m
//  weatherForecast
//
//  Created by 刘帅 on 5/26/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "WFScrollView.h"
#import "NFWeatherModel.h"
#import "NFWeatherModel.h"
#import "UIImage+RTTint.h"
#import "NFCityWeatherModel.h"
#import "WFCityManageViewController.h"

#define SCREEN self.view.frame.size

// iPhone4
#define iPhone4 ([UIScreen mainScreen].bounds.size.height == 480.0)
// iPhone5
#define iPhone5 ([UIScreen mainScreen].bounds.size.height == 568.0)
// iPhone6
#define iPhone6 ([UIScreen mainScreen].bounds.size.height == 667.0)
// iPhone6p
#define iPhone6p ([UIScreen mainScreen].bounds.size.height == 736.0)

@implementation WFScrollView

#pragma mark 根据城市数据获取视图

#ifdef def
- (void)configureView:(UIView *)view WithCityWeather:(NFCityWeatherModel *)cityWeather {
    //    NSLog(@"执行configureView:WithCityWeather");
    
    //如果 cityWeather.weathers == nil，则想法获取（利用全局变量，）
    
    //判断屏幕大小
    int fontSize = 25;
    if (iPhone4) {
        fontSize = 10;
    }else if(iPhone5) {
        fontSize = 15;
    }else if(iPhone6) {
        fontSize = 18;
    }else if(iPhone6p) {
        fontSize = 20;
    }
    UIFont *labelFont = [UIFont systemFontOfSize:fontSize];
    

    //实时温度label，20+80+100
    //温度tag = 1001
    UILabel *todayTempLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN.width/2-100, 80, 200, 100)];
    todayTempLabel.textColor = [UIColor whiteColor];
    todayTempLabel.font = [UIFont fontWithName:@"GillSans-Light" size:100];
    todayTempLabel.textAlignment = NSTextAlignmentCenter;
    todayTempLabel.text = @"N/A";
    todayTempLabel.tag = 1001;
    [view addSubview:todayTempLabel];
    
    //最高温度tag = 1002
    const CGRect todayTempLabelFrame = todayTempLabel.frame;
    UILabel *todayHighTempLabel = [[UILabel alloc]initWithFrame:CGRectMake(todayTempLabelFrame.origin.x + todayTempLabelFrame.size.width, todayTempLabelFrame.origin.y+10, 50, 30)];
    todayHighTempLabel.textColor = [UIColor whiteColor];
    todayHighTempLabel.text = @"N/A↑";
    todayHighTempLabel.tag = 1002;
    [view addSubview:todayHighTempLabel];
    
    //最低温度tag = 1003
    UILabel * todayLowTempLabel = [[UILabel alloc]initWithFrame:CGRectMake(todayTempLabelFrame.origin.x + todayTempLabelFrame.size.width, todayTempLabelFrame.origin.y+10+40, 50, 30)];
    todayLowTempLabel.textColor = [UIColor whiteColor];
    todayLowTempLabel.text = @"N/A↓";
    todayLowTempLabel.tag = 1003;
    [view addSubview:todayLowTempLabel];
    
    //空气湿度 200 < y < 300
    UIImageView *humidityImageView = [[UIImageView alloc]initWithFrame:CGRectMake( 20, 235, 30, 30)];
    UIImage *humidityImage = [UIImage imageNamed:@"湿度.png"];
    humidityImage = [humidityImage rt_tintedImageWithColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1]];
    [humidityImageView setImage:humidityImage];
    [view addSubview:humidityImageView];
    
    UILabel *humidityLabel = [[UILabel alloc]initWithFrame:CGRectMake(humidityImageView.frame.origin.x+30, 220, (view.frame.size.width-30)/3-30, 30)];
    humidityLabel.text = @"空气湿度";
    humidityLabel.textColor = [UIColor whiteColor];
    humidityLabel.textAlignment = NSTextAlignmentCenter;
    humidityLabel.font = labelFont;
    humidityLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    humidityLabel.layer.borderWidth = 1;
    [view addSubview:humidityLabel];
    //空气湿度 tag ＝ 1004
    UILabel *humidityLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(80, 250, humidityLabel.frame.size.width, 30)];
    humidityLabel2.textAlignment = NSTextAlignmentCenter;
    humidityLabel2.textColor = [UIColor whiteColor];
    humidityLabel2.font = labelFont;
    humidityLabel2.tag = 1004;
    [view addSubview:humidityLabel2];
    //    self.todayhumidityLabel = humidityLabel2;
    
    //风
    UIImageView *windImageView = [[UIImageView alloc]initWithFrame:CGRectMake((view.frame.size.width - 20*4)/3+20*2, 235, 30, 30)];
    UIImage *windImage = [UIImage imageNamed:@"天气－风.png"];
    windImage = [windImage rt_tintedImageWithColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1]];
    [windImageView setImage:windImage];
    [view addSubview:windImageView];
    //风向windType tag = 1005
    UILabel *windTypeLabel = [[UILabel alloc]initWithFrame:CGRectMake(windImageView.frame.origin.x +30, windImageView.frame.origin.y - 15, (view.frame.size.width-30)/3-30, 30)];
    windTypeLabel.text = @"";
    windTypeLabel.textColor = [UIColor whiteColor];
    windTypeLabel.textAlignment = NSTextAlignmentCenter;
    windTypeLabel.font = labelFont;
    windTypeLabel.tag = 1005;
    [view addSubview:windTypeLabel];
    //风力windForce tag = 1006
    UILabel *windForceLabel = [[UILabel alloc]initWithFrame:CGRectMake(windTypeLabel.frame.origin.x, windTypeLabel.frame.origin.y + 30, windTypeLabel.frame.size.width, windTypeLabel.frame.size.height)];
    windForceLabel.textColor = [UIColor whiteColor];
    windForceLabel.textAlignment = NSTextAlignmentCenter;
    windForceLabel.font = labelFont;
    windForceLabel.tag = 1006;
    [view addSubview:windForceLabel];
    
    //体感温度
    UIImageView *bodyTempImageView = [[UIImageView alloc]initWithFrame:CGRectMake((view.frame.size.width - 40*4)/3*2+40*3, 235, 30, 30)];
    UIImage *bodyTempImage = [UIImage imageNamed:@"温度计.png"];
    bodyTempImage = [bodyTempImage rt_tintedImageWithColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:1]];
    [bodyTempImageView setImage:bodyTempImage];
    [view addSubview:bodyTempImageView];
    
    UILabel *bodyTempLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(bodyTempImageView.frame.origin.x+30, bodyTempImageView.frame.origin.y-15, (view.frame.size.width-30)/3-30, 30)];
    bodyTempLabel1.textColor = [UIColor whiteColor];
    bodyTempLabel1.text = @"体感温度";
    bodyTempLabel1.textAlignment = NSTextAlignmentCenter;
    bodyTempLabel1.font = labelFont;
    [view addSubview:bodyTempLabel1];
    //体感温度 bodyTemp .tag = 1007
    UILabel *bodyTempLabel2 = [[UILabel alloc]initWithFrame:CGRectMake(bodyTempImageView.frame.origin.x+30, bodyTempImageView.frame.origin.y+15, (view.frame.size.width-30)/3-30, 30)];
    bodyTempLabel2.textColor = [UIColor whiteColor];
    bodyTempLabel2.textAlignment = NSTextAlignmentCenter;
    bodyTempLabel2.tag = 1007;
    bodyTempLabel2.font = labelFont;
    [view addSubview:bodyTempLabel2];
    
    
    UILabel *lastUpdateTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(todayTempLabelFrame.origin.x, todayTempLabelFrame.origin.y+100, 200, 10)];
    lastUpdateTimeLabel.textColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.8];
    lastUpdateTimeLabel.textAlignment = NSTextAlignmentCenter;
    lastUpdateTimeLabel.font = [UIFont systemFontOfSize:10];
    lastUpdateTimeLabel.tag = 1008;
    [view addSubview:lastUpdateTimeLabel];
    
    /*
     //城市名 tag = 1020
     UIButton *cityNameButton = [UIButton buttonWithType:UIButtonTypeSystem];
     cityNameButton.frame = CGRectMake(SCREEN.width/2-40, 30, 80, 40);
     [cityNameButton setTitle:cityWeather.cityName forState:UIControlStateNormal];
     //    cityNameButton.titleLabel.text = [NSString stringWithFormat:@"%@",cityWeather.cityName];
     cityNameButton.titleLabel.textAlignment = NSTextAlignmentCenter;
     cityNameButton.titleLabel.textColor = [UIColor whiteColor];
     cityNameButton.tintColor = [UIColor whiteColor];
     cityNameButton.tag = 1020;
     [view addSubview:cityNameButton];
     //    self.cityNameButton = cityNameButton;
     */
}
#endif

@end
