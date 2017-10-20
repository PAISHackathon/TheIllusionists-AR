#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ARController.h"
#import "ARView.h"
#import "Field.h"

@interface ARController : UIViewController <AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic) Field *field;
@property (nonatomic) ARView *arView;
@property (nonatomic) UIWebView *webView;
@property (nonatomic) AVCaptureDevice *camera;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

- (void)cleanup;

@end
