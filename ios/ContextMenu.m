#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ContextMenu, NSObject)

RCT_EXTERN_METHOD(showMenu:(NSDictionary *)options
                  callback:(RCTResponseSenderBlock)callback)

@end
