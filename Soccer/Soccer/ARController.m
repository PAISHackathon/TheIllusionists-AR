#import <AVFoundation/AVFoundation.h>
#import "ARController.h"


@implementation ARController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            self.camera = device;
            break;
        }
    }
    
    if (!self.camera)
    {
        NSLog(@"ERROR: no back camera");
    }
    
    self.session = [[AVCaptureSession alloc] init];
    //session.sessionPreset = AVCaptureSessionPresetMedium;
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.camera error:&error];
    if (!input)
    {
        NSLog(@"ERROR: trying to get camera input: %@", error);
    }
    
    [self.session addInput:input];
    
    AVCaptureVideoDataOutput* output = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t queue=dispatch_queue_create("cameraOutputQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange], (id)kCVPixelBufferPixelFormatTypeKey, nil];
    
    output.alwaysDiscardsLateVideoFrames = YES;
    
    [self.session addOutput:output];
    
    if (self.arView) {
    	self.arView.frame = self.view.bounds;
    	[self.view addSubview:self.arView];
    }
    else if (self.webView) {
        self.webView.frame = self.view.bounds;
        [self.view addSubview:self.webView];
    }
    
    [self.session startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void) captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef frame = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(frame, 0);
    [self.field processFrame:frame];
    CVPixelBufferUnlockBaseAddress(frame, 0);
    
    [self performSelectorOnMainThread:@selector(updateARView) withObject:nil waitUntilDone:NO];
}

- (void)updateARView
{
    if (self.arView) {
        [self.arView setNeedsDisplay];
    }
    else {
       
    }
}

- (void)cleanup
{
    [self.session stopRunning];
}


@end

