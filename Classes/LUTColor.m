//
//  LUTColor.m
//  DropLUT
//
//  Created by Wil Gieseler on 12/15/13.
//  Copyright (c) 2013 Wil Gieseler. All rights reserved.
//

#import "LUTColor.h"
#import "LUTHelper.h"

@implementation LUTColor

+ (LUTColor *)colorWithRed:(LUTColorValue)r green:(LUTColorValue)g blue:(LUTColorValue)b {
    LUTColor *color = [[LUTColor alloc] init];
    color.red = r;
    color.green = g;
    color.blue = b;
    return color;
}

+ (LUTColor *)colorFromIntegersWithBitDepth:(NSUInteger)bitdepth red:(NSUInteger)r green:(NSUInteger)g blue:(NSUInteger)b {
    NSUInteger maxBits = pow(2, bitdepth) - 1;
    return [LUTColor colorWithRed:nsremapint01(r, maxBits) green:nsremapint01(g, maxBits) blue:nsremapint01(b, maxBits)];
}

- (LUTColor *)clampedO1 {
    return [LUTColor colorWithRed:clamp01(self.red) green:clamp01(self.green) blue:clamp01(self.blue)];
}

- (LUTColor *)lerpTo:(LUTColor *)otherColor amount:(double)amount {
    return [LUTColor colorWithRed:lerp1d(self.red, otherColor.red, amount)
                            green:lerp1d(self.green, otherColor.green, amount)
                             blue:lerp1d(self.blue, otherColor.blue, amount)];
}

- (bool)equalsLUTColor:(LUTColor *)otherColor{
    return self.red == otherColor.red && self.green == otherColor.green && self.blue == otherColor.blue;
}

#if TARGET_OS_IPHONE
- (UIColor *)UIColor {
    return [UIColor colorWithRed:self.red green:self.green blue:self.blue alpha:1];
}
#elif TARGET_OS_MAC
- (NSColor *)NSColor {
    return [NSColor colorWithRed:self.red green:self.green blue:self.blue alpha:1];
}
#endif


@end
