//
//  JRGraphView.m
//  JRPlot
//
//  Created by __无邪_ on 15/1/29.
//  Copyright (c) 2015年 __无邪_. All rights reserved.
//

#import "JRGraphView.h"

static int lengthOfY = 200;
static int lengthOfX = 10;

static int standardLengthOfY = 200;

@interface JRGraphView ()<CPTPlotDataSource,CPTPlotSpaceDelegate,CPTPlotAreaDelegate,CPTScatterPlotDelegate>
{
    CPTPlotSpaceAnnotation *symbolTextAnnotation;
    CPTScatterPlot *dataLinePlot;
}
@property (nonatomic, strong)CPTGraphHostingView *hostView;

@end


@implementation JRGraphView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hostView = [[CPTGraphHostingView alloc] initWithFrame:frame];
        self.hostView.backgroundColor = [UIColor whiteColor];
        self.plotDatasDictionary = [[NSMutableDictionary alloc] init];
        
        [self.hostView setUserInteractionEnabled:YES];
        [self addSubview:self.hostView];
        [self prepaireGraph];
    
    }
    return self;
}

- (void)prepaireGraph {

    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.frame xScaleType:CPTScaleTypeLinear
                                               yScaleType:CPTScaleTypeLinear];
    self.hostView.hostedGraph = graph;
    graph.plotAreaFrame.paddingTop    = CPTFloat(-5);
    graph.plotAreaFrame.paddingRight  = CPTFloat(-10);
    graph.plotAreaFrame.paddingBottom = CPTFloat(5);
    graph.plotAreaFrame.paddingLeft   = CPTFloat(8);
    graph.plotAreaFrame.masksToBorder  = NO;
    
    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;
    // plotSpace 控制图片的移动及缩放
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat(lengthOfX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat(lengthOfY)];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0)
                                                          length:CPTDecimalFromFloat(lengthOfY)];// 固定y轴坐标
    
    // 设置图表 线 的样式
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor redColor];
    lineStyle.lineWidth = 1.f;
    // 设置关键 点 的样式
    CPTPlotSymbol * plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    plotSymbol.size = CGSizeMake(5, 5);
    plotSymbol.lineStyle = [CPTMutableLineStyle lineStyle];
    
    // Data lines
    dataLinePlot = [[CPTScatterPlot alloc] init];
    dataLinePlot.identifier = kDataLine;
    dataLinePlot.dataSource = self; //设定图表数据源
    dataLinePlot.delegate   = self;
    dataLinePlot.dataLineStyle = lineStyle;
    dataLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    dataLinePlot.interpolation = CPTScatterPlotInterpolationCurved;
    dataLinePlot.plotSymbol = plotSymbol;
    dataLinePlot.plotSymbolMarginForHitDetection = 10.0f;
    [graph addPlot:dataLinePlot];
    
    CPTScatterPlot *dashDataLinePlot = [[CPTScatterPlot alloc] init];
    dashDataLinePlot.identifier = kDashDataLine;
    dashDataLinePlot.dataSource = self;
    lineStyle.dashPattern = @[@5, @5];
    lineStyle.lineColor = [CPTColor magentaColor];
    dashDataLinePlot.dataLineStyle = lineStyle;
    dashDataLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    dashDataLinePlot.interpolation = CPTScatterPlotInterpolationCurved;
    [graph addPlot:dashDataLinePlot];
    
    // Warning lines
    CPTScatterPlot *warningUpLinePlot = [[CPTScatterPlot alloc] init];
    warningUpLinePlot.identifier = kWarningUpLine;
    lineStyle.lineColor           = [CPTColor blueColor];
    warningUpLinePlot.dataLineStyle = lineStyle;
    warningUpLinePlot.dataSource = self;
    [graph addPlot:warningUpLinePlot];
    
    CPTScatterPlot *warningDownLinePlot = [[CPTScatterPlot alloc] init];
    warningDownLinePlot.identifier = kWarningLowerLine;
    warningDownLinePlot.dataLineStyle = lineStyle;
    warningDownLinePlot.dataSource = self;
    [graph addPlot:warningDownLinePlot];
    

    
    
    CPTMutableLineStyle *clearColorLineStyle = [CPTMutableLineStyle lineStyle];
    clearColorLineStyle.lineColor = [CPTColor clearColor];
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor clearColor];
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:CPTFloat(0.2)];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];
    
    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init]; // 显示到小数点后两位
    [formatter setMaximumFractionDigits:0];
    
    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet         = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x                  = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromInt(1);
    x.minorTicksPerInterval       = 1;
    x.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0);
    x.axisConstraints             = [CPTConstraints constraintWithRelativeOffset:0.0];
    x.labelFormatter              = formatter;
    
    // Label y with an automatic label policy.
    CPTXYAxis *y                  = axisSet.yAxis;
