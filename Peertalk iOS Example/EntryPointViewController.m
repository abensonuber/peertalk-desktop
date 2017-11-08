#import "PTExampleProtocol.h"
#import "Constants.h"
#import "EntryPointViewController.h"

/*
// UIScreen mainScreen frame: 0, 0, 1024, 768
#define kFirstDotFadeTime 0.5f
#define kFirstTextFadeTime 0.7f
#define kFirstTextSlideUpDistance 50

#define kExpandAnimationTime 1.0f

#define kExpandAnimationXOrigin 44
#define kExpandAnimationYOrigin 2
#define kExpandAnimationHeight 764
#define kExpandAnimationWidth 1078

#define kTimeInSecondsBetweenDotExpandsAndHeadphoneSlideIn 0.1f

#define kHeadphoneSlideAnimationTime 0.6f
#define kHeadphoneSlideAnimationDistance 60
#define kDotsSlideAnimationAlpha 0.2

#define kTimeBetweenHeadphoneSlideInAndHeadphoneSlideOut 2.0

#define kExpandSecondDotAnimationTime 1.5f
#define kFadeSecondDotAnimationTime .75f

#define kTimeBetweenHandSlideInAndOut 2.0f

*/

#define kSixthScreenLabelSlideAnimationDistance 30
#define kSixthScreenLabelSlideAnimationDuration .6f

#define kHandSlideAnimationDuration .75f
#define kHandSlideAnimationDistance 30

#define kJoystickMaxVerticalDistanceFromCenter 80
#define kJoystickMaxHorizontalDistanceFromCenter 80

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
@property (nonatomic) bool movementAllowed;
@property (strong, nonatomic) UIImage *serializedImageView;

@property (nonatomic) CGRect initialMovementDotFrame;
@property (nonatomic) CGRect signupBackgroundImageViewInitialFrame;
@property (nonatomic) CGRect signupRightArrowImageViewInitialFrame;
@property (nonatomic) CGRect signupInUnderLabelInitialFrame;
@property (nonatomic) CGRect signupArrowLabelInitialFrame;
@property (nonatomic) CGRect secondDotImageViewInitialFrame;

@property (nonatomic) bool signupViewPresent;

@end

@implementation EntryPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.movementAllowed = true;
    NSMutableAttributedString *dragMeAttributedString = [[NSMutableAttributedString alloc] initWithString:@"DRAG ME"];
    [dragMeAttributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ClanProForUBER-Medium" size:30.0f] range:NSMakeRange(0, 7)];
    [dragMeAttributedString addAttribute:NSKernAttributeName
                             value:@(2.0)
                             range:NSMakeRange(0, 7)];
    NSMutableParagraphStyle *dragMeParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    dragMeParagraphStyle.lineSpacing = 1.5;
    dragMeParagraphStyle.alignment = NSTextAlignmentCenter;
    [dragMeAttributedString addAttribute:NSParagraphStyleAttributeName value:dragMeParagraphStyle range:NSMakeRange(0, 7)];
    [self.dragMeLabel setAttributedText:dragMeAttributedString];
    
    [self.signupInUnderLabel setFont:[UIFont fontWithName:@"ClanProForUBER-Book" size:22.4]];
    [self.signupArrowLabel setFont:[UIFont fontWithName:@"ClanProForUBER-Medium" size:22.4]];
    
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
    
    _circleRadius = 100;
    _circleCenterPoint = CGPointMake(512, 377);
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(signupBackgroundImageViewTapped)];
    [self.signupBackgroundImageView addGestureRecognizer:singleTap];
    [self.signupBackgroundImageView setMultipleTouchEnabled:YES];
    [self.signupBackgroundImageView setUserInteractionEnabled:YES];
}

- (void)signupBackgroundImageViewTapped {
    NSLog(@"Signup Tapped.");
    [self resetViewsForViewController]; // Reset the views for the controller!
}

- (void)resetViewsForViewController {
    [self.signupBackgroundImageView setAlpha:0.0];
    [self.signupBackgroundImageView setFrame:self.signupBackgroundImageViewInitialFrame];
    [self.signupRightArrowImageView setAlpha:0.0];
    [self.signupRightArrowImageView setFrame:self.signupRightArrowImageViewInitialFrame];
    [self.signupInUnderLabel setAlpha:0.0];
    [self.signupInUnderLabel setFrame:self.signupInUnderLabelInitialFrame];
    [self.signupArrowLabel setAlpha:0.0];
    [self.signupArrowLabel setFrame:self.signupArrowLabelInitialFrame];
    [self.secondDotImageView setFrame:self.secondDotImageViewInitialFrame];
    [self.signupBackgroundImageView setMultipleTouchEnabled:NO];
    [self.signupBackgroundImageView setUserInteractionEnabled:NO];
    
    [self.dragMeLabel setAlpha:1.0];
    self.signupViewPresent = false;
}

