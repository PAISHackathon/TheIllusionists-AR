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
    Field *f = self.field;
    
    if (self.arView) {
        [self.arView setNeedsDisplay];
    }
    else {
        CGPoint p = [self fieldToView:f->center];
        CGPoint q[4];
        
        for (int i = 0; i < 4; i++)
        {
            q[i] = [self fieldToView:f->corners[i]];
        }
        
        float w = self.view.bounds.size.width;
        
        p.x /= w;
        p.y /= w;
        
        for (int i = 0; i < 4; i++)
        {
            q[i].x /= w;
            q[i].y /= w;
        }


        NSString * js = [NSString stringWithFormat:@"setARObject({center:{x:%f,y:%f},corners:[{x:%f,y:%f},{x:%f,y:%f},{x:%f,y:%f},{x:%f,y:%f}]})", p.x, p.y, q[0].x, q[0].y, q[1].x, q[1].y, q[2].x, q[2].y, q[3].x, q[3].y];
        [self.webView stringByEvaluatingJavaScriptFromString:js];
    }
}

- (void)cleanup
{
    [self.session stopRunning];
}

- (CGPoint)fieldToView:(CGPoint)point
{
    float viewWidth = self.view.bounds.size.width;
    float viewHeight = self.view.bounds.size.height;
    float viewAspectRatio = viewWidth / viewHeight;
    
    float fieldWidth = (float)self.field->width;
    float fieldHeight = (float)self.field->height;
    float fieldAspectRatio = fieldHeight / fieldWidth;
    
    float scale;
    if (fieldAspectRatio <= viewAspectRatio)
    {
        scale = viewWidth / fieldHeight;
    }
    else
    {
        scale = viewHeight / fieldWidth;
    }
    
    float x = scale * (fieldHeight / 2. - point.y) + viewWidth / 2.;
    float y = scale * (point.x - fieldWidth / 2.) + viewHeight / 2.;
    
    //float x = scale * (point.x - fieldWidth / 2.) + viewWidth;
    //float y = scale * (point.y - fieldHeight / 2.) + viewHeight / 2.;
    
    return CGPointMake(x, y);
}

@end

