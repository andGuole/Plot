//
//  ViewController.m
//  JRPlot
//
//  Created by __无邪_ on 15/1/29.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "ViewController.h"
#import "JRGraphView.h"

static int i = 1;
@interface ViewController (){
    UIButton *stopButton;
    NSTimer *fireTimer;
}

@property (nonatomic, strong)JRGraphView *graphView;
@property (nonatomic, strong)NSMutableArray *dataArr;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.dataArr = [[NSMutableArray alloc] init];
    
    
    self.graphView = [[JRGraphView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 200)];
    [self.view addSubview:self.graphView];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    

    NSMutableArray *contentArray2 = [NSMutableArray array];

    for ( NSUInteger i = 0; i < 20; i++ ) {
        NSNumber *x = @(i);
        NSNumber *y = @((arc4random() % 200) + 1);
        [contentArray2 addObject:@{ @"x": x, @"y": y }
         ];
    }
    
    [self.graphView.plotDatasDictionary setObject:contentArray2 forKey:kDashDataLine];
    [self.graphView setLowerwarningValue:35];
    [self.graphView setUpwarningValue:170];
    
    [self.graphView refresh];
    

    
    
    stopButton = [[UIButton alloc] initWithFrame:CGRectMake(50, self.view.frame.size.height - 100, 200, 50)];
    [stopButton setTitle:@"Stop" forState:UIControlStateSelected];
    [stopButton setTitle:@"Start" forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(fire) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopButton];
    
}


- (void)addAction{
    
    NSNumber *x = @(i);
    i = i + 1;
    NSNumber *y = @((arc4random() % 280) + 1);
    [self.dataArr addObject:@{ X_AXIS: x, Y_AXIS: y }];

    [self.graphView.plotDatasDictionary setObject:self.dataArr forKey:kDataLine];
    [self.graphView refresh];
}


- (void)fire{
    [stopButton setSelected:!stopButton.isSelected];
    if (stopButton.isSelected) {
        
        [fireTimer invalidate];
        fireTimer = nil;
        fireTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(addAction) userInfo:nil repeats:YES];
        
    }else{
        [fireTimer invalidate];
        fireTimer = nil;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
