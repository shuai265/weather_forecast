//
//  ViewController.m
//  AddressInfo
//
//  Created by Alesary on 16/1/6.
//  Copyright © 2016年 Mr.Chen. All rights reserved.
//

#import "WFSearchCityViewController.h"
#import "ZWCollectionViewFlowLayout.h"
#import "Public.h"
#import "HeadView.h"
#import "CityViewCell.h"

#import "NBSearchResultController.h"
#import "NBSearchController.h"
#import "SearchResult.h"
#import "NSMutableArray+FilterElement.h"
//#import "RootViewController.h"

#import "WFSearchViewController.h"
#import "NFCityWeatherModel.h"

#import <CoreLocation/CoreLocation.h>


@interface WFSearchCityViewController ()<UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,NBSearchResultControllerDelegate,CityViewCellDelegate,WFSearchViewControllerDelegate,UINavigationControllerDelegate>
{
   UITableView *_tableView;
   HeadView    *_CellHeadView;
   NSMutableArray * _locationCity; //定位当前城市

   NSMutableArray *_dataArray; //定位，最近，热门数据原
    
   NSMutableDictionary *_allCitysDictionary; //所有数据字典
   NSMutableArray *_keys; //城市首字母

}
@property (nonatomic, strong)NBSearchController *searchController; //搜索的控制器

@property (nonatomic, strong)NSMutableArray *searchList; //搜索结果的数组

@property (nonatomic, strong)NBSearchResultController *searchResultController; //搜索的结果控制器

@property(strong,nonatomic)NSMutableArray *allCityArray;  //所有城市数组

@property (nonatomic, strong) CLLocationManager *locationManager; //定位

@property (nonatomic, strong) NFCityWeatherModel *cityWeather;
@end

@implementation WFSearchCityViewController

#pragma mark - 懒加载一些内容
-(NSMutableArray *)allCityArray
{
    if (!_allCityArray) {
        _allCityArray = [NSMutableArray array];
    }
    return _allCityArray;
}
- (NSMutableArray *)searchList
{
    if (!_searchList) {
        _searchList = [NSMutableArray array];
    }
    return _searchList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self locate];
    [self loadData];
    [self initTableView];
    [self initSearchController];
    
    //设置navigation Bar 的颜色
//    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.translucent = NO;//不透明
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;//影响状态栏
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
    NSLog(@"search city view did load");
//    self.navigationController.navigationBar.barTintColor=RGB(44, 166, 248);
//    NSMutableDictionary *titleAttr = [NSMutableDictionary dictionary];
//    titleAttr[NSForegroundColorAttributeName] = [UIColor blueColor];
//    [self.navigationController.navigationBar setTitleTextAttributes:titleAttr];
    

}

-(void)loadData
{
    _dataArray=[NSMutableArray array];
    //定位城市
    _locationCity=[NSMutableArray arrayWithObject:@"北京市"];
    [_dataArray addObject:_locationCity];
    
    //最近访问
    NSArray *recentArray=[NSArray arrayWithObjects:@"青岛市",@"济南市",@"深圳市",@"长沙市",@"无锡市", nil];
    [_dataArray addObject:recentArray];
    
    //热门城市
    NSArray *hotCity=[NSArray arrayWithObjects:@"广州市",@"北京市",@"天津市",@"西安市",@"重庆市",@"沈阳市",@"青岛市",@"济南市",@"深圳市",@"长沙市",@"无锡市", nil];
    [_dataArray addObject:hotCity];
    
    //索引城市
     NSString *path=[[NSBundle mainBundle] pathForResource:@"citydict" ofType:@"plist"];
     _allCitysDictionary=[NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    //将所有城市放到一个数组里
    for (NSArray *array in _allCitysDictionary.allValues) {
        for (NSString *citys in array) {
            [self.allCityArray addObject:citys];
        }
    }
    
    
    _keys=[NSMutableArray array];
    [_keys addObjectsFromArray:[[_allCitysDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    
    //添加多余三个索引
    [_keys insertObject:@"Θ" atIndex:0];
    [_allCitysDictionary setObject:hotCity forKey:@"Θ"];
     [_keys insertObject:@"♡" atIndex:0];
    [_allCitysDictionary setObject:recentArray forKey:@"♡"];
     [_keys insertObject:@"◎" atIndex:0];
    [_allCitysDictionary setObject:_locationCity forKey:@"◎"];
}
-(void)initTableView
{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, screen_width, screen_height) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.sectionIndexColor = RGB(150, 150, 150);
    [self.view addSubview:_tableView];
}
-(void)initSearchController //创建搜索控制器
{
    self.searchResultController=[[NBSearchResultController alloc]init];
    self.searchResultController.delegate=self;
    _searchController=[[NBSearchController alloc]initWithSearchResultsController:self.searchResultController];
    _searchController.delegate = self;
    _searchController.searchResultsUpdater=self;
    _searchController.searchBar.delegate = self;
    _tableView.tableHeaderView = self.searchController.searchBar;
    
    
}

//************************  ";" error?  *********************
//修改SearchBar的Cancel Button 的Title
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar;
{
    [_searchController.searchBar setShowsCancelButton:YES animated:YES];
    UIButton *btn=[_searchController.searchBar valueForKey:@"_cancelButton"];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section<=2) {
        return 1;
    }else{
        
        NSArray *array=[_allCitysDictionary objectForKey:[_keys objectAtIndex:section]];
        
        return array.count;
    }
  
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _keys.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section<=2) {
        
        return [CityViewCell getHeightWithCityArray:_dataArray[indexPath.section]];
    }else{
        
        return 47;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section<=2) {
        
        static NSString *identfire=@"Cell";
        
        CityViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identfire];
        
        if (!cell) {
            
            cell=[[CityViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identfire];
        }
        
        cell.delegate=self;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell setContentView:_dataArray[indexPath.section]];
        return cell;
        
    }else{
    
        static NSString *identfire=@"cellID";
        
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identfire];
        
        if (!cell) {
            
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identfire];
        }
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        NSArray *array=[_allCitysDictionary objectForKey:[_keys objectAtIndex:indexPath.section]];
        
        cell.textLabel.text=array[indexPath.row];
        return cell;
    }
    
   
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    _CellHeadView=[[HeadView alloc]init];
    
    if (section==0) {
        
        _CellHeadView.TitleLable.text=@"当前城市";
    }else if (section==1){
      
        _CellHeadView.TitleLable.text=@"最近访问";
        
    }
    else if (section==2){
        
        _CellHeadView.TitleLable.text=@"热门城市";
        
    }else{
    
      _CellHeadView.TitleLable.text=_keys[section];
    }
    
    return _CellHeadView;
}


