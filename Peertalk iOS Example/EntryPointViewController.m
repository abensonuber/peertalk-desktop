#import "PTExampleProtocol.h"
#import "EntryPointViewController.h"

// UIScreen mainScreen frame: 0, 0, 1024, 768
#define kFirstDotFadeTime 0.5f
#define kFirstTextFadeTime 0.7f
#define kFirstTextSlideUpDistance 50

#define kExpandAnimationTime 1.0f

#define kExpandAnimationXOrigin 44
#define kExpandAnimationYOrigin 2
#define kExpandAnimationHeight 764
#define kExpandAnimationWidth 1078

#define kTimeInSecondsBetweenDotExpandsAndHeadphoneSlideIn 0.5f

#define kHeadphoneSlideAnimationTime 0.6f
#define kHeadphoneSlideAnimationDistance 60
#define kDotsSlideAnimationAlpha 0.2

#define kTimeBetweenHeadphoneSlideInAndHeadphoneSlideOut 2.0

#define kExpandSecondDotAnimationTime 1.5f
#define kFadeSecondDotAnimationTime .75f

#define kHandSlideAnimationDuration .75f
#define kHandSlideAnimationDistance 30

#define kTimeBetweenHandSlideInAndOut 2.0f

#define kSixthScreenLabelSlideAnimationDistance 30
#define kSixthScreenLabelSlideAnimationDuration .6f

@interface EntryPointViewController () {

}

@property (nonatomic) bool animationSequenceInProcess;
@property (nonatomic) bool animationCompleted;
@property (strong, nonatomic) UIImage *serializedImageView;

@end

@implementation EntryPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tapToGetStartedLabel setFont:[UIFont fontWithName:@"ClanProForUBER-Medium" size:12.0]];
    [self.driverExperienceLabel setFont:[UIFont fontWithName:@"ClanProForUBER-Thin" size:45.0]];

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startAnimationSequence)]];
    [self.firstDotImageView setAlpha:1.0f];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"Please put on the headphones"];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"ClanProForUBER-Book" size:20.0]
                      range:NSMakeRange(0, 18)];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"ClanProForUBER-Medium" size:20.0]
                      range:NSMakeRange(18, 10)];
    [self.headphonesLabel setAttributedText:attString];
    
    NSMutableAttributedString *holdAndDragAttributedString = [[NSMutableAttributedString alloc] initWithString:@"Hold and drag to\nrotate the video"];
        [holdAndDragAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ClanProForUBER-Medium" size:19.6f] range:NSMakeRange(0, 4)];
    [holdAndDragAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ClanProForUBER-Book" size:19.6f] range:NSMakeRange(4, 5)];
    [holdAndDragAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ClanProForUBER-Medium" size:19.6f] range:NSMakeRange(9, 4)];
    [holdAndDragAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ClanProForUBER-Book" size:19.6f] range:NSMakeRange(13, 20)];
    [holdAndDragAttributedString addAttribute:NSKernAttributeName
                             value:@(1.6)
                             range:NSMakeRange(0, 33)];
    NSMutableParagraphStyle *holdAndDragParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    holdAndDragParagraphStyle.lineSpacing = 1.5;
    holdAndDragParagraphStyle.alignment = NSTextAlignmentCenter;
    [holdAndDragAttributedString addAttribute:NSParagraphStyleAttributeName value:holdAndDragParagraphStyle range:NSMakeRange(0, 33)];
    [self.holdAndDragLabel setAttributedText:holdAndDragAttributedString];
    
    [self.sixthScreenLabel setFont:[UIFont fontWithName:@"ClanProForUBER-Thin" size:45.0]];
    
    [self.signupInUnderLabel setFont:[UIFont fontWithName:@"ClanProForUBER-Book" size:16.0]];
    [self.signupArrowLabel setFont:[UIFont fontWithName:@"ClanProForUBER-Medium" size:16.0]];
}

-(void)startAnimationSequence {
    if (self.animationSequenceInProcess) {
        return;
    }
    self.animationSequenceInProcess = true;
    [self fadeDotAndFadeOutDriverLabel];
}

- (void)fadeDotAndFadeOutDriverLabel {
    // Fade the dot.
    [UIView animateWithDuration:kFirstDotFadeTime animations:^{
        [self.firstDotImageView setAlpha:0.0f];
    } completion:nil];
    
    // Trigger the driver and tap to get start animations.
    CGRect driverFrame = self.driverExperienceLabel.frame;
    CGRect getStartedFrame = self.tapToGetStartedLabel.frame;
    
    [UIView animateWithDuration:kFirstTextFadeTime animations:^{
        [self.driverExperienceLabel setAlpha:0.0f];
        [self.tapToGetStartedLabel setAlpha:0.0f];
        [self.driverExperienceLabel setFrame:CGRectMake(driverFrame.origin.x, driverFrame.origin.y - kFirstTextSlideUpDistance, driverFrame.size.width, driverFrame.size.height)];
        [self.tapToGetStartedLabel setFrame:CGRectMake(getStartedFrame.origin.x, getStartedFrame.origin.y - kFirstTextSlideUpDistance, getStartedFrame.size.width, getStartedFrame.size.height)];
    } completion:^(BOOL finished){
        if (finished) {
            [self performBackgroundSlideAnimation];
        }
    }];
}

- (void)performBackgroundSlideAnimation {
    CGRect firstBackFrame = self.firstBackgroundImageView.frame;
    CGRect secondBackFrame = self.secondBackgroundImageView.frame;
    [UIView animateWithDuration:kExpandAnimationTime animations:^{
        [self.firstBackgroundImageView setFrame:CGRectMake(firstBackFrame.origin.x + firstBackFrame.size.width, firstBackFrame.origin.y, firstBackFrame.size.width, firstBackFrame.size.height)];
        [self.secondBackgroundImageView setFrame:CGRectMake(secondBackFrame.origin.x + secondBackFrame.size.width, secondBackFrame.origin.y, secondBackFrame.size.width, secondBackFrame.size.height)];
        [self.gridImageView setFrame:CGRectMake(kExpandAnimationXOrigin, kExpandAnimationYOrigin, kExpandAnimationWidth, kExpandAnimationHeight)];
        [self.gridImageView setImage:[UIImage imageNamed:@"1st Grid Dark Dots"]];
    } completion:^(BOOL finished){
        if (finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTimeInSecondsBetweenDotExpandsAndHeadphoneSlideIn * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self performHeadphoneSlideInAnimation];
            });
            NSLog(@"Finished scaling!");
        }
    }];
}