-(void)viewDidAppear:(BOOL)animated {
    self.initialMovementDotFrame = self.secondDotImageView.frame;
    //[self fadeInHand];
    self.signupBackgroundImageViewInitialFrame = self.signupBackgroundImageView.frame;
    self.signupRightArrowImageViewInitialFrame = self.signupRightArrowImageView.frame;
    self.signupInUnderLabelInitialFrame = self.signupInUnderLabel.frame;
    self.signupArrowLabelInitialFrame = self.signupArrowLabel.frame;
    self.secondDotImageViewInitialFrame = self.secondDotImageView.frame;
}

-(void)viewDidDisappear:(BOOL)animated {
    [self resetViewsForViewController]; // Reset the view controller screen!!!
}

- (void)fadeInHand {
    CGRect finalHandFrame = self.fifthHandImageView.frame;
    CGRect finalHoldAndDragLabelFrame = self.holdAndDragLabel.frame;
    [UIView animateWithDuration:kHandSlideAnimationDuration animations:^{
        //[self.fifthHandImageView setFrame:finalHandFrame];
        [self.fifthHandImageView setFrame:CGRectMake(finalHandFrame.origin.x, finalHandFrame.origin.y + kHandSlideAnimationDistance, finalHandFrame.size.width, finalHandFrame.size.height)];
        
        [self.holdAndDragLabel setFrame:CGRectMake(finalHoldAndDragLabelFrame.origin.x, finalHoldAndDragLabelFrame.origin.y + kHandSlideAnimationDistance, finalHoldAndDragLabelFrame.size.width, finalHoldAndDragLabelFrame.size.height)];
        //[self.holdAndDragLabel setFrame:finalHoldAndDragLabelFrame];
    } completion:^(BOOL finished) {
        [self fadeOutHand];
    }];
}

- (void)fadeOutHand {
    CGRect finalHandFrame = self.fifthHandImageView.frame;
    CGRect finalHoldAndDragLabelFrame = self.holdAndDragLabel.frame;
    [UIView animateWithDuration:kHandSlideAnimationDuration animations:^{
        //[self.fifthHandImageView setFrame:finalHandFrame];
        [self.fifthHandImageView setFrame:CGRectMake(finalHandFrame.origin.x, finalHandFrame.origin.y - kHandSlideAnimationDistance, finalHandFrame.size.width, finalHandFrame.size.height)];
        
        [self.holdAndDragLabel setFrame:CGRectMake(finalHoldAndDragLabelFrame.origin.x, finalHoldAndDragLabelFrame.origin.y - kHandSlideAnimationDistance, finalHoldAndDragLabelFrame.size.width, finalHoldAndDragLabelFrame.size.height)];
        //[self.holdAndDragLabel setFrame:finalHoldAndDragLabelFrame];
    } completion:^(BOOL finished) {
        [self fadeInHand];
    }];
}

