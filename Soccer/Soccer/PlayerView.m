#import "PlayerView.h"

@implementation PlayerView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.image1 = [UIImage imageNamed:@"players/player1.png"];
    self.image2 = [UIImage imageNamed:@"players/player2.png"];
    self.image3 = [UIImage imageNamed:@"players/player3.png"];
    self.image4 = [UIImage imageNamed:@"players/player4.png"];
    self.image5 = [UIImage imageNamed:@"players/player5.png"];
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    Field *f = self.field;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint p = [self fieldToView:f->center];
    CGPoint q[4];
    
    for (int i = 0; i < 4; i++)
    {
        q[i] = [self fieldToView:f->corners[i]];
    }
    
    CGContextDrawImage(context, CGRectMake(p.x - 20, p.y - 20, 40, 40), self.image1.CGImage);
    CGContextDrawImage(context, CGRectMake((q[0].x + q[1].x) / 2 - 20, (q[0].y + q[1].y) / 2 - 20, 40, 40), self.image2.CGImage);
    CGContextDrawImage(context, CGRectMake((q[1].x + q[2].x) / 2 - 20, (q[1].y + q[2].y) / 2 - 20, 40, 40), self.image3.CGImage);
	CGContextDrawImage(context, CGRectMake((q[2].x + q[3].x) / 2 - 20, (q[2].y + q[3].y) / 2 - 20, 40, 40), self.image4.CGImage);
    CGContextDrawImage(context, CGRectMake((q[3].x + q[0].x) / 2 - 20, (q[3].y + q[0].y) / 2 - 20, 40, 40), self.image5.CGImage);
    
}

@end
