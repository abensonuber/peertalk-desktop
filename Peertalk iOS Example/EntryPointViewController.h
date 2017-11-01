#import <UIKit/UIKit.h>
#import "PTChannel.h"

@interface EntryPointViewController : UIViewController <PTChannelDelegate>
@property (weak, nonatomic) IBOutlet UILabel *driverExperienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *tapToGetStartedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gridImageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstDotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondGridImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondDotImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headphonesImageView;
@property (weak, nonatomic) IBOutlet UILabel *headphonesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fourthGridControllerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fifthHandImageView;
@property (weak, nonatomic) IBOutlet UILabel *holdAndDragLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sixthScreenGrid;
@property (weak, nonatomic) IBOutlet UILabel *sixthScreenLabel;
@property (weak, nonatomic) IBOutlet UIImageView *signupBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *signupInUnderLabel;
@property (weak, nonatomic) IBOutlet UILabel *signupArrowLabel;

- (void)sendMessage:(NSString*)message;

@end
