
#import "SHPImageDetailViewController.h"
#import "SHPComponents.h"
#import <QuartzCore/QuartzCore.h>

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

@implementation SHPImageDetailViewController

- (void)viewDidUnload {
    self.imageView = nil;
    self.image = nil;
}

-(void)viewDidLoad {

    [super viewDidLoad];
    [self addCloseButton];
    NSLog(@"viewDidLoad.................%@",self.image);
    self.imageView.image = self.image;
    previousScale = 1.0;
    beginX = self.imageView.frame.origin.x;
    beginY = self.imageView.frame.origin.y;
    
    maxScale = (self.image.size.width/self.imageView.frame.size.width)*1.5;
    minScale = 1;
    //UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateImage:)];
    //[self.view addGestureRecognizer:rotationGesture];
    
    //UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
    //[self.view addGestureRecognizer:pinchGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTapGesture];
}


- (void)scaleImage:(UIPinchGestureRecognizer *)recognizer
{
    if ([recognizer scale]<maxScale && [recognizer scale]>minScale){
        CGFloat newScale = 1.0 - (previousScale - [recognizer scale]);
        NSLog(@"scale: %f - %f - %f - %ld", newScale, previousScale, [recognizer scale], (long)UIGestureRecognizerStateEnded);
        CGAffineTransform currentTransformation = self.imageView.transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransformation, newScale, newScale);
        self.imageView.transform = newTransform;
        previousScale = [recognizer scale];
        maxScale = (self.image.size.width/self.imageView.frame.size.width)*1.5;
        minScale = (self.view.frame.size.width/self.imageView.frame.size.width);
    }
}

- (void)rotateImage:(UIRotationGestureRecognizer *)recognizer
{
    if([recognizer state] == UIGestureRecognizerStateEnded) {
        previousRotation = 0.0;
        return;
    }
    CGFloat newRotation = 0.0 - (previousRotation - [recognizer rotation]);
    CGAffineTransform currentTransformation = self.imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransformation, newRotation);
    self.imageView.transform = newTransform;
    previousRotation = [recognizer rotation];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"scale: %f - %f - %f - %f", self.imageView.frame.size.width, self.imageView.frame.size.height, self.image.size.width, self.image.size.height);
    
    if (self.imageView.frame.size.width <= self.image.size.width){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.imageView.transform = CGAffineTransformIdentity;
        self.imageView.frame = CGRectMake(beginX, beginY, self.imageView.frame.size.width*1.5, self.imageView.frame.size.height*1.5);
        [self.imageView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
        [UIView commitAnimations];
    }
    else if (self.imageView.frame.size.width > self.image.size.width){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        self.imageView.frame = CGRectMake(beginX, beginY, self.view.frame.size.width, self.view.frame.size.height);
        [self.imageView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
        [UIView commitAnimations];
    }
    maxScale = (self.image.size.width/self.imageView.frame.size.width)*1.5;
    minScale = (self.view.frame.size.width/self.imageView.frame.size.width);
}




-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


-(void)addCloseButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitle:NSLocalizedString(@"CloseLKey", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeImageControllerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
    [button sizeToFit];
    CGRect buttonFrame = button.frame;
    buttonFrame.size.width = buttonFrame.size.width + 20;
    buttonFrame.size.height = buttonFrame.size.height + 20;
    buttonFrame.origin.y = 20;
    buttonFrame.origin.x = self.view.frame.size.width - buttonFrame.size.width - 20;
    button.frame = buttonFrame;
    CALayer * l = [button layer];
    [l setMasksToBounds:YES];
    [l setBorderWidth:1.0];
    [l setBorderColor:[[UIColor whiteColor] CGColor]];
    [l setCornerRadius:4.0];
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
}



-(void)closeImageControllerButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc {
    NSLog(@"DEALLOCATING SHPImageDetailViewController");
}

@end
