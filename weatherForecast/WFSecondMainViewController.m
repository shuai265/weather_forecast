//
//  WFSecondMainViewController.m
//  weatherForecast
//
//  Created by 刘帅 on 5/25/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "WFSecondMainViewController.h"
#import "WFDaysView.h"
#import "NFWeatherModel.h"
#import "UIImage+RTTint.h"
#import "NFCityWeatherModel.h"
#import "MJRefresh.h"
#import "WFCityTableViewController.h"
#import <CoreLocation/CoreLocation.h>

#define SCREEN self.view.frame.size

// iPhone4
#define iPhone4 ([UIScreen mainScreen].bounds.size.height == 480.0)
// iPhone5
#define iPhone5 ([UIScreen mainScreen].bounds.size.height == 568.0)
// iPhone6
#define iPhone6 ([UIScreen mainScreen].bounds.size.height == 667.0)
// iPhone6p
#define iPhone6p ([UIScreen mainScreen].bounds.size.height == 736.0)

@interface WFSecondMainViewController ()<UIScrollViewDelegate,CLLocationManagerDelegate,UINavigationControllerDelegate,WFCityTableViewControllerDelegate>

//数据
@property (nonatomic,strong) NFCityWeatherModel *currentCityWeather;
@property (nonatomic,strong) NFWeatherModel *todayWeather;

//@property (nonatomic,strong) NSMutableArray *weathers;

//存放多个cityWeather,用于数据持久化，
@property (nonatomic,strong) NSMutableArray *cities;

//视图刷新需要控制的label
@property (nonatomic,strong) UILabel *todayTempLabel;//实时温度
@property (nonatomic,strong) UILabel *todayHighTempLabel;//今日最高温
@property (nonatomic,strong) UILabel *todayLowTempLabel;//今日低温
@property (nonatomic,strong) UILabel *todayTypeLabel;//今日天气
@property (nonatomic,strong) UILabel *todayhumidityLabel;//空气湿度
@property (nonatomic,strong) UILabel *todayWindTypeLabel;//今日风向
@property (nonatomic,strong) UILabel *todayWindForceLabel; // 今日风向
@property (nonatomic,strong) UILabel *todayBodyTempLabel;
@property (nonatomic,strong) UIButton *cityNameButton;//城市名
@property (nonatomic,strong) UIPageControl *pageControl;//分页点
@property (nonatomic,strong) UILabel *lastUpdateTimeLabel;//上次刷新时间


@property (nonatomic,strong) WFDaysView *daysView;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UIScrollView *daysScrollView;


//下拉刷新

@end

@implementation WFSecondMainViewController {
    __block NSString *_city;
    CLLocationManager *locationManager;
    __block NSMutableString *_cityPinYin;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0 green:150/255.0f blue:1 alpha:1];

    self.navigationController.delegate = self;
    //初始化伪数据
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self initData];
        });
    
    //加载数据
    [self loadCityWeathers];
    
    //初始化 NavigationBar
    [self initNavigationBarLayout];

    
    [self loadViewWithCities];
//    [self initLayout];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark KVO监听方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
//    if ([keyPath isEqualToString:@"cities"] && object == self.cities) {
//        [self loadViewWithCities];
//        //刷新视图
////        [self loadViewWithCities];
//    }
}

