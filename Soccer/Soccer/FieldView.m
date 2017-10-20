#import "FieldView.h"

@implementation FieldView


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint p;
    
    /*
    const uint8_t *map = self.field->map;
    if (map)
    {
        CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
        
        int w = self.cameraWidth;
        int h = self.cameraHeight;
    
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                if (map[y * w + x])
                {
                    CGPoint p = [self cameraToView:CGPointMake(x, y)];
                    CGContextFillRect(context, CGRectMake(p.x, p.y, 4, 4));
                }
            }
        }
    }
     */
    
    /*
    p = [self cameraToView:self.field->center];
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(p.x - 10, p.y - 10, 21, 21));
    */
    
    //CGContextSetLineWidth(context, 5.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    
    p = [self fieldToView:self.field->corners[0]];
    CGContextMoveToPoint(context, p.x, p.y);
    for (int i = 0; i < 4; i++)
    {
        p = [self fieldToView:self.field->corners[(i + 1) % 4]];
        CGContextAddLineToPoint(context, p.x, p.y);
    }
    CGContextStrokePath(context);
}

@end