///____________________________________________________________________________
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array=[_allCitysDictionary objectForKey:[_keys objectAtIndex:indexPath.section]];
//    NSLog(@"点击行");
//    [self popRootViewControllerWithName:array[indexPath.row]];
    [self pustSearchResultViewControllerWithName:array[indexPath.row]];
}

-(void)SelectCityNameInCollectionBy:(NSString *)cityName
{
    [self pustSearchResultViewControllerWithName:cityName];
//  [self popRootViewControllerWithName:cityName];
}
#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = [self.searchController.searchBar text];
    // 移除搜索结果数组的数据
    [self.searchList removeAllObjects];
    //过滤数据
    self.searchList= [SearchResult getSearchResultBySearchText:searchString dataArray:self.allCityArray];
    if (searchString.length==0&&self.searchList!= nil) {
        [self.searchList removeAllObjects];
    }
    self.searchList = [self.searchList filterTheSameElement];
    NSMutableArray *dataSource = nil;
    if ([self.searchList count]>0) {
        dataSource = [NSMutableArray array];
        // 结局了数据重复的问题
        for (NSString *str in self.searchList) {
            [dataSource addObject:str];
        }
    }
    
    //刷新表格
    self.searchResultController.dataSource = dataSource;
    [self.searchResultController.tableView reloadData];
    [_tableView reloadData];
   
}
/**
 *  点击了搜索的结果的 cell
 *
 *  @param resultVC  搜索结果的控制器
 *  @param follow    搜索结果信息的模型
 */
- (void)resultViewController:(NBSearchResultController *)resultVC didSelectFollowCity:(NSString *)cityName
{
    self.searchController.searchBar.text =@"";
    [self.searchController dismissViewControllerAnimated:NO completion:nil];
//    [self popRootViewControllerWithName:cityName];
    [self pustSearchResultViewControllerWithName:cityName];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
- (void)locate{
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        //定位初始化
        _locationManager=[[CLLocationManager alloc] init];
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter=10;
        if (iOSVersion>=8) {
            [_locationManager requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8定位需要）
        }
        [_locationManager startUpdatingLocation];//开启定位
    }else {
        //提示用户无法进行定位操作
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"定位不成功 ,请确认开启定位" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
    // 开始定位
    [_locationManager startUpdatingLocation];
}
#pragma mark - CLLocationManagerDelegate
/**
 *  只要定位到用户的位置，就会调用（调用频率特别高）
 *  @param locations : 装着CLLocation对象
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             //NSLog(@%@,placemark.name);//具体位置
             //获取城市
             NSString *city = placemark.locality;
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             [_locationCity replaceObjectAtIndex:0 withObject:city];
             [_tableView reloadData];
             
             //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
             [manager stopUpdatingLocation];
         }else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.searchController.active?nil:_keys;
}
-(void)returnText:(ReturnCityName)block
{
    self.returnBlock=block;
}
- (void)popRootViewControllerWithName:(NSString *)cityName
{
    self.returnBlock(cityName);
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)pustSearchResultViewControllerWithName:(NSString *)cityName {
//    self.returnBlock(cityName);
    WFSearchViewController *searchViewController = [[WFSearchViewController alloc]init];
    searchViewController.searchText = cityName;
    [self.navigationController pushViewController:searchViewController animated:YES];
}

#pragma mark WFSearchViewControllerDelegate
- (void)WFSearchViewController:(WFSearchViewController *)viewController SelectedCity:(NFCityWeatherModel *)city {
    self.cityWeather = city;
}


@end