- (void)fadeInSignup {
    CGRect signupImageViewFinalFrame = self.signupBackgroundImageView.frame;
    [self.signupBackgroundImageView setFrame:CGRectMake(signupImageViewFinalFrame.origin.x, signupImageViewFinalFrame.origin.y - kSixthScreenLabelSlideAnimationDistance, signupImageViewFinalFrame.size.width, signupImageViewFinalFrame.size.height)];
    
    CGRect signupArrowImageFinalFrame = self.signupRightArrowImageView.frame;
    [self.signupRightArrowImageView setFrame:CGRectMake(signupArrowImageFinalFrame.origin.x, signupArrowImageFinalFrame.origin.y - kSixthScreenLabelSlideAnimationDistance, signupArrowImageFinalFrame.size.width, signupArrowImageFinalFrame.size.height)];
    
    CGRect signupArrowLabelFinalFrame = self.signupArrowLabel.frame;
    [self.signupArrowLabel setFrame:CGRectMake(signupArrowLabelFinalFrame.origin.x, signupArrowLabelFinalFrame.origin.y - kSixthScreenLabelSlideAnimationDistance, signupArrowLabelFinalFrame.size.width, signupArrowLabelFinalFrame.size.height)];
    
    CGRect signupInUnderFinalFrame = self.signupInUnderLabel.frame;
    [self.signupInUnderLabel setFrame:CGRectMake(signupInUnderFinalFrame.origin.x, signupInUnderFinalFrame.origin.y - kSixthScreenLabelSlideAnimationDistance, signupInUnderFinalFrame.size.width, signupInUnderFinalFrame.size.height)];
    
    // Enable interaction on the signupBackgroundImageView.
    [self.signupBackgroundImageView setMultipleTouchEnabled:YES];
    [self.signupBackgroundImageView setUserInteractionEnabled:YES];
    
    [UIView animateWithDuration:kSixthScreenLabelSlideAnimationDuration animations:^{
        [self.signupBackgroundImageView setAlpha:1.0f];
        [self.signupBackgroundImageView setFrame:signupImageViewFinalFrame];
        
        [self.dragMeLabel setAlpha:0.0f];
        
        [self.signupArrowLabel setAlpha:1.0f];
        [self.signupArrowLabel setFrame:signupArrowLabelFinalFrame];
        
        [self.signupInUnderLabel setAlpha:1.0f];
        [self.signupInUnderLabel setFrame:signupInUnderFinalFrame];
        
        [self.signupRightArrowImageView setAlpha:1.0f];
        [self.signupRightArrowImageView setFrame:signupArrowImageFinalFrame];
        
    } completion:^(BOOL finished) {
        if (finished) {
            
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
    if (!self.movementAllowed) {
        return;
    }
    [self.secondDotImageView setFrame:self.initialMovementDotFrame];
    [self sendJsonDictionaryWithType:[NSMutableDictionary new] type:kUsbTypeVrTouchEnd];
    //NSLog(@"touchesEnded");
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.movementAllowed) {
        return;
    }
    [self.secondDotImageView setFrame:self.initialMovementDotFrame];
    [self sendJsonDictionaryWithType:[NSMutableDictionary new] type:kUsbTypeVrTouchEnd];
}

- (void)handleTouch:(UIEvent *)event start:(bool)start {
    if (!self.movementAllowed) {
        return;
    }
    UITouch *touch = [[event allTouches] anyObject];
    if (!touch) {
        return; // No gaurantee of a touch existing.
    }
    _curPoint = [touch locationInView:touch.view];
    
    CGFloat percentOfWidth = [self getPercentageOfWidth:_curPoint.x];
    CGFloat percentOfHeight = [self getPercentageOfHeight:_curPoint.y];
    
    if (!self.signupViewPresent) {
        [self fadeInSignup];
        self.signupViewPresent = true;
    }
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 @(percentOfWidth), kUsbParamXCoordinate,
                                 @(percentOfHeight), kUsbParamYCoordinate,
                                 nil];
    
    // set the frame of the movement!
    [self.secondDotImageView setFrame:CGRectMake(self.initialMovementDotFrame.origin.x + (kJoystickMaxVerticalDistanceFromCenter * percentOfWidth / 100.0), self.initialMovementDotFrame.origin.y + (kJoystickMaxVerticalDistanceFromCenter * percentOfHeight / -100.0), self.initialMovementDotFrame.size.width, self.initialMovementDotFrame.size.height)];
    [self sendJsonDictionaryWithType:dict type:(start ? kUsbTypeVrTouchStart : kUsbTypeVrTouch)];
}

- (CGFloat)getPercentageOfWidth:(CGFloat)xValue {
    if (xValue > (_circleCenterPoint.x + _circleRadius)) {
        return 100;
    }
    if (xValue < (_circleCenterPoint.x - _circleRadius)) {
        return -100;
    }
    return round(100 * (xValue - _circleCenterPoint.x) / _circleRadius);
}

- (CGFloat)getPercentageOfHeight:(CGFloat)yValue {
    if (yValue > (_circleCenterPoint.y + _circleRadius)) {
        return -100;
    }
    if (yValue < (_circleCenterPoint.y - _circleRadius)) {
        return 100;
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
            } else {
                NSLog(@"Sent Message: %@", message);
            }
        }];
        //[self appendOutputMessage:[NSString stringWithFormat:@"[you]: %@", message]];
    } else {
        //NSLog(@"Can not send message — not connected");
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
        NSLog([NSString stringWithFormat:@"Received message: %@", message]);

        NSError *error;
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!json || error) {
            NSLog(@"Failed to convert message into json!");
            return;
        }
        
        if (![json objectForKey:kJsonFieldType]) {
            NSLog([NSString stringWithFormat:@"Received message does not contain %@", kJsonFieldType]);
            return;
        }
        
        if ([kUsbTypePing caseInsensitiveCompare:[json objectForKey:kJsonFieldType]] == NSOrderedSame) {
            NSLog(@"Received Ping!");
            [self sendJsonDictionaryWithType:[NSMutableDictionary new] type:kUsbTypePong];
        }
        if ([kUsbTypeVideoReset caseInsensitiveCompare:[json objectForKey:kJsonFieldType]] == NSOrderedSame) {
            NSLog(@"Inactive video movement.");
            [self resetViewsForViewController]; // Reshow views...
        }
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
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end