#pragma mark 初始化 NavigationBar 页面布局
- (void)initNavigationBarLayout {
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
    //背景图片
    UIImageView *backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN.width, SCREEN.height)];
    UIImage *backgroudImage = [UIImage imageNamed:@"background.jpg"];
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    [backgroundImageView setImage:backgroudImage];
    [self.view addSubview:backgroundImageView];
    
    //navigationBar 标题及其颜色
    UIColor *titleColor = [UIColor whiteColor];
    NSDictionary *titleAttributesDic = [NSDictionary dictionaryWithObject:titleColor forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = titleAttributesDic;
    self.navigationItem.title = _currentCityWeather.cityName;
    
    //刷新按钮
    UIImage *refreshImage = [UIImage imageNamed:@"刷新.png"];
    refreshImage = [refreshImage rt_tintedImageWithColor:[UIColor whiteColor]];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setBackgroundImage:refreshImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(refreshClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    //管理按钮
    UIImage *settingImage = [UIImage imageNamed:@"Setting.png"];
    settingImage = [settingImage rt_tintedImageWithColor:[UIColor whiteColor]];
    UIButton *settingButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [settingButton setBackgroundImage:settingImage forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(cityManageClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:settingButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
}



#pragma mark 初始化数据
- (void) initData {
    
    self.cities = [[NSMutableArray alloc]init];
    
    //伪数据
    NFCityWeatherModel *cityWeather = [[NFCityWeatherModel alloc]init];
    cityWeather.cityName = @"广州";
    [self.cities addObject:cityWeather];
    
    NFCityWeatherModel *cityWeather1 = [[NFCityWeatherModel alloc]init];
    cityWeather1.cityName = @"北京";
    [self.cities addObject:cityWeather1];
    
    NFCityWeatherModel *cityWeather2 = [[NFCityWeatherModel alloc]init];
    cityWeather2.cityName = @"沧州";
    [self.cities addObject:cityWeather2];
    NSLog(@"-initData:_weathers.count = %ld",_cities.count);

    [self saveCityWeather];
    [self loadViewWithCities];
    
    //如果没有天气数据，则加载数据
    for (NFCityWeatherModel *tempCityWeather in _cities) {
        if (!tempCityWeather.weathers|| tempCityWeather.weathers.count < 7) {
            [self getWeatherForCityWeather:tempCityWeather];
        }
    }
    
}

#pragma mark 数据持久化
- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return documentsDirectory;
}

- (NSString *)dataFilePath {
    return [[self documentsDirectory] stringByAppendingPathComponent:@"Weather.plist"];
}

- (void)saveCityWeather {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data]; [archiver encodeObject:_cities forKey:@"Weather"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
    NSLog(@"<saveCityWeather>: dataFilePath = '%@'",[self dataFilePath]);
}

- (void)loadCityWeathers {
    
    NSString *path = [self dataFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.cities = [unarchiver decodeObjectForKey:@"Weather"];
        [unarchiver finishDecoding];
    } else {
        self.cities = [[NSMutableArray alloc] init];
    }
}


#pragma mark 根据 _cities 加载界面 ,
//进入软件 和 更改城市 两种情况调用，刷新视图
- (void) loadViewWithCities {
    
    //删除旧的
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    
    //如果_cities 为空，没有城市，则跳转到增加城市中，或者城市界面中返回键无法点击（点击事件设为一个alertView）
    if (!_cities || _cities.count == 0) {
        return;
    }
    //判断 cityWeather.weather ?= nil (在网络请求回调块里操作数据，并且刷新视图？)
    //还需要加入时间控制，防止数据过期出现bug，比如过了一天
    
    //重新加载
    int cityCount = (int)_cities.count;
    
    //pageControl
    self.pageControl = [[UIPageControl alloc]init];
    CGSize size = [_pageControl sizeForNumberOfPages:cityCount];    //此方法根据页书返回合适大小
    _pageControl.frame = CGRectMake(0, 0, size.width, size.height);
    _pageControl.center = CGPointMake(SCREEN.width/2, 68);
//    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0 green:150/255.0f blue:1 alpha:0.3];    //设置颜色
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:193.0/255.0 green:219/255.0f blue:249/255.0f alpha:1];    //设置当前页的颜色
    //设置总页数--> 由_weathers控制
    _pageControl.numberOfPages = cityCount;
    [self.view addSubview:_pageControl];
    
    
    //主滑动视图
    _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-self.view.frame.size.height/5*2)];
    _mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * cityCount, self.view.frame.size.height-self.view.frame.size.height/5*2);
    _mainScrollView.delegate = self;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.showsHorizontalScrollIndicator = NO;//隐藏滚动条
    _mainScrollView.showsVerticalScrollIndicator = NO;
    //mainScrollView.bounces = NO; 禁用弹簧效果
    [self.view addSubview:_mainScrollView];
    
    for (int i=0; i < cityCount; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(_mainScrollView.frame.size.width *i, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height)];
        [self configureView:view WithCityWeather:_cities[i]];
        [_mainScrollView addSubview:view];
    }
    
    
    //次滑动视图，温度折线图
    self.daysScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/5*3, self.view.frame.size.width, self.view.frame.size.height/5*2)];
    _daysScrollView.contentOffset = CGPointMake(0, 0);
    _daysScrollView.contentSize = CGSizeMake(self.view.frame.size.width*1.5, self.view.frame.size.height/5*2);
    _daysScrollView.showsVerticalScrollIndicator = NO;
    _daysScrollView.delegate = self;
    _daysScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_daysScrollView];
    //    [self.mainScrollView addSubview:_daysScrollView];
    
    
    
    self.daysView = [[WFDaysView alloc]initWithFrame:CGRectMake(0, 0, _daysScrollView.contentSize.width, _daysScrollView.contentSize.height)];
    _daysView.backgroundColor = [UIColor clearColor];
    [self.daysScrollView addSubview:_daysView];
//    _daysView.weathersToCalc = _weathers;
    [_daysView setNeedsDisplay];
}

