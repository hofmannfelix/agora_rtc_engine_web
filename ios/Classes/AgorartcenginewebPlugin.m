#import "AgorartcenginewebPlugin.h"
#if __has_include(<agorartcengineweb/agorartcengineweb-Swift.h>)
#import <agorartcengineweb/agorartcengineweb-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "agorartcengineweb-Swift.h"
#endif

@implementation AgorartcenginewebPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAgorartcenginewebPlugin registerWithRegistrar:registrar];
}
@end
