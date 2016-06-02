//
//  WFCityTableViewController.m
//  weatherForecast
//
//  Created by 刘帅 on 5/25/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "WFCityManageViewController.h"
#import "NFCityWeatherModel.h"
#import "NFWeatherModel.h"
#import "WFSearchViewController.h"
#import "WFSearchCityViewController.h"


@interface WFCityManageViewController ()<WFSearchViewControllerDelegate,UINavigationControllerDelegate>

@end

@implementation WFCityManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.delegate = self;
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];

    //navigationBar 标题及其颜色
    UIColor *titleColor = [UIColor grayColor];
    NSDictionary *titleAttributesDic = [NSDictionary dictionaryWithObject:titleColor forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = titleAttributesDic;
    self.navigationItem.title = @"城市管理";
    
//    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *addCityButton = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addCityClick:)];
    self.navigationItem.rightBarButtonItem = addCityButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(calcelClick:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //手势识别
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 手势识别方法
- (IBAction)longPressGestureRecognized:(id)sender {
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    //找到对应位置的cell的indexPath
    CGPoint location = [longPress locationInView:self.tableView];   //获取手指的point
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    
    static UIView *snapshot = nil; ///<A snapshot of the row user is moving>
    static NSIndexPath *sourceIndexPath = nil; ///<Initial index path, where gesture begins>
    switch (state) {
        case UIGestureRecognizerStateBegan: {   //识别开始
            if (indexPath) {    //如果是点击的cell
                sourceIndexPath = indexPath;//记录源indexPath
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];   //获取到对应的cell
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                
                //Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;//获取cell的center
                snapshot.center = center;   //设置snapshot的center
                snapshot.alpha = 0.0;   //开始透明状态
                [self.tableView addSubview:snapshot];   //添加到视图
                [UIView animateWithDuration:0.25 animations:^{  //添加动画
                    //Offset for gesture location
                    center.y = location.y;  //追踪手指
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;//淡出效果，放大实现抬起效果
                    
                    // Black out.
                    cell.backgroundColor = [UIColor grayColor];
                } completion:nil];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: { //手指移动
            CGPoint center = snapshot.center;   //重设snapshot的y，追踪手指
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                // ... update data source.
                [self.cities exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move to rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                // Undo the black-out effect we did.
                cell.backgroundColor = [UIColor whiteColor];
            }completion:^(BOOL finished) {
                [snapshot removeFromSuperview];
                snapshot = nil;
            }];
            sourceIndexPath = nil;
            break;
        }
    }
}

#pragma mark - snapshot
//根据传入view返回对应的 snapshot view
- (UIView * )customSnapshotFromView:(UIView *)inputView {
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0f;
    snapshot.layer.shadowOpacity= 0.4;
    
    return snapshot;
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"CityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    NFCityWeatherModel *cityWeatherModel = [_cities objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@省 %@市 %@",cityWeatherModel.province_cn,cityWeatherModel.district_cn,cityWeatherModel.name_cn];
    NFWeatherModel *todayWeather = [cityWeatherModel.weathers objectAtIndex:7];
   
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  %lu°-%lu° ",todayWeather.type,(unsigned long)todayWeather.lowtemp,(unsigned long)todayWeather.hightemp];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - table View delegate

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_cities removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate WFCityTableViewController:self didSelectedRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NFCityWeatherModel *sourceCity = _cities[sourceIndexPath.row];
    [_cities insertObject:sourceCity atIndex:destinationIndexPath.row];
    [_cities removeObject:sourceCity];
    
}

#pragma mark 添加城市
- (void)addCityClick:(UIButton *)button {
    NSLog(@"addCityClick");
//    WFSearchViewController *searchVC = [[WFSearchViewController alloc]init];
//    searchVC.delegate = self;
    WFSearchCityViewController *searchCityVC = [[WFSearchCityViewController alloc]init];
    [self.navigationController pushViewController:searchCityVC animated:YES];
}
- (void)calcelClick:(UIButton *)button {
    
    [self.delegate WFCityTableViewController:self didFinishEditingCities:_cities];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark WFSearchViewControllerDelegate
- (void)WFSearchViewController:(WFSearchViewController *)viewController SelectedCity:(NFCityWeatherModel *)city {
    [self.navigationController popViewControllerAnimated:viewController];
    [self.cities addObject:city];
    NSLog(@"self.cities.count = '%lu'",(unsigned long)self.cities.count);
    [self.tableView reloadData];
}

@end
