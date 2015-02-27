//
//  ViewController.m
//  consoleViewer
//
//  Created by quarta on 26/02/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet UITextField *inputView;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Console init:self.logView withTextField:self.inputView withEnterButton:self.enterButton];
    self.partyTime = [[PLPartyTime alloc] initWithServiceType:@"one2one"];
    self.partyTime.delegate = self;
    [Console writeLine: @"You are currently alone"];
    [self.partyTime joinParty];
    
    [Console writeLine:@"Please enter your username"];
    [Console readLine:@selector(continueProc:) withObject:self];
}


- (void)continueProc:(NSString*)data {
    [Console writeLine:@"Your username is:"];
    [Console writeLine:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enterClicked:(id)sender {
    [Console notifyText];
}


#pragma mark - PLPartyTimeDelegate methods

- (void)partyTime:(PLPartyTime *)partyTime peer:(MCPeerID *)peer changedState:(MCSessionState)state currentPeers:(NSArray *)currentPeers{
    if (self.partyTime.connectedPeers.count<1) {
        [Console writeLine: @"You are currently alone"];
    }else if (self.partyTime.connectedPeers.count==1){
        [Console writeLine: @"There is one other person around"];
    }else{
        [Console writeLine: [NSString stringWithFormat:@"There are %lu people around", (unsigned long)self.partyTime.connectedPeers.count]];
    }
}

- (void)partyTime:(PLPartyTime *)partyTime didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    // Decode the incoming data to a UTF8 encoded string
    NSString *receivedMessage = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];

    [Console writeLine: [NSString stringWithFormat:@"Party received message: %@", receivedMessage]];
}

- (void)partyTime:(PLPartyTime *)partyTime failedToJoinParty:(NSError *)error{
    [Console writeLine: @"Failed to join party..."];
}




@end
