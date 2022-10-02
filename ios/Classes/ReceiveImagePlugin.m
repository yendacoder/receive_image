#import "ReceiveImagePlugin.h"
#if __has_include(<receive_image/receive_image-Swift.h>)
#import <receive_image/receive_image-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "receive_image-Swift.h"
#endif

@implementation ReceiveImagePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftReceiveImagePlugin registerWithRegistrar:registrar];
}
@end