#pragma mark 根据城市数据获取视图

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
    
    
    UILabel *lastUpdateTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(todayTempLabel.frame.origin.x, todayTempLabel.frame.origin.y+100, 200, 10)];
    lastUpdateTimeLabel.textColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.8];
    lastUpdateTimeLabel.textAlignment = NSTextAlignmentCenter;
    lastUpdateTimeLabel.font = [UIFont systemFontOfSize:10];
    lastUpdateTimeLabel.tag = 1008;
    [view addSubview:lastUpdateTimeLabel];
    
    
     //城市名 tag = 1020
     UIButton *cityNameButton = [UIButton buttonWithType:UIButtonTypeSystem];
     cityNameButton.frame = CGRectMake(SCREEN.width/2-40, 30, 80, 40);
     [cityNameButton setTitle:cityWeather.cityName forState:UIControlStateNormal];
         cityNameButton.titleLabel.text = [NSString stringWithFormat:@"%@",cityWeather.cityName];
     cityNameButton.titleLabel.textAlignment = NSTextAlignmentCenter;
     cityNameButton.titleLabel.textColor = [UIColor whiteColor];
     cityNameButton.tintColor = [UIColor whiteColor];
     cityNameButton.tag = 1020;
     [view addSubview:cityNameButton];
     //    self.cityNameButton = cityNameButton;
    
}


#pragma mark 刷新视图，传入数据 单个cityWeatherModel, 网络方法成功后调用此方法刷新对应的视图
//刷新视图
- (void) updateViewWithCityWeather:(NFCityWeatherModel *)cityWeather {
    //    self.daysView.weathersToCalc = new??
    
    //获取今日天气
    if (cityWeather.weathers.count < 7) {
        return;
    }
    
#warning 需要优化，增强稳定性
    //获取当前视图，和cityWeather 应当对应，或者用city Weather 来获取 i 的值，更保险
    NSArray *viewArray = [self.mainScrollView subviews];
    int i = (int)[_cities indexOfObject:cityWeather];
//    int i = _mainScrollView.contentOffset.x/_mainScrollView.frame.size.width;
    UIView *view = viewArray[i];
    
    
    NFWeatherModel *todayWeather = cityWeather.weathers[2];
    //刷新温度线视图
    self.daysView.weathersToCalc = cityWeather.weathers;
    [self.daysView setNeedsDisplay];
    self.daysScrollView.contentOffset = CGPointMake(0, 0);
    
    //重设实时温度
    self.todayTempLabel = [view viewWithTag:1001];
    self.todayTempLabel.text = [NSString stringWithFormat:@"%lu°",(unsigned long)todayWeather.curTemp];
    
    self.todayHighTempLabel = [view viewWithTag:1002];
    self.todayHighTempLabel.text = [NSString stringWithFormat:@"%lu°↑",todayWeather.hightemp];
    
    self.todayLowTempLabel = [view viewWithTag:1003];
    self.todayLowTempLabel.text = [NSString stringWithFormat:@"%lu°↓",todayWeather.lowtemp];
    
    self.todayhumidityLabel = [view viewWithTag:1004];
    //    self.todayhumidityLabel.text = _todayWeather.
    
    self.todayWindTypeLabel = [view viewWithTag:1005];
    self.todayWindTypeLabel.text = todayWeather.windType;
    
    //风力windForce tag = 1006
    self.todayWindForceLabel = [view viewWithTag:1006];
    self.todayWindForceLabel.text = todayWeather.windForce;
    //体感温度 bodyTemp .tag = 1007
    self.todayBodyTempLabel = [view viewWithTag:1007];
    self.todayBodyTempLabel.text = [NSString stringWithFormat:@"%lu°",(unsigned long)todayWeather.curTemp];
    
    self.lastUpdateTimeLabel = [view viewWithTag:1008];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@" HH:mm"];
    NSString *date = [formatter stringFromDate:cityWeather.lastDate];
    self.lastUpdateTimeLabel.text = [NSString stringWithFormat:@"上次刷新 %@",date];
    
    //重设城市名
    self.cityNameButton = [view viewWithTag:1020];
    [self.cityNameButton setTitle:cityWeather.cityName forState:UIControlStateNormal];
    
    
}

#pragma mark 获取天气
//需要将功能分离之后整合，天气方法只返回天气，增加获取时间，但有一个问题，直接赋值的话网络延迟无法正常获取，只能将需要更新的对象传给 天气方法，等下载之后进行赋值
//获取成功之后 保存数据
- (void)getWeatherForCityWeather:(NFCityWeatherModel *)cityWeather {
    if (!cityWeather.cityName) {
        NSLog(@"error: 获取天气失败，城市名为空");
        return;
    }
    
    //查询7天天气
    NSString *httpUrl = @"http://apis.baidu.com/apistore/weatherservice/recentweathers";
    //    NSString *httpArg = @"cityname=%E5%8C%97%E4%BA%AC&cityid=101010100";
    NSString *httpArg = [NSString stringWithFormat:@"cityname=%@",cityWeather.cityName];
    httpArg = [httpArg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self getCityWeatherWithRequest:httpUrl withHttpArg:httpArg forCityWeather:cityWeather];
    
}

