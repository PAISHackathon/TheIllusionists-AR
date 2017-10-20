#import "Field.h"

typedef struct
{
    float m11;
    float m20;
    float m02;
    float m21;
    float m12;
    float m30;
    float m03;
    float orientation;
    float elevation;
    float x[4];
    float y[4];
    float v;
}
Shape;

@interface Field ()
{
    Shape *shapes;
    int shapesLen;
}

@end

@implementation Field

- (id)init
{
    self = [super init];
    
    NSString* file = [[NSBundle mainBundle] pathForResource:@"shapes" ofType:@"csv"];
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    
    NSArray* lines = [content componentsSeparatedByString:@"\n"];
    
    shapesLen = lines.count - 1;
    shapes = (Shape *)malloc(shapesLen * sizeof(Shape));
    Shape *s = shapes;
    
    for (int i = 0; i < shapesLen; i++, s++)
    {
        NSString* line = [lines objectAtIndex:i];
        NSArray* pieces = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        s->m11 = [[pieces objectAtIndex:0] floatValue];
        s->m20 = [[pieces objectAtIndex:1] floatValue];
        s->m02 = [[pieces objectAtIndex:2] floatValue];
        s->m21 = [[pieces objectAtIndex:3] floatValue];
        s->m12 = [[pieces objectAtIndex:4] floatValue];
        s->m30 = [[pieces objectAtIndex:5] floatValue];
        s->m03 = [[pieces objectAtIndex:6] floatValue];
        
        s->orientation = [[pieces objectAtIndex:7] floatValue];
        s->elevation = [[pieces objectAtIndex:8] floatValue];
        
        s->x[0] = [[pieces objectAtIndex:9] floatValue];
        s->y[0] = [[pieces objectAtIndex:10] floatValue];
        
        s->x[1] = [[pieces objectAtIndex:11] floatValue];
        s->y[1] = [[pieces objectAtIndex:12] floatValue];

        s->x[2] = [[pieces objectAtIndex:13] floatValue];
        s->y[2] = [[pieces objectAtIndex:14] floatValue];

        s->x[3] = [[pieces objectAtIndex:15] floatValue];
        s->y[3] = [[pieces objectAtIndex:16] floatValue];
        
        s->v = sqrtf(s->m11 * s->m11 + s->m20 * s->m20 + s->m02 * s->m02 + s->m21 * s->m21 + s->m12 * s->m12 + s->m30 * s->m30 + s->m03 * s->m03);
    }
    
    return self;
}

- (void)processFrame:(CVImageBufferRef)frame
{
    width = CVPixelBufferGetWidth(frame);
    height = CVPixelBufferGetHeight(frame);
    
    /*
    if (!map)
    {
        map = (uint8_t *)malloc(width * height * sizeof(uint8_t));
    }
    
    memset(map, 0, width * height * sizeof(uint8_t));
     */

    double M00 = 0;
    double M10 = 0;
    double M01 = 0;
    double M11 = 0;
    double M20 = 0;
    double M02 = 0;
    double M21 = 0;
    double M12 = 0;
    double M30 = 0;
    double M03 = 0;
    
    int lumaBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(frame, 0);
    int cbcrBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(frame, 1);
    
    const uint8_t *lumaRow = CVPixelBufferGetBaseAddressOfPlane(frame, 0);
    const uint8_t *cbcrRow = CVPixelBufferGetBaseAddressOfPlane(frame, 1);
    
    for (int j = 0; j < height; j += 4, lumaRow += 4 * lumaBytesPerRow, cbcrRow += 2 * cbcrBytesPerRow)
    {
        double y1 = (double)j;
        double y2 = y1 * y1;
        double y3 = y2 * y1;

        for (int i = 0; i < width; i += 4)
        {
            int luma = lumaRow[i];
            if (luma > 64)
            {
                int cb = cbcrRow[i];
                if (cb < 128)
                {
                    int cr = cbcrRow[i + 1];
                    if (cr < 128)
                    {
                        if (cb + cr < 256 - (luma / 4))
                        {
                            double x1 = (double)i;
                            double x2 = x1 * x1;
                            double x3 = x2 * x1;
                            
                            M00++;
                            M10 += x1;
                            M01 += y1;
                            M11 += x1 * y1;
                            M20 += x2;
                            M02 += y2;
                            M21 += x2 * y1;
                            M12 += x1 * y2;
                            M30 += x3;
                            M03 += y3;
                            
                            //map[j * width + i] = 1;
                        }
                    }
                }
            }
        }
    }
    
    double sqrtM00 = sqrt(M00);
    
    double x = M10 / M00;
    double y = M01 / M00;

    center = CGPointMake(x, y);
    
    float m11 = (float)((M11 - x * M01) / (M00 * M00));
    float m20 = (float)((M20 - x * M10) / (M00 * M00));
    float m02 = (float)((M02 - y * M01) / (M00 * M00));
    float m21 = (float)((M21 - 2. * x * M11 - y * M20 + 2. * x * x * M01) / (M00 * M00 * sqrtM00));
    float m12 = (float)((M12 - 2. * y * M11 - x * M02 + 2. * y * y * M10) / (M00 * M00 * sqrtM00));
    float m30 = (float)((M30 - 3. * x * M20 + 2. * x * x * M10) / (M00 * M00 * sqrtM00));
    float m03 = (float)((M03 - 3. * y * M02 + 2. * y * y * M01) / (M00 * M00 * sqrtM00));
    
    float max = 0;
    const Shape *match = NULL;
    const Shape *s = shapes;
    
    for (int i = 0; i < shapesLen; i++, s++)
    {
        float d = (m11 * s->m11 + m20 * s->m20 + m02 * s->m02 + m21 * s->m21 + m12 * s->m12 + m30 * s->m30 + m03 * s->m03) / s->v;
        
        if (d > max)
        {
            max = d;
            match = s;
        }
    }
    
    if (match)
    {
        for (int i = 0; i < 4; i++)
        {
            corners[i] = CGPointMake(x + match->x[i] * 4 * sqrtM00, y + match->y[i] * 4 * sqrtM00);
        }
    }
}

@end
