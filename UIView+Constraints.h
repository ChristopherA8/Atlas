#include <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (fconstraints)
- (void)
    atlas_anchorTop:(nullable NSLayoutAnchor<NSLayoutYAxisAnchor *> *)top
            leading:(nullable NSLayoutAnchor<NSLayoutXAxisAnchor *> *)leading
             bottom:(nullable NSLayoutAnchor<NSLayoutYAxisAnchor *> *)bottom
           trailing:(nullable NSLayoutAnchor<NSLayoutXAxisAnchor *> *)trailing
            padding:(UIEdgeInsets)insets
               size:(CGSize)size;
- (void)atlas_anchorSizeToView:(UIView *)view;
- (void)atlas_centerInView:(UIView *)view;
- (void)atlas_heightWidthAnchorsEqualToSize:(CGSize)size;
- (void)atlas_fillSuperview;
@end

NS_ASSUME_NONNULL_END
