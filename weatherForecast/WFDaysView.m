//
//  WFDaysView.m
//  weatherForecast
//
//  Created by 刘帅 on 5/19/16.
//  Copyright © 2016 刘帅. All rights reserved.
//

#import "WFDaysView.h"
#import "NFWeatherModel.h"
#import "NSDate+WFDateExtension.h"

#define SIZE self.frame.size

@interface WFDaysView ()
@property (nonatomic,strong) NSMutableArray *highTemp;
@property (nonatomic,strong) NSMutableArray *lowtemp;
@property (nonatomic,strong) NSArray *highPoint;
@property (nonatomic,strong) NSArray *lowPoint;
@property (nonatomic,strong) NSArray *weathers;
@property (nonatomic,strong) NSArray *dates;

@end

@implementation WFDaysView {

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (void)drawRect:(CGRect)rect {
    
//    self.tintColor = [UIColor whiteColor];
//    [self initData];
    
    if (self.weathersToCalc != nil) {
        self.weathers = self.weathersToCalc;
        //取得图形上下文
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //获取高温点高度
        self.highPoint = [self getHighPoint];
        NSNumber * h0 = _highPoint[0];
        NSNumber * h1 = _highPoint[1];
        NSNumber * h2 = _highPoint[2];
        NSNumber * h3 = _highPoint[3];
        NSNumber * h4 = _highPoint[4];
        NSNumber * h5 = _highPoint[5];
        NSNumber * h6 = _highPoint[6];
        
        self.lowPoint = [self getLowPoint];
        //    NSLog(@"lowpoint = %@",self.lowPoint);
        NSNumber * l0 = _lowPoint[0];
        NSNumber * l1 = _lowPoint[1];
        NSNumber * l2 = _lowPoint[2];
        NSNumber * l3 = _lowPoint[3];
        NSNumber * l4 = _lowPoint[4];
        NSNumber * l5 = _lowPoint[5];
        NSNumber * l6 = _lowPoint[6];
        
        
        //创建路径对象
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, 40, h0.intValue);
        CGPathAddLineToPoint(path, nil, (40+self.frame.size.width-80)/6*1, h1.intValue);
        CGPathAddLineToPoint(path, nil, (40+self.frame.size.width-80)/6*2, h2.intValue);
        CGPathAddLineToPoint(path, nil, (40+self.frame.size.width-80)/6*3, h3.intValue);
        CGPathAddLineToPoint(path, nil, (40+self.frame.size.width-80)/6*4, h4.intValue);
        CGPathAddLineToPoint(path, nil, (40+self.frame.size.width-80)/6*5, h5.intValue);
        CGPathAddLineToPoint(path, nil, (40+self.frame.size.width-80)/6*6, h6.intValue);
        
        CGMutablePathRef path2 = CGPathCreateMutable();
        CGPathMoveToPoint(path2, nil, 50, l0.intValue);
        CGPathAddLineToPoint(path2, nil, 50+(self.frame.size.width-100)/6*1, l1.intValue);
        CGPathAddLineToPoint(path2, nil, 50+(self.frame.size.width-100)/6*2, l2.intValue);
        CGPathAddLineToPoint(path2, nil, 50+(self.frame.size.width-100)/6*3, l3.intValue);
        CGPathAddLineToPoint(path2, nil, 50+(self.frame.size.width-100)/6*4, l4.intValue);
        CGPathAddLineToPoint(path2, nil, 50+(self.frame.size.width-100)/6*5, l5.intValue);
        CGPathAddLineToPoint(path2, nil, 50+(self.frame.size.width-100)/6*6, l6.intValue);
        
        //3.添加路径到图形上下文
        CGContextAddPath(context, path);
        CGContextAddPath(context, path2);
        //4.设置图形上下文状态属性
        CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);    //设置笔触颜色
        CGContextSetLineWidth(context, 2.0f);//线条宽度
        CGContextSetLineCap(context, kCGLineCapRound);//顶点样式
        CGContextSetLineJoin(context, kCGLineJoinRound);//连接点样式
        
        //5.绘制图像到指定图形上下文
        CGContextDrawPath(context, kCGPathStroke);//最后一个参数少填充类型
        
        //6.释放对象
        CGPathRelease(path);
        CGPathRelease(path2);
        
        //6.2画分割线
        CGMutablePathRef path3 = CGPathCreateMutable();
        CGPathMoveToPoint(path3, nil, 0, 1);
        CGPathAddLineToPoint(path3, nil,self.frame.size.width,1);
        
        CGContextAddPath(context, path3);
        
        CGContextSetLineWidth(context, 1.0f);
        CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.3);    //设置笔触颜色
        CGContextDrawPath(context, kCGPathStroke);
        CGPathRelease(path3);
        
        //7.加载其他view
        [self setLayout];
        }
}

