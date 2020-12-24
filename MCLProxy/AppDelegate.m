//
//  AppDelegate.m
//  MCLProxy
//
//  Created by Chris Marcellino on 12/23/20.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSString *displayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(id)kCFBundleNameKey];
    NSString *text = NSLocalizedString(@"To enable this extension, open Safari and go to the Safari "
                                       "menu > Preferences > Extensions and check the box next to MCL Proxy.\n\n"
                                       "Then use the toolbar button in Safari to access pages through the proxy.", nil);
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:displayName];
    [alert setInformativeText:text];
    [alert runModal];
    
    [[NSApplication sharedApplication] terminate:self];
}

@end
