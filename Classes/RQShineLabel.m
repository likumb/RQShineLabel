//
//  RQShineLabel.m
//  RQShineLabel
//
//  Created by Genki on 5/7/14.
//  Copyright (c) 2014 Reteq. All rights reserved.
//

#import "RQShineLabel.h"

@interface RQShineLabel()

@property (strong, nonatomic) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) NSMutableArray *characterAnimationDurations;
@property (nonatomic, strong) NSMutableArray *characterAnimationDelays;
@property (strong, nonatomic) CADisplayLink *displaylink;
@property (assign, nonatomic) CFTimeInterval beginTime;
@property (assign, nonatomic) CFTimeInterval endTime;
@property (nonatomic, copy) void (^completion)();

@end

@implementation RQShineLabel

- (instancetype)init
{
  self = [super init];
  if (!self) {
    return nil;
  }
  
  [self commonInit];
  
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (!self) {
    return nil;
  }
  
  [self commonInit];
  
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (!self) {
    return nil;
  }
  
  [self commonInit];
  
  [self setText:self.text];
  
  return self;
}

- (void)commonInit
{
  // Defaults
  _needShine = YES;
  _shineDuration   = 2.5;
  self.textColor  = [UIColor whiteColor];
  
  _characterAnimationDurations = [NSMutableArray array];
  _characterAnimationDelays    = [NSMutableArray array];
  
  _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAttributedString)];
  _displaylink.paused = YES;
  [_displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setText:(NSString *)text
{
  self.attributedText = [[NSAttributedString alloc] initWithString:text];
}

- (void)setNeedShine:(BOOL)needShine
{
  _needShine = needShine;
  self.attributedString = [self.attributedString copy];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
  self.attributedString = [self initialAttributedStringFromAttributedString:attributedText];
	[super setAttributedText:self.attributedString];
	for (NSUInteger i = 0; i < attributedText.length; i++) {
		self.characterAnimationDelays[i] = @(arc4random_uniform(self.shineDuration / 2 * 100) / 100.0);
		CGFloat remain = self.shineDuration - [self.characterAnimationDelays[i] floatValue];
		self.characterAnimationDurations[i] = @(arc4random_uniform(remain * 100) / 100.0);
	}
}

- (void)shine
{
  [self shineWithCompletion:NULL];
}

- (void)shineWithCompletion:(void (^)())completion
{
  
  if (!self.isShining) {
    self.completion = completion;
    [self startAnimationWithDuration:self.shineDuration];
  }
}

- (BOOL)isShining
{
  return !self.displaylink.isPaused;
}

#pragma mark - Private methods

- (void)startAnimationWithDuration:(CFTimeInterval)duration
{
  self.beginTime = CACurrentMediaTime();
  self.endTime = self.beginTime + duration;
  self.displaylink.paused = NO;
}

- (void)updateAttributedString
{
  CFTimeInterval now = CACurrentMediaTime();
  for (NSUInteger i = 0; i < self.attributedString.length; i ++) {
    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self.attributedString.string characterAtIndex:i]]) {
        continue;
    }
    [self.attributedString enumerateAttribute:NSForegroundColorAttributeName
                                      inRange:NSMakeRange(i, 1)
                                      options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                   usingBlock:^(id value, NSRange range, BOOL *stop) {
                                     
                                     CGFloat currentAlpha = CGColorGetAlpha([(UIColor *)value CGColor]);
                                     BOOL shouldUpdateAlpha = currentAlpha < 1 || (now - self.beginTime) >= [self.characterAnimationDelays[i] floatValue];
                                     
                                     if (!shouldUpdateAlpha) {
                                       return;
                                     }
                                     
                                     CGFloat percentage = (now - self.beginTime - [self.characterAnimationDelays[i] floatValue]) / ( [self.characterAnimationDurations[i] floatValue]);
                                     UIColor *color = [self.textColor colorWithAlphaComponent:percentage];
                                     [self.attributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
                                   }];
  }
  [super setAttributedText:self.attributedString];
  if (now > self.endTime) {
    self.displaylink.paused = YES;
    if (self.completion) {
      self.completion();
    }
  }
}

- (NSMutableAttributedString *)initialAttributedStringFromAttributedString:(NSAttributedString *)attributedString
{
  NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
  CGFloat alpha = self.needShine ? 0 : 1;
  UIColor *color = [self.textColor colorWithAlphaComponent:alpha];
  [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, mutableAttributedString.length)];
  return mutableAttributedString;
}


@end
