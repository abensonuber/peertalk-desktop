#import "PTExampleProtocol.h"
#import "Constants.h"
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
    __weak PTChannel *serverChannel_;
    __weak PTChannel *peerChannel_;
}

@property (nonatomic) CGPoint curPoint;
@property (nonatomic) CGFloat circleRadius;
@property (nonatomic) CGPoint circleCenterPoint;

- (void)appendOutputMessage:(NSString*)message;
- (void)sendDeviceInfo;

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
    
    // PT Channel Code
    
    // Create a new channel that is listening on our IPv4 port
    PTChannel *channel = [PTChannel channelWithDelegate:self];
    [channel listenOnPort:PTExampleProtocolIPv4PortNumber IPv4Address:INADDR_LOOPBACK callback:^(NSError *error) {
        if (error) {
            [self appendOutputMessage:[NSString stringWithFormat:@"Failed to listen on 127.0.0.1:%d: %@", PTExampleProtocolIPv4PortNumber, error]];
        } else {
            [self appendOutputMessage:[NSString stringWithFormat:@"Listening on 127.0.0.1:%d", PTExampleProtocolIPv4PortNumber]];
            serverChannel_ = channel;
        }
    }];
    
    _circleRadius = 300;
    _circleCenterPoint = CGPointMake(691, 598);

    // Draw the touch circle center.
    /*
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(_circleCenterPoint.x - _circleRadius, _circleCenterPoint.y - _circleRadius, _circleRadius * 2, _circleRadius * 2)] CGPath]];
    [circleLayer setStrokeColor:[[UIColor redColor] CGColor]];
    [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [[self.view layer] addSublayer:circleLayer]; */
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
            
            // Start the video from the beginning!
            [self sendJsonDictionaryWithType:[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                              @(0), kUsbParamIndex,
                                              nil]
                                        type:kUsbTypeVideoChange];
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
            self.animationCompleted = true;
        }
    }];
}

// PT Channel Code

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchesBegan");
    [self handleTouch:event start:true];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchesMoved");
    [self handleTouch:event start:false];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.animationCompleted) {
        return;
    }
    [self sendJsonDictionaryWithType:[NSMutableDictionary new] type:kUsbTypeVrTouchEnd];
    //NSLog(@"touchesEnded");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.animationCompleted) {
        return;
    }
    [self sendJsonDictionaryWithType:[NSMutableDictionary new] type:kUsbTypeVrTouchEnd];
}

- (void)handleTouch:(UIEvent *)event start:(bool)start {
    if (!self.animationCompleted) {
        return;
    }
    UITouch *touch = [[event allTouches] anyObject];
    if (!touch) {
        return; // No gaurantee of a touch existing.
    }
    _curPoint = [touch locationInView:touch.view];
    
    CGFloat percentOfWidth = [self getPercentageOfWidth:_curPoint.x];
    CGFloat percentOfHeight = [self getPercentageOfHeight:_curPoint.y];
    //NSLog([NSString stringWithFormat:@"%lf %lf", percentOfWidth, percentOfHeight]);
    if (percentOfWidth < -999 || percentOfHeight < -999) {
        return;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 @(percentOfWidth), kUsbParamXCoordinate,
                                 @(percentOfHeight), kUsbParamYCoordinate,
                                 nil];
    
    [self sendJsonDictionaryWithType:dict type:(start ? kUsbTypeVrTouchStart : kUsbTypeVrTouch)];
}

- (CGFloat)getPercentageOfWidth:(CGFloat)xValue {
    if (xValue > (_circleCenterPoint.x + _circleRadius)) {
        return -1000;
    }
    if (xValue < (_circleCenterPoint.x - _circleRadius)) {
        return -1000;
    }
    return round(100 * (xValue - _circleCenterPoint.x) / _circleRadius);
}

- (CGFloat)getPercentageOfHeight:(CGFloat)yValue {
    if (yValue > (_circleCenterPoint.y + _circleRadius)) {
        return -1000;
    }
    if (yValue < (_circleCenterPoint.y - _circleRadius)) {
        return -1000;
    }
    return round(100 * (_circleCenterPoint.y - yValue) / _circleRadius);
}

- (void)sendJsonDictionaryWithType:(NSMutableDictionary *)dict type:(NSString *)type {
    [dict setValue:type forKey:@"type"];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    if (!jsonData || error) {
        return;
    }
    [self sendMessage:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
}

- (void)viewDidUnload {
    if (serverChannel_) {
        [serverChannel_ close];
    }
    [super viewDidUnload];
}


- (void)sendMessage:(NSString*)message {
    if (peerChannel_) {
        dispatch_data_t payload = PTExampleTextDispatchDataWithString(message);
        [peerChannel_ sendFrameOfType:PTExampleFrameTypeTextMessage tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
            if (error) {
                NSLog(@"Failed to send message: %@", error);
            }
        }];
        //[self appendOutputMessage:[NSString stringWithFormat:@"[you]: %@", message]];
    } else {
        [self appendOutputMessage:@"Can not send message — not connected"];
    }
}

