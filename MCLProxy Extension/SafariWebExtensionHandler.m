//
//  SafariWebExtensionHandler.m
//  MCLProxy Extension
//
//  Created by Chris Marcellino on 12/23/20.
//

#import <SafariServices/SafariServices.h>
#import "SafariWebExtensionHandler.h"

static NSString *const ezProxyHost = @"mclibrary.idm.oclc.org";

@implementation SafariWebExtensionHandler

- (void)toolbarItemClickedInWindow:(SFSafariWindow *)window
{
    [window getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
        [activeTab getActivePageWithCompletionHandler:^(SFSafariPage * _Nullable activePage) {
            [activePage getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties * _Nullable properties) {
                NSURL *url = [[properties url] absoluteURL];
                NSString *host = [url host];
                NSString *path = [url path];
                if (!path) {
                    path = @"";
                }
                
                if (url && host) {
                    NSMutableString *proxyURL = [[NSMutableString alloc] init];
                    [proxyURL appendString:@"https://"];
                    [proxyURL appendString:ezProxyHost];
                    [proxyURL appendString:@"/login?url="];     // EZProxy prefix
                    [proxyURL appendString:@"http://"];         // first portion of the source address (cannot be TLS)
                    [proxyURL appendString:host];
                    [proxyURL appendString:path];
                    
                    NSURL *newURL = [NSURL URLWithString:proxyURL];
                    if (newURL) {
                        [window openTabWithURL:newURL makeActiveIfPossible:YES completionHandler:^(SFSafariTab * _Nullable tab) {
                            [activeTab close];
                        }];
                    }
                }
            }];
        }];
    }];
}

- (void)validateToolbarItemInWindow:(SFSafariWindow *)window
                  validationHandler:(void (^)(BOOL enabled, NSString *badgeText))validationHandler
{
    [window getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
        [activeTab getActivePageWithCompletionHandler:^(SFSafariPage * _Nullable activePage) {
            [activePage getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties * _Nullable properties) {
                BOOL allow = NO;
                
                NSString *host = [[[properties url] host] lowercaseString];
                if (host) {
                    allow = YES;
                    
                    // Exlcude inapplicable hosts
                    NSArray *excludedHostSuffixes = @[ ezProxyHost, @"mayo.edu", @"mayoclinic.org"];
                    for (NSString *suffix in excludedHostSuffixes) {
                        if ([host hasSuffix:[@"." stringByAppendingString:suffix]] || [host isEqual:suffix]) {
                            allow = NO;
                            break;
                        }
                    }
                }
                
                validationHandler(allow, nil);
            }];
        }];
    }];
}

@end
