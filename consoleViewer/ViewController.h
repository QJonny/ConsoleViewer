//
//  ViewController.h
//  consoleViewer
//
//  Created by quarta on 26/02/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Console.h"
#import "MHUnicastSocket.h"
#import "MHMulticastSocket.h"

@interface ViewController : UIViewController

@property MHUnicastSocket* uSocket;
@property MHMulticastSocket* mSocket;
@end

