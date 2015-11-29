//
//  CTLinkData.h
//  CoreTextDemo
//
//  Created by Gray.Luo on 15/11/29.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTLinkData : NSObject
@property (nonatomic ,strong) NSString *text;
@property (nonatomic ,strong) NSString *url;
@property (nonatomic ,assign) NSRange range;
@end
