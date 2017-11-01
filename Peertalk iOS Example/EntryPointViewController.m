#import "PTExampleProtocol.h"
#import "EntryPointViewController.h"

#define kFirstDotFadeTime 0.5f
#define kFirstTextFadeTime 0.7f
#define kFirstTextSlideUpDistance 50

#define kExpandAnimationTime 1.0f

#define kExpandAnimationXOrigin 32
#define kExpandAnimationYOrigin 2
#define kExpandAnimationHeight 764
#define kExpandAnimationWidth 1078
// 0, 0, 1024, 768

@interface EntryPointViewController () {

}

@property (nonatomic) bool animationSequenceInProcess;

@end

@implementation EntryPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tapToGetStartedLabel setFont:[UIFont fontWithName:@"ClanProForUBER-Medium" size:12.0]];
    [self.driverExperienceLabel setFont:[UIFont fontWithName:@"ClanProForUBER-Thin" size:45.0]];

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startAnimationSequence)]];
    [self.firstDotImageView setAlpha:1.0f];
}

-(void)startAnimationSequence {
    if (self.animationSequenceInProcess) {
        return;
    }
    self.animationSequenceInProcess = true;
    
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
    //[self.secondGridImageView setHidden:NO];
    //[self.secondGridImageView setAlpha:0];
    [self.secondGridImageView setAlpha:1.0f];
    [self.secondDotImageView setAlpha:1.0f];
    CGRect finalRect = CGRectMake(kExpandAnimationXOrigin, kExpandAnimationYOrigin, kExpandAnimationWidth, kExpandAnimationHeight);
    [UIView animateWithDuration:kExpandAnimationTime animations:^{
        //[self.gridImageView setAlpha:0.0f];
        [self.gridImageView setFrame:finalRect];
        //[self.secondGridImageView setFrame:[UIScreen mainScreen].bounds];
        //[self.secondGridImageView setFrame:finalRect];
    } completion:^(BOOL finished){
        if (finished) {
            NSLog(@"Finished scaling!");
            //self.gridImageView.frame;
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

