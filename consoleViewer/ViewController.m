//
//  ViewController.m
//  consoleViewer
//
//  Created by quarta on 26/02/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <MHMultipeerWrapperDelegate>
@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet UITextField *inputView;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@end


@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [Console init:self.logView withTextField:self.inputView withEnterButton:self.enterButton];
    self.mcWrapper = [[MHMultipeerWrapper alloc] initWithServiceType:@"test"];
    self.mcWrapper.delegate = self;
    [Console writeLine: @"You are currently alone."];

    [self.mcWrapper connectToAll];
    
    [Console writeLine:@"Type Enter for sending a message"];
    [Console readLine:@selector(continueProc:) withObject:self];
}


- (void)continueProc:(NSString*)data {
    if ([data isEqualToString:@""]) {
        NSError *error;
        [self.mcWrapper sendData:[@"Hello!!!" dataUsingEncoding:NSUTF8StringEncoding] reliable:YES error:&error];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enterClicked:(id)sender {
    [Console notifyText];
}


#pragma mark - MHMultipeerDelegate methods


- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper didReceiveData:(NSData *)data fromPeer:(NSString *)peer{
    // Decode the incoming data to a UTF8 encoded string
    NSString *receivedMessage = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];

    [Console writeLine: [NSString stringWithFormat:@"Received message: %@", receivedMessage]];
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper hasConnected:(NSString *)info peer:(NSString *)peer
      displayName:(NSString *)displayName{
    [Console writeLine: [NSString stringWithFormat:@"Peer has connected: %@", displayName]];
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper hasDisconnected:(NSString *)info peer:(NSString *)peer{
    [Console writeLine: @"Peer has disconnected..."];
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper failedToConnect:(NSError *)error{
    [Console writeLine: @"Failed to connect..."];
}




@end