- (void)appendOutputMessage:(NSString*)message {
    NSLog(@">> %@", message);
    //NSString *text = self.outputTextView.text;
    //if (text.length == 0) {
    //    self.outputTextView.text = [text stringByAppendingString:message];
    //} else {
    //    self.outputTextView.text = [text stringByAppendingFormat:@"\n%@", message];
    //    [self.outputTextView scrollRangeToVisible:NSMakeRange(self.outputTextView.text.length, 0)];
    //}
}

#pragma mark - Communicating

- (void)sendDeviceInfo {
    if (!peerChannel_) {
        return;
    }
    
    NSLog(@"Sending device info over %@", peerChannel_);
    
    UIScreen *screen = [UIScreen mainScreen];
    CGSize screenSize = screen.bounds.size;
    NSDictionary *screenSizeDict = (__bridge_transfer NSDictionary*)CGSizeCreateDictionaryRepresentation(screenSize);
    UIDevice *device = [UIDevice currentDevice];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                          device.localizedModel, @"localizedModel",
                          [NSNumber numberWithBool:device.multitaskingSupported], @"multitaskingSupported",
                          device.name, @"name",
                          (UIDeviceOrientationIsLandscape(device.orientation) ? @"landscape" : @"portrait"), @"orientation",
                          device.systemName, @"systemName",
                          device.systemVersion, @"systemVersion",
                          screenSizeDict, @"screenSize",
                          [NSNumber numberWithDouble:screen.scale], @"screenScale",
                          nil];
    dispatch_data_t payload = [info createReferencingDispatchData];
    [peerChannel_ sendFrameOfType:PTExampleFrameTypeDeviceInfo tag:PTFrameNoTag withPayload:payload callback:^(NSError *error) {
        if (error) {
            NSLog(@"Failed to send PTExampleFrameTypeDeviceInfo: %@", error);
        }
    }];
}


#pragma mark - PTChannelDelegate

// Invoked to accept an incoming frame on a channel. Reply NO ignore the
// incoming frame. If not implemented by the delegate, all frames are accepted.
- (BOOL)ioFrameChannel:(PTChannel*)channel shouldAcceptFrameOfType:(uint32_t)type tag:(uint32_t)tag payloadSize:(uint32_t)payloadSize {
    if (channel != peerChannel_) {
        // A previous channel that has been canceled but not yet ended. Ignore.
        return NO;
    } else if (type != PTExampleFrameTypeTextMessage && type != PTExampleFrameTypePing) {
        NSLog(@"Unexpected frame of type %u", type);
        [channel close];
        return NO;
    } else {
        return YES;
    }
}

// Invoked when a new frame has arrived on a channel.
- (void)ioFrameChannel:(PTChannel*)channel didReceiveFrameOfType:(uint32_t)type tag:(uint32_t)tag payload:(PTData*)payload {
    //NSLog(@"didReceiveFrameOfType: %u, %u, %@", type, tag, payload);
    if (type == PTExampleFrameTypeTextMessage) {
        PTExampleTextFrame *textFrame = (PTExampleTextFrame*)payload.data;
        textFrame->length = ntohl(textFrame->length);
        NSString *message = [[NSString alloc] initWithBytes:textFrame->utf8text length:textFrame->length encoding:NSUTF8StringEncoding];
        //[self appendOutputMessage:[NSString stringWithFormat:@"[%@]: %@", channel.userInfo, message]];
    } else if (type == PTExampleFrameTypePing && peerChannel_) {
        [peerChannel_ sendFrameOfType:PTExampleFrameTypePong tag:tag withPayload:nil callback:nil];
    }
}

// Invoked when the channel closed. If it closed because of an error, *error* is
// a non-nil NSError object.
- (void)ioFrameChannel:(PTChannel*)channel didEndWithError:(NSError*)error {
    if (error) {
        [self appendOutputMessage:[NSString stringWithFormat:@"%@ ended with error: %@", channel, error]];
    } else {
        [self appendOutputMessage:[NSString stringWithFormat:@"Disconnected from %@", channel.userInfo]];
    }
}

// For listening channels, this method is invoked when a new connection has been
// accepted.
- (void)ioFrameChannel:(PTChannel*)channel didAcceptConnection:(PTChannel*)otherChannel fromAddress:(PTAddress*)address {
    // Cancel any other connection. We are FIFO, so the last connection
    // established will cancel any previous connection and "take its place".
    if (peerChannel_) {
        [peerChannel_ cancel];
    }
    
    // Weak pointer to current connection. Connection objects live by themselves
    // (owned by its parent dispatch queue) until they are closed.
    peerChannel_ = otherChannel;
    peerChannel_.userInfo = address;
    [self appendOutputMessage:[NSString stringWithFormat:@"Connected to %@", address]];
    
    // Send some information about ourselves to the other end
    [self sendDeviceInfo];
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