- (void)getCityWeatherWithRequest: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg forCityWeather:(NFCityWeatherModel *)cityWeather {
    
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"d03b9f8e708c94bbf71ab4fbc60a4021" forHTTPHeaderField: @"apikey"];
    [NSURLConnection sendAsynchronousRequest: request queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
#pragma mark 解析数据   
                                   cityWeather.weathers = [self parseWeatherJSONData:data];
                                   
                                   //如何判断数据下载完成？
                                   if (cityWeather.weathers.count == 7) {
                                       //刷新视图
                                       //更新时间
                                       cityWeather.lastDate = [NSDate date];
                                       [self saveCityWeather];//保存数据
                                       
                                       for (int i = 0; i<_cities.count; i++) {
                                           NFCityWeatherModel *temp = _cities[i];
                                           if ([temp.cityName isEqualToString: cityWeather.cityName]) {
                                               [self updateViewWithCityWeather:_cities[i]];
                                           }
                                       }
                                   }
                               }
                           }];
}

#pragma mark 解析天气数据,返回需要的天气数据数组
-(NSArray *)parseWeatherJSONData:(NSData *)data {
    
    NSMutableArray *weathers = [[NSMutableArray alloc]init];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *retData = dict[@"retData"];
    NSLog(@"retData = %@",dict);
    
    NSMutableArray *forecast = [retData[@"forecast"] mutableCopy];
    NSDictionary *today = retData[@"today"];
    
    NSMutableArray *history = [retData[@"history"] mutableCopy];
    NSLog(@"forecast = %@",forecast);
    
    
    //过去两天的数据
    for (int i = 0; i < 2; i++) {
        NSDictionary *tempDict = history[5+i];
        NFWeatherModel *weatherModel = [[NFWeatherModel alloc]init];
        weatherModel.type = tempDict[@"type"];
        weatherModel.week = tempDict[@"week"];
        weatherModel.date = tempDict[@"date"];
        weatherModel.hightemp = [tempDict[@"hightemp"] integerValue];
        weatherModel.lowtemp = [tempDict[@"lowtemp"]integerValue];
        [weathers addObject:weatherModel];
        
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
    //NSLog(@"today[@\"date\"] = '%@'",todayWeatherModel.date);
    [weathers addObject:todayWeatherModel];
    self.todayWeather = todayWeatherModel;
    
    for (int i = 0; i<4; i++) {
        NSDictionary *tempDict = forecast[i];
        NFWeatherModel *weatherModel = [[NFWeatherModel alloc]init];
        weatherModel.type = tempDict[@"type"];
        weatherModel.week = tempDict[@"week"];
        weatherModel.date = tempDict[@"date"];
        weatherModel.hightemp = [tempDict[@"hightemp"] integerValue];
        weatherModel.lowtemp = [tempDict[@"lowtemp"]integerValue];
        [weathers addObject:weatherModel];
    }
    
    return weathers;
}

#pragma mark scrollView 代理方法
//如何确定视图切换了？？？？？？？？？
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //如果主视图滑动，切换城市，刷新视图
    if (scrollView == _mainScrollView) {
        
        int i = scrollView.contentOffset.x/scrollView.frame.size.width;
        
        self.pageControl.currentPage = i;
        
        
        NFCityWeatherModel *cityWeather =_cities[i];
        self.daysView.weathersToCalc = cityWeather.weathers;
        [self.daysView setNeedsDisplay];
        }
}

#pragma mark 刷新动作 
-(void) refreshClick:(UIButton *)button {
    int currentCityNumber = (int)self.mainScrollView.contentOffset.x/self.mainScrollView.frame.size.width;
    if (currentCityNumber < _cities.count) {
        NFCityWeatherModel *currentCity = _cities[currentCityNumber];
        [self getWeatherForCityWeather:currentCity];
        [self updateViewWithCityWeather:currentCity];
    }
}

#pragma mark 管理城市 按钮动作
- (void)cityManageClick:(UIButton *)button {
//    NSLog(@"<cityManageClick:>manageButtonclick");
    WFCityTableViewController *cityTableViewController = [[WFCityTableViewController alloc]init];
    cityTableViewController.cities = _cities;
    cityTableViewController.delegate = self;
    [self.navigationController pushViewController:cityTableViewController animated:YES];
}

