//
//  CTImageData.h
//  CoreTextDemo
//
//  Created by Gray.Luo on 15/11/29.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CTImageData : NSObject
@property (nonatomic,strong) NSString *imgHolder;
@property (nonatomic,strong) NSURL *imgPath;
@property (nonatomic) NSInteger idx;
@property (nonatomic) CGRect imageRect;
@end
