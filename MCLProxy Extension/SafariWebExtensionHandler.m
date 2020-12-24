//
//  SafariWebExtensionHandler.m
//  MCLProxy Extension
//
//  Created by Chris Marcellino on 12/23/20.
//

#import <SafariServices/SafariServices.h>
#import "SafariWebExtensionHandler.h"

// Constants (also see excludedHostSuffixes below)
static NSString *const ezProxyHost = @"mclibrary.idm.oclc.org";

@implementation SafariWebExtensionHandler

- (void)toolbarItemClickedInWindow:(SFSafariWindow *)window
{
    [window getActiveTabWithCompletionHandler:^(SFSafariTab * _Nullable activeTab) {
        [activeTab getActivePageWithCompletionHandler:^(SFSafariPage * _Nullable activePage) {
            [activePage getPagePropertiesWithCompletionHandler:^(SFSafariPageProperties * _Nullable properties) {
                NSURL *sourceURL = [properties url];
                if (sourceURL) {
                    NSURL *proxyURL = [self proxyURLForSourceURL:sourceURL];
                    if (proxyURL) {
                        [window openTabWithURL:proxyURL
                          makeActiveIfPossible:YES
                             completionHandler:^(SFSafariTab * _Nullable tab) {
                            // Close the original tab if successful
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
                BOOL allow = [self proxyURLForSourceURL:[properties url]] != nil;
                validationHandler(allow, nil);
            }];
        }];
    }];
}

- (NSURL *)proxyURLForSourceURL:(NSURL *)sourceURL
{
    if (!sourceURL) {
        return nil;
    }
    
    NSURL *newURL = nil;
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:sourceURL resolvingAgainstBaseURL:YES];
    // Don't convert authenticated or non-conventional port pages
    if ([urlComponents user] || [urlComponents password] || [urlComponents port]) {
        return nil;
    }
    
    
    NSString *originalScheme = [urlComponents scheme];
    NSString *originalHost = [urlComponents host];
    NSString *originalPath = [urlComponents path];
    NSString *originalQuery = [urlComponents query];
    
    if (urlComponents && [self allowScheme:originalScheme] && [self allowHost:originalHost]) {
        [urlComponents setScheme:@"https"];
        [urlComponents setHost:ezProxyHost];
        
        // Make the new path and query "/login?url=ORIGINAL_URL". NSURLComponent will escape as needed.
        [urlComponents setPath:@"/login"];
        
        NSMutableString *newQuery = [NSMutableString stringWithString:@"url="];
        [newQuery appendString:originalScheme];
        [newQuery appendString:@"://"];
        [newQuery appendString:originalHost];
        [newQuery appendString:originalPath];
        if (originalQuery) {
            if (!originalPath || [originalPath length] == 0) {
                [newQuery appendString:@"/"];
            }
            [newQuery appendString:@"?"];
            [newQuery appendString:originalQuery];
        }
        // Ignore the fragment since it is likely to cause more harm than good
        [urlComponents setPercentEncodedQuery:newQuery];
        
        newURL = [urlComponents URL];
    }
    
    return newURL;
}

- (BOOL)allowScheme:(NSString *)scheme
{
    if (!scheme) {
        return NO;
    }
    
    NSArray *const allowedSchemes = @[ @"http", @"https" ];
    
    BOOL allow = NO;
    for (NSString *allowedScheme in allowedSchemes) {
        if ([scheme isCaseInsensitiveLike:allowedScheme]) {
            allow = YES;
            break;
        }
    }
    
    return allow;
}

- (BOOL)allowHost:(NSString *)host
{
    if (!host) {
        return NO;
    }
    
    NSArray *const excludedHostSuffixes = @[ ezProxyHost, @"mayo.edu", @"mayoclinic.org", @"local", @"localhost"];
    
    BOOL allow = YES;
    
    // Exlcude inapplicable hosts, comparing lowercase strings without locale sensitivity
    host = [host lowercaseString];
    for (NSString *suffix in excludedHostSuffixes) {
        NSString *lowerSuffix = [suffix lowercaseString];
        
        if ([host hasSuffix:[@"." stringByAppendingString:lowerSuffix]] ||
            [host isEqual:lowerSuffix] ||
            [host isEqual:[lowerSuffix stringByAppendingString:@"."]]) {
            allow = NO;
            break;
        }
    }
    
    return allow;
}

@end
