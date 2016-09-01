//
//  SHPNetworkErrorViewController.m
//  Shopper
//
//  Created by andrea sponziello on 11/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPNetworkErrorViewController.h"

@interface SHPNetworkErrorViewController ()

@end

@implementation SHPNetworkErrorViewController

//@synthesize buttonTarget = _buttonTarget;
//@synthesize buttonSelector = _buttonSelector;
@synthesize message = _message;

-(void)setTargetAndSelector:(id)buttonTarget buttonSelector:(SEL) buttonSelector {
//    _buttonTarget = target;
//    _buttonSelector = buttonSelector;
    [retryButton addTarget:buttonTarget action:buttonSelector forControlEvents:UIControlEventTouchUpInside];
}

-(void)setMessage:(NSString *)message {
    _message = message;
    messageLabel.text = self.message;
}

-(id)initWithFrame:(CGRect)theFrame {
    if (self = [super init]) {
        frame = theFrame;
        self.view.frame = theFrame;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self createTheView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    container = nil;
    messageLabel = nil;
    self.message = nil;
    retryButton = nil;
}

static NSInteger retryButtonTag = 10;
static NSInteger messageLabelTag = 20;

-(void)createTheView {
    [super loadView];
    containerWidth = frame.size.width - 40; // 20pt >> container width << 20pt
    container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, containerWidth, 120)];
//    container.backgroundColor = [UIColor lightGrayColor];
    messageLabel = [[UILabel alloc] init];
    messageLabel.textColor = [UIColor darkGrayColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
//    messageLabel.backgroundColor = [UIColor darkGrayColor];
    messageLabel.font = [UIFont boldSystemFontOfSize:16];
    messageLabel.tag = messageLabelTag;
    messageLabel.frame = CGRectMake(2, 2, container.frame.size.width, 30);
    [container addSubview:messageLabel];
    
    CGRect buttonFrame = CGRectMake(0, 60, container.frame.size.width, 36);
    retryButton = [ UIButton buttonWithType:UIButtonTypeRoundedRect];
    retryButton.frame = buttonFrame;
    
    // customize with image
    UIImage *backgroundImageNormal = [UIImage imageNamed:@"tanButton"];
    backgroundImageNormal = [backgroundImageNormal resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    [retryButton setBackgroundImage:backgroundImageNormal forState:UIControlStateNormal];
    UIImage *backgroundImagePressed = [UIImage imageNamed:@"tanButtonHighlight"];
    backgroundImagePressed = [backgroundImagePressed resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 5.0)];
    [retryButton setBackgroundImage:backgroundImagePressed forState:UIControlStateHighlighted];
    retryButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//    [retryButton setTitle:NSLocalizedString(@"SigninLKey", nil) forState:UIControlStateNormal];
    
    retryButton.tag = retryButtonTag;
    retryButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    retryButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    retryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    [retryButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    [retryButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [retryButton setTitle:NSLocalizedString(@"TryAgainLKey", nil) forState:UIControlStateNormal];
    [container addSubview:retryButton];
    
    [self.view addSubview:container];
    container.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//-(void)dealloc {
//    container = nil;
//    messageLabel = nil;
//    retryButton = nil;
//}

@end
