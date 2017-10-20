#import "ARView.h"

@implementation ARView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.opaque = NO;
    
    return self;
}

- (CGPoint)fieldToView:(CGPoint)point
{
    float viewWidth = self.bounds.size.width;
    float viewHeight = self.bounds.size.height;
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