#pragma mark 城市管理界面代理方法 Manage City Delegate 
-(void)WFCityTableViewController:(WFCityTableViewController *)viewController didFinishEditingCities:(NSMutableArray *)cities {
    self.cities = cities;
}

#pragma mark navigationController Delegate 方法
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"调用navigationController代理方法,navigationController:willShowViewController:animated:");
    if (viewController == self) {
        [self loadViewWithCities];
        for (int i = 0; i<_cities.count; i++) {
            [self updateViewWithCityWeather:_cities[i]];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == self) {
        [self loadViewWithCities];
    }
}




//******************************************************************************************

#ifdef zhushi

#pragma mark 根据城市天气，计算视图
- (void)configureView:(UIView *)view WithCityWeather:(NFCityWeatherModel *)cityWeather {
    
    NSLog(@"执行configureView:WithCityWeather");
    //需要判断city Weather.weathers 是不是空，如果空，则网络定位获取，如果不是，则直接加载
    
    //    if (cityWeather.weathers.count == 0) {
    //        NSLog(@"获取天气数据失败");
    //        return;
    //    }
    //    NSLog(@"初始化视图");
    //今日天气
    //    NFWeatherModel *todayWeather = cityWeather.weathers[2];
    
    
    //判断屏幕大小
    int fontSize = 25;
    if (iPhone4) {
        fontSize = 10;
    }else if(iPhone5) {
        fontSize = 15;
    }else if(iPhone6) {
        fontSize = 20;
    }else if(iPhone6p) {
        fontSize = 25;
    }
    UIFont *labelFont = [UIFont systemFontOfSize:fontSize];
    
    
    //实时温度label，20+80+100
    //温度tag = 1001
    self.todayTempLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN.width/2-100, 80, 200, 100)];
    _todayTempLabel.textColor = [UIColor whiteColor];
    //    _todayTempLabel.font = [UIFont systemFontOfSize:100.0];
    _todayTempLabel.font = [UIFont fontWithName:@"GillSans-Light" size:100];
    _todayTempLabel.textAlignment = NSTextAlignmentCenter;
    _todayTempLabel.text = @"N/A";
    _todayTempLabel.tag = 1001;
    [view addSubview:_todayTempLabel];
    
    //最高温度tag = 1002
    const CGRect todayTempLabelFrame = _todayTempLabel.frame;
    self.todayHighTempLabel = [[UILabel alloc]initWithFrame:CGRectMake(todayTempLabelFrame.origin.x + todayTempLabelFrame.size.width, todayTempLabelFrame.origin.y+10, 50, 30)];
    _todayHighTempLabel.textColor = [UIColor whiteColor];
    _todayHighTempLabel.text = @"N/A";
    _todayHighTempLabel.tag = 1002;
    [view addSubview:_todayHighTempLabel];
    
    //最低温度tag = 1003
    self.todayLowTempLabel = [[UILabel alloc]initWithFrame:CGRectMake(todayTempLabelFrame.origin.x + todayTempLabelFrame.size.width, todayTempLabelFrame.origin.y+10+40, 50, 30)];
    _todayLowTempLabel.textColor = [UIColor whiteColor];
    _todayLowTempLabel.text = @"N/A";
    _todayLowTempLabel.tag = 1003;
    [view addSubview:_todayLowTempLabel];
    
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
    
    
    UILabel *lastUpdateTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(_todayTempLabel.frame.origin.x, _todayTempLabel.frame.origin.y+100, 200, 10)];
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

#pragma mark 刷新视图 reloadView
- (void)updateView {
    
    int cityCount = (int)_weathers.count;
    self.pageControl.numberOfPages = cityCount;
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * cityCount, self.view.frame.size.height-self.view.frame.size.height/5*2);
    
    for (int i = 0; i < _mainScrollView.subviews.count; i++) {
        UIView *view = _mainScrollView.subviews[i];
        [view removeFromSuperview];
    }
    
    for (int i=0; i < _weathers.count; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(_mainScrollView.frame.size.width *i, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height)];
        [self configureView:view WithCityWeather:self.weathers[i]];
        [_mainScrollView addSubview:view];
        NSLog(@"调用次数= %d",i);
        [self updateViewWithCityWeather:_currentCityWeather];
    }
    //    int i = _mainScrollView.contentOffset.x/_mainScrollView.frame.size.width;
    //    if (_weathers.count > i) {
    //        NFCityWeatherModel *cityWeather = _weathers[i];
    //        [self updateViewWithCityWeather:cityWeather];
    //    }
}

