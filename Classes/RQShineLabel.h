//
//  RQShineLabel.h
//  RQShineLabel
//
//  Created by Genki on 5/7/14.
//  Copyright (c) 2014 Reteq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RQShineLabel: UILabel

/**
 *  Fade in text animation duration. Defaults to 2.5.
 */
@property (assign, nonatomic, readwrite) CFTimeInterval shineDuration;

/**
 *  Check if the animation is finished
 */
@property (assign, nonatomic, readonly, getter = isShining) BOOL shining;

@property (assign, nonatomic) BOOL needShine;

/**
 *  Start the animation
 */
- (void)shine;
- (void)shineWithCompletion:(void (^)())completion;

@end
