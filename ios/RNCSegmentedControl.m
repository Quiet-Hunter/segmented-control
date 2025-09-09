/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNCSegmentedControl.h"

#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>

@implementation RNCSegmentedControl

- (instancetype)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    _selectedIndex = self.selectedSegmentIndex;
    [self addTarget:self
                  action:@selector(didChange)
        forControlEvents:UIControlEventValueChanged];
  }
  return self;
}

- (void)setValues:(NSArray *)values {
	[self removeAllSegments];
	for (id segment in values) {
		if ([segment isKindOfClass:[NSMutableDictionary class]]){
			UIImage *image = [[RCTConvert UIImage:segment] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
			[self insertSegmentWithImage:image
								 atIndex:self.numberOfSegments
								animated:NO];
		} else {
			[self insertSegmentWithTitle:(NSString *)segment
								 atIndex:self.numberOfSegments
								animated:NO];
		}
	}
	super.selectedSegmentIndex = _selectedIndex;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
  _selectedIndex = selectedIndex;
  super.selectedSegmentIndex = selectedIndex;
}

/**
 * Helper: create a 1x1 resizable image from a UIColor.
 */
+ (UIImage *)rnc_imageWithColor:(UIColor *)color
{
  CGRect rect = CGRectMake(0, 0, 1, 1);
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
  [(color ?: UIColor.clearColor) setFill];
  UIRectFill(rect);
  UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return [img resizableImageWithCapInsets:UIEdgeInsetsZero];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && defined(__IPHONE_13_0) && \
    __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    // On iOS 13+, UISegmentedControl draws a system background image that
    // covers the view's backgroundColor. To actually tint the "track", we must
    // set background images per state (and optionally clear the divider).
    [super setBackgroundColor:UIColor.clearColor];

    UIImage *bg = [RNCSegmentedControl rnc_imageWithColor:(backgroundColor ?: UIColor.clearColor)];
    [self setBackgroundImage:bg forState:UIControlStateNormal   barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:bg forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];

    // Optional: clear the divider so no gray hairline shows through
    UIImage *clearImg = [RNCSegmentedControl rnc_imageWithColor:UIColor.clearColor];
    [self setDividerImage:clearImg
     forLeftSegmentState:UIControlStateNormal
     rightSegmentState:UIControlStateNormal
     barMetrics:UIBarMetricsDefault];
    return;
  }
#endif
  // < iOS 13 fallback
  [super setBackgroundColor:backgroundColor];
}

- (void)setTintColor:(UIColor *)tintColor {
  [super setTintColor:tintColor];
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && defined(__IPHONE_13_0) &&      \
    __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    // On iOS 13+, selected segment fill is controlled by selectedSegmentTintColor.
    [self setSelectedSegmentTintColor:tintColor];
  }
#endif
}

- (void)didChange {
  _selectedIndex = self.selectedSegmentIndex;
  if (_onChange) {
    NSString *segmentTitle = [self titleForSegmentAtIndex:_selectedIndex];
    _onChange(@{
      @"value" : (segmentTitle) ? segmentTitle : [self imageForSegmentAtIndex:_selectedIndex],
      @"selectedSegmentIndex" : @(_selectedIndex)
    });
  }
}

- (void)setAppearance:(NSString *)appearanceString {
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && defined(__IPHONE_13_0) &&      \
    __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
  if (@available(iOS 13.0, *)) {
    if ([appearanceString isEqual:@"dark"]) {
      [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleDark];
    } else if ([appearanceString isEqual:@"light"]) {
      [self setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    }
  }
#endif
}

- (NSArray *)accessibilityElements {
  NSArray *elements = [super accessibilityElements];
  [elements enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
    @try {
      obj.accessibilityIdentifier = self.testIDS[idx];
    } @catch (NSException *exception) {
      NSLog(@"%@", exception);
    }
  }];

  return elements;
}

@end