//刷新视图
- (void) updateViewWithCityWeather:(NFCityWeatherModel *)cityWeather {
    //    self.daysView.weathersToCalc = new??
    
    //获取今日天气
    if (cityWeather.weathers.count < 7) {
        return;
    }
    
    NFWeatherModel *todayWeather = cityWeather.weathers[2];
    //刷新温度线视图
    self.daysView.weathersToCalc = cityWeather.weathers;
    [self.daysView setNeedsDisplay];
    self.daysScrollView.contentOffset = CGPointMake(0, 0);
    
    //重设实时温度
    NSArray *viewArray = [self.mainScrollView subviews];
    int i = _mainScrollView.contentOffset.x/_mainScrollView.frame.size.width;
    UIView *view = viewArray[i];
    
    self.todayTempLabel = [view viewWithTag:1001];
    self.todayTempLabel.text = [NSString stringWithFormat:@"%lu°",(unsigned long)todayWeather.curTemp];
    
    self.todayHighTempLabel = [view viewWithTag:1002];
    self.todayHighTempLabel.text = [NSString stringWithFormat:@"%lu°↑",todayWeather.hightemp];
    
    self.todayLowTempLabel = [view viewWithTag:1003];
    self.todayLowTempLabel.text = [NSString stringWithFormat:@"%lu°↓",todayWeather.lowtemp];
    
    self.todayhumidityLabel = [view viewWithTag:1004];
    //    self.todayhumidityLabel.text = _todayWeather.
    
    self.todayWindTypeLabel = [view viewWithTag:1005];
    self.todayWindTypeLabel.text = todayWeather.windType;
    
    //风力windForce tag = 1006
    self.todayWindForceLabel = [view viewWithTag:1006];
    self.todayWindForceLabel.text = todayWeather.windForce;
    //体感温度 bodyTemp .tag = 1007
    self.todayBodyTempLabel = [view viewWithTag:1007];
    self.todayBodyTempLabel.text = [NSString stringWithFormat:@"%lu°",(unsigned long)todayWeather.curTemp];
    
    self.lastUpdateTimeLabel = [view viewWithTag:1008];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"a hh:mm"];
    NSString *date = [formatter stringFromDate:cityWeather.lastDate];
    self.lastUpdateTimeLabel.text = [NSString stringWithFormat:@"上次刷新 %@",date];
    //重设城市名
    //    self.cityNameButton = [view viewWithTag:1020];
    //    [self.cityNameButton setTitle:_city forState:UIControlStateNormal];
    
    
}

#pragma mark scrollView 代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //如果主视图滑动，切换城市，刷新视图
    if (scrollView == _mainScrollView) {
        
        int i = scrollView.contentOffset.x/scrollView.frame.size.width;
        
        self.pageControl.currentPage = i;
        
        if (_weathers.count>i) {
            self.currentCityWeather = _weathers[i];
            self.navigationItem.title = _currentCityWeather.cityName;
            NSDate *curDate = [NSDate date];
            
            [self getWeatherForCityWeather:_currentCityWeather];
            [self updateViewWithCityWeather:_currentCityWeather];
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}


#pragma mark 获取地址,赋值给 _city
- (NSString *) getLoacation {
    
    [self initializeLocationService];
    
    NSLog(@"return city = '%@'",_city);
    return _city;
}



#pragma mark - 初始化定位管理器
- (void)initializeLocationService {
    // 判断是否开启定位
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager requestAlwaysAuthorization];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 10;
        [locationManager startUpdatingLocation];
    }
}
#pragma mark - 定位代理方法
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    NSLog(@"经度:%lf",newLocation.coordinate.longitude);
    NSLog(@"纬度:%lf",newLocation.coordinate.latitude);
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
        if (array.count > 0){
            CLPlacemark *placemark = [array objectAtIndex:0];
            //            NSLog(@"placemark = %@",placemark);
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            NSLog(@"city = '%@'", city);
            //将获得的城市名，去掉“市”
            city = [city stringByReplacingOccurrencesOfString:@"市" withString:@""];
            NSLog(@"city = %@",city);
            _city = city;
            [_cities setObject:city atIndexedSubscript:0];
            [_cities addObject:@"北京"];
            
            //转换拼音
            _cityPinYin = [city mutableCopy];
            CFStringTransform((__bridge CFMutableStringRef)_cityPinYin, NULL, kCFStringTransformMandarinLatin, NO);
            CFStringTransform((__bridge CFMutableStringRef)_cityPinYin, NULL, kCFStringTransformStripCombiningMarks, NO);
            NSLog(@"获取地址'%@''%@'",city,_cityPinYin);
            _cityPinYin = [[_cityPinYin stringByReplacingOccurrencesOfString:@" " withString:@""]mutableCopy];
            
            //如果定位刷新，重新获取天气，刷新视图
            
        }
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"No results were returned.");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:@"定位失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:@"定位失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
}


#pragma mark 获取天气

