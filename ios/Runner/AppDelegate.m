#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
// Add the GoogleMaps import.
#import "GoogleMaps/GoogleMaps.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  [GMSServices provideAPIKey:@"AIzaSyBJ3yL6Xj0mkXcUt5GxtFYbiBp60q709RA"];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
