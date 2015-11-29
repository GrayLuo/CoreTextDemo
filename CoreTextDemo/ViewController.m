//
//  ViewController.m
//  CoreTextDemo
//
//  Created by hyq on 15/11/27.
//  Copyright © 2015年 Grey. All rights reserved.
//

#import "ViewController.h"
#import "CTRichView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    CTRichView *richView = [[CTRichView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:richView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
