#import <UIKit/UIKit.h>
#import "PTChannel.h"

@interface PTViewController : UIViewController <PTChannelDelegate, UITextFieldDelegate>

@property (weak) IBOutlet UITextView *outputTextView;
@property (weak) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *videoSegmentControl;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UISwitch *playPauseSwitch;

- (void)sendMessage:(NSString*)message;

@end
