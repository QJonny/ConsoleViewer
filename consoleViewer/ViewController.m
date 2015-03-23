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

@property (nonatomic) NSTimeInterval start;
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
        [self.mcWrapper sendData:[@"-1-" dataUsingEncoding:NSUTF8StringEncoding] reliable:YES error:&error];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enterClicked:(id)sender {
    NSError *error;
    NSDate* d = [NSDate date];
    self.start = [d timeIntervalSince1970];
    [self.mcWrapper sendData:[@"-1-" dataUsingEncoding:NSUTF8StringEncoding] reliable:YES error:&error];
    //[Console notifyText];
}


#pragma mark - MHMultipeerDelegate methods

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper didReceiveData:(NSData *)data fromPeer:(NSString *)peer{
    // Decode the incoming data to a UTF8 encoded string
    NSString *receivedMessage = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];

    if([receivedMessage isEqualToString:@"-1-"]) {
        NSError *error;
        [self.mcWrapper sendData:[@"-2-" dataUsingEncoding:NSUTF8StringEncoding] reliable:YES error:&error];
    }
    else if([receivedMessage isEqualToString:@"-2-"])
    {
        NSDate* d = [NSDate date];
        NSTimeInterval end = [d timeIntervalSince1970];
        NSTimeInterval timeInterval = end - self.start;
        [Console writeLine: [NSString stringWithFormat:@"Received reply in %.3f seconds", timeInterval]];
    }
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper hasConnected:(NSString *)info peer:(NSString *)peer
      displayName:(NSString *)displayName{
    [Console writeLine: [NSString stringWithFormat:@"Peer has connected: %@", displayName]];
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper hasDisconnected:(NSString *)info peer:(NSString *)peer{
    [Console writeLine: @"Peer has disconnected"];
}

- (void)mcWrapper:(MHMultipeerWrapper *)mcWrapper failedToConnect:(NSError *)error{
    [Console writeLine: @"Failed to connect..."];
}




@end
