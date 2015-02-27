//
//  Logger.h
//  consoleViewer
//
//  Created by quarta on 25/02/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#ifndef consoleViewer_Logger_h
#define consoleViewer_Logger_h

#import <UIKit/UIKit.h>

@interface Console: NSObject

+ (void)init:(UITextView*)logView withTextField:(UITextField*)textField withEnterButton:(UIButton*)enterButton;
+ (void)writeLine:(NSString*)msg;
+ (void)readLine:(SEL)onResponse withObject:(id)obj;
+ (void)notifyText;

@end
#endif
