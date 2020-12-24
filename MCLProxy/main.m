//
//  main.m
//  MCLProxy
//
//  Created by Chris Marcellino on 12/23/20.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[])
{
    AppDelegate *delegate = [[AppDelegate alloc] init];
    [[NSApplication sharedApplication] setDelegate:delegate];
    return NSApplicationMain(argc, argv);
}
