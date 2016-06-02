//
//  WFSearchViewController.m
//  weatherForecast
//
//  Created by 刘帅 on 5/27/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "WFSearchViewController.h"
#import "NFCityWeatherModel.h"
#import "WFSearchCity.h"


static NSString * const LoadingCellIdentifier = @"LoadingCell";
static NSString * const NothingFoundCellIdentifier = @"NothingFoundCell";

@interface WFSearchViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic,weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *searchResult;
@end

@implementation WFSearchViewController {
    WFSearchCity *_search;
    UIStatusBarStyle _statusBarStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

//    self.searchBar.backgroundColor = [UIColor clearColor];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.rowHeight = 44;
    
    if (_searchText) {
        NSString *searchCity = [[NSString alloc]init];
        if (_searchText.length>2) {
            searchCity = [_searchText substringToIndex:2];
        }else {
            searchCity = _searchText;
        }
        NSLog(@"searchCity = %@",searchCity);
        [self performSearchWithCityName:searchCity];
    }
    
    UINib *cellNib = [UINib nibWithNibName:LoadingCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:LoadingCellIdentifier];
    
    cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
//        [self.searchBar becomeFirstResponder];
    }
    
    _statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark 设置状态栏
//状态栏
- (UIStatusBarStyle)preferredStatusBarStyle {
    return  _statusBarStyle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_search == nil) {
        return 0;//not searched yet
    } else if(_search.isLoading) {
        return 1;//loading
    } else if(_search.searchResult.count == 0) {
        return 1;//nothing found
    } else {
        return [_search.searchResult count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    if (_search.isLoading) {
//        cell.textLabel.text = @"正在搜索";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadingCellIdentifier forIndexPath:indexPath];
        UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:100];
        [spinner startAnimating];

        return cell;
        
    } else if([_search.searchResult count] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier forIndexPath:indexPath];
    } else {
        NFCityWeatherModel *city = _search.searchResult[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@省 %@市 %@",city.province_cn,city.district_cn,city.name_cn];
        
    }
    return cell;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NFCityWeatherModel *city = (NFCityWeatherModel *)_search.searchResult[indexPath.row];
//    city.cityName = self.searchText;    //需要改一下天气搜索
    [self.delegate WFSearchViewController:self SelectedCity:city];
    NSLog(@"city 省市区 = '%@ %@ %@'",city.province_cn,city.district_cn,city.name_cn);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *cityData = [NSKeyedArchiver archivedDataWithRootObject:city];
    [defaults setObject:cityData forKey:@"addCity"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_search.searchResult count]==0 || _search.isLoading) {
        return nil;
    } else {
        return indexPath;
    }
}


#pragma mark - UISearchBarDelegate
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self performSearch];
}


- (void)performSearch {
    _search = [[WFSearchCity alloc]init];
    
    [_search performSearchForText:self.searchBar.text completion:^(BOOL success,NSArray *searchResult) {
        if (!success) {
            [self showNetWorkError];
        }
        
        self.searchResult = searchResult;
        [self.tableView reloadData];
    }];
    
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

#pragma 直接根据传进来的self.cityName 进行搜索
- (void)performSearchWithCityName:(NSString *)cityName {
    _search = [[WFSearchCity alloc]init];
    
    [_search performSearchForText:cityName completion:^(BOOL success,NSArray *searchResult) {
        if (!success) {
            [self showNetWorkError];
        }
        
        
        [self.tableView reloadData];
    }];
    
    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

- (void)showNetWorkError {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"错误", @"Error alert: title") message:NSLocalizedString(@"网络错误，请检查网络连接", @"Error alert: message") delegate:nil
        cancelButtonTitle:NSLocalizedString(@"确定", @"Error alert: calcel button") otherButtonTitles:nil, nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