- (void)performHeadphoneSlideInAnimation {
    CGRect finalHeadphoneImageFrame = self.headphonesImageView.frame;
    [self.headphonesImageView setFrame:CGRectMake(finalHeadphoneImageFrame.origin.x, finalHeadphoneImageFrame.origin.y - kHeadphoneSlideAnimationDistance, finalHeadphoneImageFrame.size.width, finalHeadphoneImageFrame.size.height)];
    
    CGRect finalHeadphoneLabelFrame = self.headphonesLabel.frame;
        [self.headphonesLabel setFrame:CGRectMake(finalHeadphoneLabelFrame.origin.x, finalHeadphoneLabelFrame.origin.y - kHeadphoneSlideAnimationDistance, finalHeadphoneLabelFrame.size.width, finalHeadphoneLabelFrame.size.height)];
    [UIView animateWithDuration:kHeadphoneSlideAnimationTime animations:^{
        [self.gridImageView setAlpha:kDotsSlideAnimationAlpha];
        
        [self.headphonesImageView setFrame:finalHeadphoneImageFrame];
        [self.headphonesImageView setAlpha:1.0f];
        
        [self.headphonesLabel setFrame:finalHeadphoneLabelFrame];
        [self.headphonesLabel setAlpha:1.0f];
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Finished Headphone slide in");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTimeBetweenHeadphoneSlideInAndHeadphoneSlideOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self performHeadphoneSlideOutAnimation];
            });
        }
    }];
}

- (void)performHeadphoneSlideOutAnimation {
    CGRect headphoneImageFrame = self.headphonesImageView.frame;
    CGRect headphoneLabelFrame = self.headphonesLabel.frame;
    [UIView animateWithDuration:kHeadphoneSlideAnimationTime animations:^{

        [self.headphonesImageView setFrame:CGRectMake(headphoneImageFrame.origin.x, headphoneImageFrame.origin.y - kHeadphoneSlideAnimationDistance, headphoneImageFrame.size.width, headphoneImageFrame.size.height)];
        [self.headphonesImageView setAlpha:0.0f];
        
        [self.headphonesLabel setFrame:CGRectMake(headphoneLabelFrame.origin.x, headphoneLabelFrame.origin.y - kHeadphoneSlideAnimationDistance, headphoneLabelFrame.size.width, headphoneLabelFrame.size.height)];
        [self.headphonesLabel setAlpha:0.0f];
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Finished Headphone slide out");
        }
    }];
    [self performLowerRightGridFadeInAnimation];
}

