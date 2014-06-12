//
//  LUTPreviewView.m
//  
//
//  Created by Wil Gieseler on 12/15/13.
//
//

#import "LUTPreviewView.h"
#import <QuartzCore/QuartzCore.h>

@interface LUTPreviewView () {
}
@property (strong) CALayer *normalImageLayer;
@property (strong) CALayer *lutImageLayer;
@property (strong) CALayer *avPlayerLayer;
@property (strong) CALayer *maskLayer;
@property (strong) NSView  *borderView;
@end

@implementation LUTPreviewView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)layout {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];

    _maskLayer.frame = CGRectMake(0, 0, self.bounds.size.width * self.maskAmount, self.bounds.size.height);
    self.normalImageLayer.frame = self.bounds;
    self.lutImageLayer.frame = self.bounds;
    
    _borderView.frame = CGRectMake(self.bounds.size.width * self.maskAmount, 0, 1, self.bounds.size.height);
    
    _avPlayerLayer.bounds = self.bounds;

    [CATransaction commit];

    [super layout];
}

- (void)setMaskAmount:(float)maskAmount {
    if (maskAmount > 1) {
        maskAmount = 1;
    }
    else if (maskAmount < 0) {
        maskAmount = 0;
    }
    _maskAmount = maskAmount;
    [self setNeedsLayout:YES];
}

- (void)setLut:(LUT *)lut {
    _lut = lut;
    dispatch_async(dispatch_get_current_queue(), ^{
        [self updateImageViews];
//        if (_lut) {
//            CIFilter *filter = _lut.coreImageFilterWithCurrentColorSpace;
//            if (filter) {
//                self.lutImageLayer.filters = @[filter];
//                return;
//            }
//        }
//        [self.lutImageLayer setFilters:@[]];
    });
}

- (void)updateImageViews {
    NSImage *lutImage = self.previewImage;
    if (self.lut) {
        lutImage = [self.lut processNSImage:self.previewImage renderPath:LUTImageRenderPathCoreImage];
    }
    self.lutImageLayer.contents = lutImage;
    self.normalImageLayer.contents = self.previewImage;
}

- (void)setPreviewImage:(NSImage *)previewImage {
    _previewImage = previewImage;
    dispatch_async(dispatch_get_current_queue(), ^{
//        NSLog(@"recommendedLayerContentsScale:0 %f", [previewImage recommendedLayerContentsScale:2]);
        [self updateImageViews];
        [self setupPlaybackLayers];
    });
}

- (void)setAvPlayer:(AVPlayer *)avPlayer {
    _avPlayer = avPlayer;
    [self setupPlaybackLayers];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)isOpaque {
    return YES;
}

-(void)mouseDown:(NSEvent *)event {
    [self maskToEvent:event];
}

-(void)mouseDragged:(NSEvent *)event {
//    [[NSCursor closedHandCursor] push];
    [self maskToEvent:event];
}

- (void)maskToEvent:(NSEvent *)event {
    NSPoint newDragLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    self.maskAmount = newDragLocation.x / self.bounds.size.width;
}

- (void)initialize {
    
    self.maskAmount = 0.5;
    
    self.wantsLayer = YES;
    self.layer.backgroundColor = NSColor.blackColor.CGColor;
    
    
    self.normalImageLayer = [[CALayer alloc] init];
    self.normalImageLayer.contentsGravity = kCAGravityResizeAspect;
    self.lutImageLayer = [[CALayer alloc] init];
    self.lutImageLayer.contentsGravity = kCAGravityResizeAspect;
    self.layerUsesCoreImageFilters = YES;
    
    [self.layer addSublayer:self.normalImageLayer];
    [self.layer addSublayer:self.lutImageLayer];
    
    _maskLayer = [CALayer layer];
    _maskLayer.backgroundColor = NSColor.whiteColor.CGColor;
    _maskLayer.frame = CGRectMake(0, 0, self.bounds.size.width * self.maskAmount, self.bounds.size.height);
    
    _borderView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    _borderView.wantsLayer = YES;
    _borderView.layer.backgroundColor = [NSColor colorWithWhite:1 alpha:0.5].CGColor;
    _borderView.frame = CGRectMake(self.bounds.size.width * self.maskAmount, 0, 1, self.bounds.size.height);
    [self addSubview:_borderView];

    [self setupPlaybackLayers];
}

- (BOOL)isVideo {
    return !!self.avPlayer;
}

- (void)setupPlaybackLayers {
    if (self.isVideo) {
        if (!_avPlayerLayer) {
            _avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
            _avPlayerLayer.bounds = self.bounds;
            _avPlayerLayer.backgroundColor = NSColor.redColor.CGColor;
        }
        [self.layer addSublayer:_avPlayerLayer];
    }
    else {
        [_avPlayerLayer removeFromSuperlayer];
        _avPlayerLayer = nil;
        self.lutImageLayer.mask = _maskLayer;
    }

}

@end