#pragma mark 页面布局
- (void)setLayout {
    //添加label°
    //删除旧的subview，防止页面刷新后新旧冲突
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    for (int i = 0; i<7; i++) {
        NSNumber *y = _highPoint[i];
        NFWeatherModel *weather = _weathers[i];
        //温度label
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake((50+self.frame.size.width-100)/6*i-30, y.intValue-20, 60, 15)];
        label.textColor = [UIColor whiteColor];
        int h = (int)weather.hightemp;
        label.text = [NSString stringWithFormat:@"%d°",h];
        //            if (i == 0) {
        //                label.textAlignment = NSTextAlignmentRight;
        //            }else if (i == 6) {
        //                label.textAlignment = NSTextAlignmentLeft;
        //            }else {
        //                label.textAlignment = NSTextAlignmentCenter;
        //            }
        
        [self addSubview:label];
        //        label.center = CGPointMake((30+self.frame.size.width-60)/6*i, y.intValue-20);
        //        label.textAlignment = NSTextAlignmentCenter;
        
        //天气label
        UILabel *typeLabel = [[UILabel alloc]initWithFrame:CGRectMake((50+self.frame.size.width-100)/6*i, 60, 60, 15)];
        typeLabel.textColor = [UIColor whiteColor];
        typeLabel.text = weather.type;
        
        typeLabel.textAlignment = NSTextAlignmentCenter;
        //            if (i == 0) {
        //                typeLabel.textAlignment = NSTextAlignmentRight;
        //            }else if (i == 6) {
        //                typeLabel.textAlignment = NSTextAlignmentLeft;
        //            }else {
        //                typeLabel.textAlignment = NSTextAlignmentCenter;
        //            }
        [self addSubview:typeLabel];
        
        //日期label
        self.dates = [self getDate];
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectMake((50+self.frame.size.width-100)/6*i, 40, 60, 15)];
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.text = _dates[i];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        //            if (i == 0) {
        //                dateLabel.textAlignment = NSTextAlignmentRight;
        //            }else if (i == 6) {
        //                dateLabel.textAlignment = NSTextAlignmentLeft;
        //            }else {
        //                dateLabel.textAlignment = NSTextAlignmentCenter;
        //            }
        [self addSubview:dateLabel];
        
        
        NSNumber *lowpoint = _lowPoint[i];
        UILabel *lowTempLabel = [[UILabel alloc]initWithFrame:CGRectMake((50+self.frame.size.width-100)/6*i, lowpoint.intValue-20, 40, 15)];
        lowTempLabel.textColor = [UIColor whiteColor];
        NSNumber *t1 = self.lowtemp[i];
        lowTempLabel.text = [NSString stringWithFormat:@"%d°",[t1 intValue]];
        if (i == 0) {
            lowTempLabel.textAlignment = NSTextAlignmentRight;
        }else if (i == 6) {
            lowTempLabel.textAlignment = NSTextAlignmentLeft;
        }else {
            lowTempLabel.textAlignment = NSTextAlignmentCenter;
        }
        //        label.center = CGPointMake((30+self.frame.size.width-60)/6*i, y.intValue-20);
        //        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lowTempLabel];
    }

}

#pragma mark 获取日期
- (NSArray *)getDate {
    NSMutableArray *array = [NSMutableArray array];
    //直接获取日期
    int dayTime = 60*60*24;
    for (int i=-2; i<5; i++) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:dayTime*i];
        int day = [date getDay];
        int month = [date getMonth];
        NSString *dateStr = [NSString stringWithFormat:@"%d/%d",month,day];
        [array addObject:dateStr];
    }
    return array;
    
    
    /*
    //从天气数据中提取日期
    
    NSMutableArray *dates = [NSMutableArray array];
    
    //获取月份
    NFWeatherModel *weather0 = _weathers[0];
    NSRange r1 = NSMakeRange(5, 2);
    NSString *month =[weather0.date substringWithRange:r1];
    NSInteger mon = [month integerValue];
    
    for (int i=0; i<7; i++) {
        //获取天气对象
        NFWeatherModel *weather = _weathers[i];
        NSString *date = weather.date;
        NSLog(@"date.length = '%lu'",(unsigned long)date.length);
        
        
        //进行格式判断，应该用正则，因为每天凌晨数据格式不同，防止crash
        if (date.length < 8) {
            NSString *dayStr = [date substringWithRange:NSMakeRange(0, 2)];
            
            NSDate *date = [NSDate date];
            //对比是不是下个月一号
            if ([dayStr integerValue] ?? [date WFDateNumberOfDaysInCurrentMonth]) {
                
            }
        }
        NSLog(@"weather.date = %@",weather.date);
        NSString *monthStr = [weather.date substringWithRange:r1];
        NSString *dayStr = [weather.date substringWithRange:NSMakeRange(8, 2)];
    }
     */
    
}