//    y.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    y.majorIntervalLength         = CPTDecimalFromInt(50);
    y.minorTicksPerInterval       = 1;
//    y.preferredNumberOfMajorTicks = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    
    y.labelFormatter              = formatter;
    y.labelOffset                 = -2;
    y.visibleAxisRange            = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(lengthOfY)];
    
    // Set axes
    graph.axisSet.axes = @[x, y];
    
    
    
    
    // Auto scale the plot space to fit the plot data
//    [plotSpace scaleToFitPlots:@[dataLinePlot]];
////    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
//    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
//    
//    // Expand the ranges to put some space around the plot
////    [xRange expandRangeByFactor:CPTDecimalFromDouble(1.2)];
//    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.2)];
////    plotSpace.xRange = xRange;
//    plotSpace.yRange = yRange;
//    
////    [xRange expandRangeByFactor:CPTDecimalFromDouble(1.025)];
////    xRange.location = plotSpace.xRange.location;
//    [yRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
////    x.visibleAxisRange = xRange;
//    y.visibleAxisRange = yRange;
//    
////    [xRange expandRangeByFactor:CPTDecimalFromDouble(3.0)];
//    [yRange expandRangeByFactor:CPTDecimalFromDouble(3.0)];
////    plotSpace.globalXRange = xRange;
//    plotSpace.globalYRange = yRange;
    
}



#////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - Refresh
////////////////////////////////////////////////////////////////////////////////
-(void)setUpwarningValue:(CGFloat)upwarningValue{
    
    
    NSNumber *startXAxisOffset = @(-2.f);
    NSNumber *endXAxisXoffset = @(100);
    [self.plotDatasDictionary setObject:@[@{ X_AXIS:startXAxisOffset, Y_AXIS:@(upwarningValue) },@{X_AXIS:endXAxisXoffset, Y_AXIS:@(upwarningValue)}] forKeyedSubscript:kWarningUpLine];
}
-(void)setLowerwarningValue:(CGFloat)lowerwarningValue{
    NSNumber *startXAxisOffset = @(-2.f);
    NSNumber *endXAxisXoffset = @(100);
    [self.plotDatasDictionary setObject:@[@{ X_AXIS:startXAxisOffset, Y_AXIS:@(lowerwarningValue) },@{X_AXIS:endXAxisXoffset, Y_AXIS:@(lowerwarningValue)}] forKeyedSubscript:kWarningLowerLine];
}
- (void)refresh {
    
    NSArray *dataArr = [self.plotDatasDictionary objectForKey:kDataLine];
    BOOL shouldRefresh = NO;
    
    for (NSDictionary *dic in dataArr) {
        NSNumber *y = dic[Y_AXIS];
        if (y.intValue > lengthOfY - 30) {
            lengthOfY = y.intValue + 30;
            shouldRefresh = YES;
        }
    }
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    CPTXYAxisSet *axisSet         = (CPTXYAxisSet *)self.hostView.hostedGraph.axisSet;
    
    if (shouldRefresh) {
        CPTXYAxis *y                  = axisSet.yAxis;
        
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                        length:CPTDecimalFromFloat(lengthOfY)];
        plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0)
                                                              length:CPTDecimalFromFloat(lengthOfY)];// 固定y轴坐标
        y.visibleAxisRange            = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                                     length:CPTDecimalFromFloat(lengthOfY)];
        
    }
    if (dataArr.count > (lengthOfX - 3)) {
        NSUInteger location = dataArr.count - 7;
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(location) length:CPTDecimalFromFloat(lengthOfX)];
    }
    
    
    [dataLinePlot reloadData];

}


#////////////////////////////////////////////////////////////////////////////////
#pragma mark - CPTPlotDataSource
////////////////////////////////////////////////////////////////////////////////

