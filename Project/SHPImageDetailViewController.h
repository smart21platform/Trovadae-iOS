//header

#import <UIKit/UIKit.h>

@interface SHPImageDetailViewController : UIViewController{
    CGFloat previousScale;
    CGFloat previousRotation;
    CGFloat beginX;
    CGFloat beginY;
    CGFloat maxScale;
    CGFloat minScale;
}

@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


- (void)scaleImage:(UIPinchGestureRecognizer *)recognizer;
- (void)rotateImage:(UIRotationGestureRecognizer *)recognizer;
- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer;
@end

