#import <UIKit/UIKit.h>

@interface Field : NSObject
{
	@public int width;
	@public int height;
    @public CGPoint center;
    @public CGPoint corners[4];
    @public uint8_t *map;
}

- (id)init;
- (void)processFrame:(CVImageBufferRef)frame;

@end
