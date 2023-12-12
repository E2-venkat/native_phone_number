#import "PhoneNumberAndSmsPlugin.h"

@implementation PhoneNumberAndSmsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"phone_number_and_sms_auto_fill"
            binaryMessenger:[registrar messenger]];
  PhoneNumberAndSmsPlugin* instance = [[PhoneNumberAndSmsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(nil);
}

@end