- (void)getWeatherForCityWeather:(NFCityWeatherModel *)cityWeather {
    if (!cityWeather.cityName) {
        NSLog(@"error: can't get weather, city is nil");
        return;
    }
    
    //查询7天天气
    NSString *httpUrl = @"http://apis.baidu.com/apistore/weatherservice/recentweathers";
    //    NSString *httpArg = @"cityname=%E5%8C%97%E4%BA%AC&cityid=101010100";
    NSString *httpArg = [NSString stringWithFormat:@"cityname=%@",cityWeather.cityName];
    httpArg = [httpArg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self getCityWeatherWithRequest:httpUrl withHttpArg:httpArg forCityWeather:cityWeather];
    
}

- (void)getCityWeatherWithRequest: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg forCityWeather:(NFCityWeatherModel *)cityWeather {
    
    
    __block NSMutableArray *weathers = [[NSMutableArray alloc]init];
    NSDate *date = [NSDate date];
    cityWeather.lastDate = date;
    
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"d03b9f8e708c94bbf71ab4fbc60a4021" forHTTPHeaderField: @"apikey"];
    [NSURLConnection sendAsynchronousRequest: request queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
#pragma mark 解析数据
                                   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                   
                                   NSDictionary *retData = dict[@"retData"];
                                   NSLog(@"retData = %@",dict);
                                   NSMutableArray *forecast = [retData[@"forecast"] mutableCopy];
                                   NSDictionary *today = retData[@"today"];
                                   NSMutableArray *history = [retData[@"history"] mutableCopy];
                                   NSLog(@"forecast = %@",forecast);
                                   
                                   
                                   //过去两天的数据
                                   for (int i = 0; i < 2; i++) {
                                       NSDictionary *tempDict = history[5+i];
                                       NFWeatherModel *weatherModel = [[NFWeatherModel alloc]init];
                                       weatherModel.type = tempDict[@"type"];
                                       weatherModel.week = tempDict[@"week"];
                                       weatherModel.date = tempDict[@"date"];
                                       weatherModel.hightemp = [tempDict[@"hightemp"] integerValue];
                                       weatherModel.lowtemp = [tempDict[@"lowtemp"]integerValue];
                                       [weathers addObject:weatherModel];
                                       
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
                                   //                                   NSLog(@"today[@\"date\"] = '%@'",todayWeatherModel.date);
                                   [weathers addObject:todayWeatherModel];
                                   self.todayWeather = todayWeatherModel;
                                   
                                   for (int i = 0; i<4; i++) {
                                       NSDictionary *tempDict = forecast[i];
                                       NFWeatherModel *weatherModel = [[NFWeatherModel alloc]init];
                                       weatherModel.type = tempDict[@"type"];
                                       weatherModel.week = tempDict[@"week"];
                                       weatherModel.date = tempDict[@"date"];
                                       weatherModel.hightemp = [tempDict[@"hightemp"] integerValue];
                                       weatherModel.lowtemp = [tempDict[@"lowtemp"]integerValue];
                                       [weathers addObject:weatherModel];
                                       
                                       cityWeather.weathers = weathers;
                                       NSLog(@"weathers.count = %lu",(unsigned long)weathers.count);
                                       //如何判断数据下载完成？
                                       if (weathers.count == 7) {
                                           [self updateViewWithCityWeather:_currentCityWeather];
                                       }
                                   }
                                   
                               }
                           }];
    
}


- (void) getWeather {
    
    //城市为空则直接return，防止crash
    if (!_city) {
        return;
    }
    
    //    NSString *httpUrl = @"http://apis.baidu.com/apistore/weatherservice/weather";
    //        NSString *httpArg = @"citypinyin=beijing";
    //    NSString *httpArg = [NSString stringWithFormat:@"citypinyin=%@",_cityPinYin];
    
    //查询7天天气
    NSString *httpUrl = @"http://apis.baidu.com/apistore/weatherservice/recentweathers";
    //    NSString *httpArg = @"cityname=%E5%8C%97%E4%BA%AC&cityid=101010100";
    NSString *httpArg = [NSString stringWithFormat:@"cityname=%@",_city];
    httpArg = [httpArg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self request: httpUrl withHttpArg: httpArg];
    
    //查询城市列表
    //    NSString *httpUrl = @"http://apis.baidu.com/apistore/weatherservice/citylist";
    //    NSString *httpArg = @"cityname=%E6%9C%9D%E9%98%B3";
    //    httpArg = [httpArg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    [self request: httpUrl withHttpArg: httpArg];
    
    
    
    
    //    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",httpUrl,httpArg]];
    //    //    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //    //    [self request: httpUrl withHttpArg: httpArg];
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    //    [request setHTTPMethod: @"GET"];
    //    [request addValue: @"d03b9f8e708c94bbf71ab4fbc60a4021" forHTTPHeaderField: @"apikey"];
    
    
    //    //1.管理器
    //    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    //2.登录参数设置
    //    NSDictionary *dic = @{@"apikey":@"d03b9f8e708c94bbf71ab4fbc60a4021"};
    //    //3.请求
    //    [manager GET:[NSString stringWithFormat:@"%@%@",httpUrl,httpArg] parameters:dic success:  ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    //        NSLog(@"%@", responseObject);
    //        [self parseDictionary:responseObject];
    //        [self.tableView reloadData];
    //    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
    //        NSLog(@"Failure! %@", error);
    //    }];
    
    
    
    //    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    //    [operation setCompletionBlockWithSuccess:^ (AFHTTPRequestOperation *operation, id responseObject) {   NSLog(@"Success! %@", responseObject);
    //                [self parseDictionary:responseObject];
    //                [self.tableView reloadData];
    //
    //            } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
    //                NSLog(@"Failure! %@", error); }];
    //    [_queue addOperation:operation];
    
    //    NSLog(@"return weather = '%@'",_weather);
    //    return _weather;
    
}