- (void)performLowerRightGridFadeInAnimation {
    CGRect secondDotFrame = self.secondDotImageView.frame;
    [self.secondDotImageView setFrame:CGRectMake(secondDotFrame.origin.x + secondDotFrame.size.width / 2, secondDotFrame.origin.y + secondDotFrame.size.height / 2, 1, 1)];
    [UIView animateWithDuration:kExpandSecondDotAnimationTime animations:^{
        [self.fourthGridControllerImageView setAlpha:1.0f];
        [self.secondDotImageView setAlpha:1.0f];
        [self.secondDotImageView setFrame:secondDotFrame];
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Finished Headphone slide out");
            [self performSecondDotFadeOut];
        }
    }];
}

- (void)performSecondDotFadeOut {
    // Also Switch the grid to fade to the middle 9 dots faded out.
    
    [UIView animateWithDuration:kFadeSecondDotAnimationTime animations:^{
        [self.secondDotImageView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Second Dot Animation Finished.");
            [self fadeInHand];
        }
    }];
}

- (void)fadeInHand {
    CGRect finalHandFrame = self.fifthHandImageView.frame;
    [self.fifthHandImageView setFrame:CGRectMake(finalHandFrame.origin.x, finalHandFrame.origin.y - kHandSlideAnimationDistance, finalHandFrame.size.width, finalHandFrame.size.height)];
    
    CGRect finalHoldAndDragLabelFrame = self.holdAndDragLabel.frame;
    [self.holdAndDragLabel setFrame:CGRectMake(finalHoldAndDragLabelFrame.origin.x, finalHoldAndDragLabelFrame.origin.y - kHandSlideAnimationDistance, finalHoldAndDragLabelFrame.size.width, finalHoldAndDragLabelFrame.size.height)];
    [UIView animateWithDuration:kHandSlideAnimationDuration animations:^{
        [self.fifthHandImageView setAlpha:1.0f];
        [self.fifthHandImageView setFrame:finalHandFrame];
        
        [self.holdAndDragLabel setAlpha:1.0f];
        [self.holdAndDragLabel setFrame:finalHoldAndDragLabelFrame];
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Hand slide in Animation finished");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTimeBetweenHandSlideInAndOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self fadeOutHand];
            });
        }
    }];
}

- (void)fadeOutHand {
    CGRect finalHandFrame = self.fifthHandImageView.frame;
    CGRect finalHoldAndDragLabelFrame = self.holdAndDragLabel.frame;
    [UIView animateWithDuration:kHandSlideAnimationDuration animations:^{
        [self.fifthHandImageView setAlpha:0.0f];
        [self.fifthHandImageView setFrame:CGRectMake(finalHandFrame.origin.x, finalHandFrame.origin.y - kHandSlideAnimationDistance, finalHandFrame.size.width, finalHandFrame.size.height)];
        
        [self.holdAndDragLabel setAlpha:0.0f];
        [self.holdAndDragLabel setFrame:CGRectMake(finalHoldAndDragLabelFrame.origin.x, finalHoldAndDragLabelFrame.origin.y - kHandSlideAnimationDistance, finalHoldAndDragLabelFrame.size.width, finalHoldAndDragLabelFrame.size.height)];
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Hand fade out Animation Finished.");
            [self fadeInFinalBackground];
        }
    }];
}

- (void)fadeInFinalBackground {
    CGRect firstBackFrame = self.firstBackgroundImageView.frame;
    [self.firstBackgroundImageView setFrame:CGRectMake(-firstBackFrame.size.width, firstBackFrame.origin.y, firstBackFrame.size.width, firstBackFrame.size.height)];
    CGRect secondBackFrame = self.secondBackgroundImageView.frame;
    [UIView animateWithDuration:kExpandAnimationTime animations:^{
        [self.firstBackgroundImageView setFrame:CGRectMake(0, firstBackFrame.origin.y, firstBackFrame.size.width, firstBackFrame.size.height)];
        [self.secondBackgroundImageView setFrame:CGRectMake(secondBackFrame.origin.x + secondBackFrame.size.width, secondBackFrame.origin.y, secondBackFrame.size.width, secondBackFrame.size.height)];
        [self.sixthScreenGrid setAlpha:1.0f];
        [self.fourthGridControllerImageView setAlpha:0.0f];
    } completion:^(BOOL finished){
        if (finished) {
            NSLog(@"Final Background Faded in");
            [self fadeInSixthScreenWords];
        }
    }];
}

