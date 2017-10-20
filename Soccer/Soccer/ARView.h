#import <UIKit/UIKit.h>
#import "Field.h"

@interface ARView : UIView

@property (nonatomic) Field *field;

- (CGPoint)fieldToView:(CGPoint)point;

@end