//获取最高温度的高度值，存放NSNumber, 共七天
- (NSArray *)getHighPoint{

    self.highTemp = [self getHighTempFromWeathers:_weathers];
    self.lowtemp = [self getLowTempFromWeathers:_weathers];
//    NSLog(@"highTemp = %@",self.highTemp);
//    NSLog(@"lowtemp = %@",self.lowtemp);
    
    int chazhi = 0; //最高温差
    
    int lowestTemp = 400;
    
    for (NSNumber *h in self.highTemp) {
        for (NSNumber *l in self.lowtemp) {
            int i = h.intValue - l.intValue;
            //获取最大温差
            if (i > chazhi) {
                chazhi = i;
            }
            //获取最低温度
            if (l.intValue < lowestTemp) {
                lowestTemp = l.intValue;
            }
        }
    }
    
//    NSLog(@"最大温差= %d",chazhi);
//    NSLog(@"最低温度＝ %d",lowestTemp);
    
    //取出单位温度差的高度
    int danwei = self.frame.size.height/2/chazhi;
//    NSLog(@"单位温差高度 = %d",danwei);
    
    NSMutableArray *result = [[NSMutableArray alloc]init];
    
    for (int i =0; i<7; i++) {
//        int x = 30 + 60*i;//每个点的x坐标
        NSNumber *h = self.highTemp[i];
        int y = self.frame.size.height - ((h.intValue - lowestTemp)*danwei);
//        CGPoint point = CGPointMake(x, y);
        [result addObject:[NSNumber numberWithInt:y]];
//        NSLog(@"h[%d] = %d",i,y);
    }
    return (NSArray *)result;
}

- (NSArray *)getLowPoint{
    
    
    self.highTemp = [self getHighTempFromWeathers:_weathers];
    self.lowtemp = [self getLowTempFromWeathers:_weathers];
    
    int chazhi = 0;
    int lowestTemp = 400;
    for (NSNumber *h in self.highTemp) {
        for (NSNumber *l in self.lowtemp) {
            int i = h.intValue - l.intValue;
            //获取最大温差
            if (i > chazhi) {
                chazhi = i;
            }
            //获取最低温度
            if (l.intValue < lowestTemp) {
                lowestTemp = l.intValue;
            }
        }
    }
    
    //取出单位温度差的高度
    int danwei = self.frame.size.height/2/chazhi;
    
//    NSLog(@"最大温差＝ %d",chazhi);
//    NSLog(@"最低温度＝ %d",lowestTemp);
//    NSLog(@"单位温差高度＝ %d",danwei);
    
    NSMutableArray *result = [[NSMutableArray alloc]init];
    
#warning 可以改成用块遍历
    for (int i =0; i<7; i++) {
        
        NSNumber *l = self.lowtemp[i];
        int y = self.frame.size.height - ((l.intValue - lowestTemp)*danwei + 20);
        //        CGPoint point = CGPointMake(x, y);
        [result addObject:[NSNumber numberWithInt:y]];
//        NSLog(@"l[%d] = %d",i,y);
    }
    return result;
}

- (NSMutableArray *)getHighTempFromWeathers:(NSArray *)weathersToCalc {
//    NSLog(@"执行 getHighTempFromWeathers:");
    NSMutableArray *array = [[NSMutableArray alloc]init];
//    [weathersToCalc enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NFWeatherModel *weather = obj;
//        int i =  (int)weather.hightemp;
//        NSLog(@"hightemp = %d",i);
//        [array addObject:[NSNumber numberWithInt:i]];
//    }];
    for (NFWeatherModel *weather in weathersToCalc) {
        int i = (int)weather.hightemp;
//        NSLog(@"hightemp = '%d'",i);
        [array addObject:[NSNumber numberWithInt:i]];
    }
    
    return array;
}

- (NSMutableArray *)getLowTempFromWeathers:(NSArray *)weathers {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [weathers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NFWeatherModel *weather = obj;
        int i =  (int)weather.lowtemp;
        [array addObject:[NSNumber numberWithInt:i]];
    }];
    return array;
}

#warning 伪数据，防止crash
- (void) initData {
    
    if (self.weathersToCalc == nil) {
        NFWeatherModel *weather;
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (int i = 0; i<7; i++) {
            weather = [[NFWeatherModel alloc]init];
            weather.hightemp = 30;
            weather.lowtemp = 20;
            [array addObject:weather];
        }

        self.weathers = array;
    }else {
        self.weathers = self.weathersToCalc;
    }
}

@end
