//
//  CTRichView.h
//  NetWorkProcessDemo
//
//  Created by hyq on 15/11/27.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CTImageData.h"
#import "CTLinkData.h"

@interface CTRichView : UIView
@property (nonatomic,assign) CTFrameRef ctFrame;
@property (nonatomic,strong) NSMutableArray *imageDataArray;
@property (nonatomic,strong) NSMutableArray *linkDataArray;
@end