/** @brief @required The number of data points for the plot.
 *  @param plot The plot.
 *  @return The number of data points for the plot.
 **/
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    
    NSUInteger numRecords = 0;
    NSString *identifier  = (NSString *)plot.identifier;
    NSArray *dataArr = [self.plotDatasDictionary objectForKey:identifier];
    numRecords = dataArr.count;
    return numRecords;
    
}
/** @brief @optional Gets a plot data value for the given plot and field.
 *  Implement one and only one of the optional methods in this section.
 *  @param plot The plot.
 *  @param fieldEnum The field index.
 *  @param idx The data index of interest.
 *  @return A data point.
 **/
-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx{
    
    NSNumber *num        = nil;
    NSString *identifier = (NSString *)plot.identifier;
    NSArray *dataArr = [self.plotDatasDictionary objectForKey:identifier];
    num = dataArr[idx][(fieldEnum == CPTScatterPlotFieldX ? X_AXIS : Y_AXIS)];
    
    return num;
}


#////////////////////////////////////////////////////////////////////////////////
#pragma mark - CPTScatterPlotDelegate
////////////////////////////////////////////////////////////////////////////////
/** @brief @optional Informs the delegate that a data point was
 *  @if MacOnly clicked. @endif
 *  @if iOSOnly touched. @endif
 *  @param plot The scatter plot.
 *  @param idx The index of the
 *  @if MacOnly clicked data point. @endif
 *  @if iOSOnly touched data point. @endif
 **/
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx{
//    NSString *plotKey = (NSString *)plot.identifier;
    CPTXYGraph *graph = (CPTXYGraph *)self.hostView.hostedGraph;
    
    CPTPlotSpaceAnnotation *annotation = symbolTextAnnotation;
    
    if ( annotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        annotation = nil;
    }
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor blackColor];
    hitAnnotationTextStyle.fontSize = 16.0;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    
    NSString *identifier = (NSString *)plot.identifier;
    NSArray *dataArr = [self.plotDatasDictionary objectForKey:identifier];
    
    NSDictionary *dataPoint = dataArr[idx];
    
    NSNumber *x = dataPoint[X_AXIS];
    NSNumber *y = dataPoint[Y_AXIS];
    
    NSArray *anchorPoint = @[x, y];
    
    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:y];
    
    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
    annotation                = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    annotation.contentLayer   = textLayer;
    annotation.displacement   = CGPointMake(0.0, 20.0);
    symbolTextAnnotation = annotation;
    [graph.plotAreaFrame.plotArea addAnnotation:annotation];
    
}



#////////////////////////////////////////////////////////////////////////////////
#pragma mark - Plot Space Delegate Methods
////////////////////////////////////////////////////////////////////////////////
/** @brief @optional Notifies that plot space is going to change a plot range.
 *  @param space The plot space.
 *  @param newRange The proposed new plot range.
 *  @param coordinate The coordinate of the range.
 *  @return The new plot range to be used.
 **/
-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    CPTMutablePlotRange *changedRange = [newRange mutableCopy];

    switch ( coordinate ) {
        case CPTCoordinateX:
            if (changedRange.locationDouble < -1) {
                changedRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-0.9) length:CPTDecimalFromFloat(newRange.lengthDouble)];
            }
            if (changedRange.lengthDouble > 10) {
                changedRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(newRange.locationDouble) length:CPTDecimalFromFloat(lengthOfX)];
            }
            break;
            
        case CPTCoordinateY:
            if (lengthOfY != standardLengthOfY && lengthOfY > standardLengthOfY) {
                changedRange.length = CPTDecimalFromLongLong(lengthOfY);
                
            }
            break;
            
        default:
            break;
    }
    
    return changedRange;
}


#////////////////////////////////////////////////////////////////////////////////
#pragma mark - CPTPlotAreaDelegate
////////////////////////////////////////////////////////////////////////////////

/** @brief @optional Informs the delegate that a plot area was
 *  @if MacOnly clicked. @endif
 *  @if iOSOnly touched. @endif
 *  @param plotArea The plot area.
 **/
-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea{
    if (symbolTextAnnotation) { // Remove the annotation
        [self.hostView.hostedGraph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
        symbolTextAnnotation = nil;
    }
}
@end
