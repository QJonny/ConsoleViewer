//
//  Logger.m
//  consoleViewer
//
//  Created by quarta on 25/02/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Console.h"

@interface Console ()

@end

@implementation Console

static UITextView* _logView = nil;
static UITextField* _textField = nil;
static UIButton* _enterButton = nil;
static SEL _onResponse = nil;
static id _obj = nil;

+ (void)init:(UITextView*)logView withTextField:(UITextField*)textField withEnterButton:(UIButton*)enterButton {
    _logView = logView;
    _textField = textField;
    _enterButton = enterButton;
    [logView setText:@""];
    [_textField setText:@""];
    //_textField.enabled = NO;
    //_enterButton.enabled = NO;
}

+ (void)writeLine:(NSString*)msg {
    [_logView setText:[NSString stringWithFormat:@"%@%@\n", [_logView text], msg]];
    
    if(_logView.text.length > 0)
    {
        NSRange range = NSMakeRange(_logView.text.length - 1, 1);
        [_logView scrollRangeToVisible:range];
    }
}

+ (void)readLine:(SEL)onResponse withObject:(id)obj {
    _onResponse = onResponse;
    _obj = obj;
    //_textField.enabled = YES;
    //_enterButton.enabled = YES;
}

+ (void)notifyText {
    //_textField.enabled = NO;
    //_enterButton.enabled = NO;
    NSString* data = [NSMutableString stringWithString: _textField.text];
    
    [_textField setText:@""];
    
    [_obj performSelector:_onResponse withObject:data];
}


@end