- (void)fadeInSixthScreenWords {
    CGRect sixthScreenLabelFinalFrame = self.sixthScreenLabel.frame;
    [self.sixthScreenLabel setFrame:CGRectMake(sixthScreenLabelFinalFrame.origin.x, sixthScreenLabelFinalFrame.origin.y - kSixthScreenLabelSlideAnimationDistance, sixthScreenLabelFinalFrame.size.width, sixthScreenLabelFinalFrame.size.height)];
    
    CGRect signupImageViewFinalFrame = self.signupBackgroundImageView.frame;
    [self.signupBackgroundImageView setFrame:CGRectMake(signupImageViewFinalFrame.origin.x, signupImageViewFinalFrame.origin.y - kSixthScreenLabelSlideAnimationDistance, signupImageViewFinalFrame.size.width, signupImageViewFinalFrame.size.height)];
    
    CGRect signupArrowLabelFinalFrame = self.signupArrowLabel.frame;
    [self.signupArrowLabel setFrame:CGRectMake(signupArrowLabelFinalFrame.origin.x, signupArrowLabelFinalFrame.origin.y - kSixthScreenLabelSlideAnimationDistance, signupArrowLabelFinalFrame.size.width, signupArrowLabelFinalFrame.size.height)];
    
    CGRect signupInUnderFinalFrame = self.signupInUnderLabel.frame;
    [self.signupInUnderLabel setFrame:CGRectMake(signupInUnderFinalFrame.origin.x, signupInUnderFinalFrame.origin.y - kSixthScreenLabelSlideAnimationDistance, signupInUnderFinalFrame.size.width, signupInUnderFinalFrame.size.height)];
    
    [UIView animateWithDuration:kSixthScreenLabelSlideAnimationDuration animations:^{
        [self.sixthScreenLabel setAlpha:1.0f];
        [self.sixthScreenLabel setFrame:sixthScreenLabelFinalFrame];
        
        [self.signupBackgroundImageView setAlpha:1.0f];
        [self.signupBackgroundImageView setFrame:signupImageViewFinalFrame];
        
        [self.signupArrowLabel setAlpha:1.0f];
        [self.signupArrowLabel setFrame:signupArrowLabelFinalFrame];
        
        [self.signupInUnderLabel setAlpha:1.0f];
        [self.signupInUnderLabel setFrame:signupInUnderFinalFrame];
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Sixth Screen Label Slide Finished");
            [self showSixthScreenDot];
        }
    }];
}

- (void)showSixthScreenDot {
    [self.secondDotImageView setImage:[UIImage imageNamed:@"1st screen - lit dot"]];
    CGRect secondDotFrame = self.secondDotImageView.frame;
    [self.secondDotImageView setFrame:CGRectMake(secondDotFrame.origin.x + secondDotFrame.size.width / 2, secondDotFrame.origin.y + secondDotFrame.size.height / 2, 1, 1)];
    [UIView animateWithDuration:kExpandSecondDotAnimationTime animations:^{
        [self.secondDotImageView setAlpha:1.0f];
        [self.secondDotImageView setFrame:secondDotFrame];
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"Finished sixth screen dot animation");
        }
    }];
}

/*
- (void)switchUIImageView {
    UIImage * toImage = [UIImage imageNamed:@"myname.png"];
    [UIView transitionWithView:self.imageView
                      duration:5.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageView.image = toImage;
                    } completion:nil];
} */

-(BOOL)prefersStatusBarHidden{
    return YES;
}

/*
 ClanProForUBER-MediumNarrow
 ClanProForUBER-BookNarrow
 ClanProForUBER-News
 ClanProForUBER-ThinNarrow
 ClanProForUBER-NewsNarrow
 ClanProForUBER-Book
 ClanProForUBER-Medium
 ClanProForUBER-Thin
 */

/*for (NSString* family in [UIFont familyNames])
 {
 NSLog(@"%@", family);
 
 for (NSString* name in [UIFont fontNamesForFamilyName: family])
 {
 NSLog(@"  %@", name);
 }
 } */

@end

