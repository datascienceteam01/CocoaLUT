//
//  LUT1DGraphView.h
//  Pods
//
//  Created by Greg Cotten on 5/1/14.
//
//
#import "CocoaLUT.h"

typedef NS_ENUM(NSInteger, LUT1DGraphViewInterpolation) {
    LUT1DGraphViewInterpolationLinear
};



@interface LUT1DGraphView : NSView

@property (strong, nonatomic) LUT1D *lut;
@property (assign, nonatomic) LUT1DGraphViewInterpolation interpolation;
@property (assign) NSPoint mousePoint;
@property (assign) BOOL mouseIsIn;
@property (strong) NSTrackingArea *currentTrackingArea;

-(void)lutDidChange;

- (NSArray *)indexLUTColorAndIdentityLUTColorFromCurrentMousePoint;

+(M13OrderedDictionary *)interpolationMethods;

@end


@interface LUT1DGraphViewController : NSViewController

@property (strong) NSAttributedString *colorizedColorStringAtMousePoint;
@property (strong) NSColor *inputColor;
@property (strong) NSColor *outputColor;

- (void)initialize;

- (void)setViewWithLUT:(LUT1D *)lut;

- (void)setInterpolation:(LUT1DGraphViewInterpolation)interpolation;

@end
