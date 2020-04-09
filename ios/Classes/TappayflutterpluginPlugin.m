#import "TappayflutterpluginPlugin.h"
#if __has_include(<tappayflutterplugin/tappayflutterplugin-Swift.h>)
#import <tappayflutterplugin/tappayflutterplugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tappayflutterplugin-Swift.h"
#endif

@implementation TappayflutterpluginPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTappayflutterpluginPlugin registerWithRegistrar:registrar];
}
@end
