#import "ViewController.h"
#import "Field.h"
#import "ARController.h"
#import "FieldView.h"
#import "PlayerView.h"

@interface ViewController ()

@property (nonatomic) Field *field;
@property (nonatomic) ARController *arController;
@property (nonatomic) UIButton *fieldButton;
@property (nonatomic) UIButton *playersButton;
@property (nonatomic) UIButton *webButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.field = [[Field alloc] init];
    
    float top = self.view.bounds.origin.y;
    float width = self.view.bounds.size.width;
    
    self.fieldButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fieldButton addTarget:self action:@selector(fieldButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.fieldButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.fieldButton setTitle:@"Field" forState:UIControlStateNormal];
    self.fieldButton.frame = CGRectMake(0, 100, width, 100);
    [self.view addSubview:self.fieldButton];
    
    self.playersButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playersButton addTarget:self action:@selector(playersButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.playersButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.playersButton setTitle:@"Players" forState:UIControlStateNormal];
    self.playersButton.frame = CGRectMake(0, 200, width, 100);
    [self.view addSubview:self.playersButton];
    
    self.webButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.webButton addTarget:self action:@selector(webButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.webButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.webButton setTitle:@"Web" forState:UIControlStateNormal];
    self.webButton.frame = CGRectMake(0, 300, width, 100);
    [self.view addSubview:self.webButton];
    
}

-(void) fieldButtonClicked:(UIButton*)sender
{
    if (self.arController)
    {
        [self.arController cleanup];
        [self.arController.view removeFromSuperview];
        [self.arController removeFromParentViewController];
    }
    
    FieldView *fieldView = [[FieldView alloc] init];
    fieldView.field = self.field;
    
    self.arController = [[ARController alloc] init];
    self.arController.field = self.field;
    self.arController.arView = fieldView;
    
    [self addChildViewController:self.arController];
    [self.arController.view setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.arController.view];
    [self.arController didMoveToParentViewController:self];
}

-(void) playersButtonClicked:(UIButton*)sender
{
    if (self.arController)
    {
        [self.arController cleanup];
        [self.arController.view removeFromSuperview];
        [self.arController removeFromParentViewController];
    }
    
    PlayerView *playerView = [[PlayerView alloc] init];
    playerView.field = self.field;
    
    self.arController = [[ARController alloc] init];
    self.arController.field = self.field;
    self.arController.arView = playerView;
    
    [self addChildViewController:self.arController];
    [self.arController.view setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.arController.view];
    [self.arController didMoveToParentViewController:self];
}

-(void) webButtonClicked:(UIButton*)sender
{
    if (self.arController)
    {
        [self.arController cleanup];
        [self.arController.view removeFromSuperview];
        [self.arController removeFromParentViewController];
    }
    
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"web1" ofType:@"html"];
    NSURL *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSString *html = [[NSString alloc] initWithContentsOfFile:htmlPath];

    
    UIWebView *webView=[[UIWebView alloc]init];
    [webView loadHTMLString:html baseURL:bundleUrl];
    
    //NSString *url=@"http://www.google.com";
    //NSURL *nsurl=[NSURL URLWithString:url];
    //NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    //[webView loadRequest:nsrequest];
      
    self.arController = [[ARController alloc] init];
    self.arController.field = self.field;
    self.arController.webView = webView;
    
    [self addChildViewController:self.arController];
    [self.arController.view setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.arController.view];
    [self.arController didMoveToParentViewController:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