-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    
    //查询城市列表，城市名＋id,应当用定位城市名 从城市列表获取城市名和id，再进行天气查询
    /*
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
     */
    
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
                                   
                                   
                                   
                                   self.weathers = [[NSMutableArray alloc]initWithCapacity:7];
                                   //过去两天的数据
                                   for (int i = 0; i < 2; i++) {
                                       NSDictionary *tempDict = history[5+i];
                                       NFWeatherModel *weatherModel = [[NFWeatherModel alloc]init];
                                       weatherModel.type = tempDict[@"type"];
                                       weatherModel.week = tempDict[@"week"];
                                       weatherModel.date = tempDict[@"date"];
                                       weatherModel.hightemp = [tempDict[@"hightemp"] integerValue];
                                       weatherModel.lowtemp = [tempDict[@"lowtemp"]integerValue];
                                       [self.weathers addObject:weatherModel];
                                       
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
                                   [self.weathers addObject:todayWeatherModel];
                                   self.todayWeather = todayWeatherModel;
                                   
                                   for (int i = 0; i<4; i++) {
                                       NSDictionary *tempDict = forecast[i];
                                       NFWeatherModel *weatherModel = [[NFWeatherModel alloc]init];
                                       weatherModel.type = tempDict[@"type"];
                                       weatherModel.week = tempDict[@"week"];
                                       weatherModel.date = tempDict[@"date"];
                                       weatherModel.hightemp = [tempDict[@"hightemp"] integerValue];
                                       weatherModel.lowtemp = [tempDict[@"lowtemp"]integerValue];
                                       [self.weathers addObject:weatherModel];
                                   }
                                   
                                   //                                   [self reloadView];
                               }
                           }];
    
    
}
//
//- (int) intFromString:(NSString *)string {
////    NSMutableString *mutStr = [NSMutableString string];
//    int result = 0;
//
////    for (int i = 0; i < [string lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
////        NSLog(@"%lu",(unsigned long)[string length]);
////        NSLog(@"%lu",(unsigned long)[string lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]);
////        NSString *s = [string substringToIndex:i];
////        if ([s isEqualToString:@"\\"]) {
////            return result;
////        }
//////        [mutStr appendString:s];
////        mutStr = [s mutableCopy];
////        result = [mutStr intValue];
////    }
//    NSString *s = [string substringToIndex:1];
//    result = [s intValue];
//
//    return result;
//}

#pragma mark 管理城市 按钮动作
- (void)cityManageClick:(UIButton *)button {
    NSLog(@"<cityManageClick:>manageButtonclick");
    WFCityTableViewController *cityTableViewController = [[WFCityTableViewController alloc]init];
    cityTableViewController.weathers = _weathers;
    [self.navigationController pushViewController:cityTableViewController animated:YES];
}


#pragma mark navigationControllerDelegate 透明效果
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLog(@"navigationBar 半透明代码");
    if (viewController == self) {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0];
        self.navigationController.navigationBar.alpha = 0;
        //        self.navigationController.navigationBar.translucent = YES;
    }else {
        self.navigationController.navigationBar.alpha = 1;
        self.navigationController.navigationBar.tintColor = nil;
        self.navigationController.navigationBar.translucent = NO;
    }
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == self) {
        NSLog(@"show self");
    }
}

#pragma mark 状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark 城市管理 CityManage Delegate 方法
- (void)WFCityTableViewController:(WFCityTableViewController *)viewController didFinishEditingWeathers:(NSMutableArray *)weathers {
    self.weathers = weathers;
    //    [self updateView];
    //    [self initLayout];
}
#endif
@end
