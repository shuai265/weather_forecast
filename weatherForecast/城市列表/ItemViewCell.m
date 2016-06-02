//
//  ItemViewCell.m
//  AddressInfo
//
//  Created by Alesary on 16/1/6.
//  Copyright © 2016年 Mr.Chen. All rights reserved.
//

#import "ItemViewCell.h"

@interface ItemViewCell ()

@end

@implementation ItemViewCell

- (void)awakeFromNib {

    self.CityName.layer.cornerRadius=5.5;
    self.CityName.layer.masksToBounds=YES;
}

@end
