//
//  ViewController.m
//  consoleViewer
//
//  Created by quarta on 26/02/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <MHUnicastSocketDelegate, MHMulticastSocketDelegate>
@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet UITextField *inputView;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@property (copy) void (^send)(void);

@property (nonatomic)NSUInteger count;

@property (nonatomic)NSMutableArray *peers;

@property (nonatomic)NSString* group;

@property (nonatomic) NSTimeInterval start;
@end


@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [Console init:self.logView withTextField:self.inputView withEnterButton:self.enterButton];
    //self.uSocket = [[MHUnicastSocket alloc] initWithServiceType:@"test"];
    //self.uSocket.delegate = self;
    self.mSocket = [[MHMulticastSocket alloc] initWithServiceType:@"test"];
    self.mSocket.delegate = self;
    
    
    self.peers = [[NSMutableArray alloc] init];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    //[appDelegate setUniSocket:self.uSocket];
    [appDelegate setMultiSocket:self.mSocket];

    
    
    [Console writeLine: [NSString stringWithFormat:@"You have peerID %@", [self.mSocket getOwnPeer]]];
    
    [Console writeLine:@"Type Enter for sending a message"];
    [Console readLine:@selector(continueProc:) withObject:self];
}


- (void)continueProc:(NSString*)data {
    NSError *error;
    NSString *str;
    if ([data isEqualToString:@""])
    {
        NSDate* d = [NSDate date];
        self.start = [d timeIntervalSince1970];
        str = @"-1-";
        
        /*MHPacket *packet = [[MHPacket alloc] initWithSource:[self.uSocket getOwnPeer]
                                           withDestinations:self.peers
                                                   withData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self.uSocket sendPacket:packet error:&error];*/
        
        MHPacket *packet = [[MHPacket alloc] initWithSource:[self.mSocket getOwnPeer]
                                           withDestinations:[[NSArray alloc] initWithObjects:@"global", nil]
                                                   withData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        [self.mSocket sendPacket:packet error:&error];
    }
    else
    {
        //[self.uSocket discover];
        [self.mSocket joinGroup:@"global"];
        //str = data;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enterClicked:(id)sender {
    
    [self continueProc:self.inputView.text];
    [self.inputView setText:@""];
    //[Console notifyText];
}




#pragma mark - MHUnicastSocketDelegate methods

- (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket
       didReceivePacket:(MHPacket *)packet
{
    // Decode the incoming data to a UTF8 encoded string
    NSString *receivedMessage = [[NSString alloc] initWithData:packet.data encoding: NSUTF8StringEncoding];

    if([receivedMessage isEqualToString:@"-1-"]) {
        /*NSError *error;
        MHPacket *packet = [[MHPacket alloc] initWithSource:[self.uSocket getOwnPeer]
                                           withDestinations:self.peers
                                                   withData:[@"-2-" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self.uSocket sendPacket:packet error:&error];*/
        [Console writeLine: [NSString stringWithFormat:@"received packet from %@", packet.source]];
    }
    else if([receivedMessage isEqualToString:@"-2-"])
    {
        NSDate* d = [NSDate date];
        NSTimeInterval end = [d timeIntervalSince1970];
        NSTimeInterval timeInterval = end - self.start;
        [Console writeLine: [NSString stringWithFormat:@"Received reply in %.3f seconds", timeInterval]];
    }
}

- (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket
           isDiscovered:(NSString *)info peer:(NSString *)peer
            displayName:(NSString *)displayName{
    [self.peers addObject:peer];
    [Console writeLine: [NSString stringWithFormat:@"Peer has connected: %@", displayName]];
}

- (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket
        hasDisconnected:(NSString *)info peer:(NSString *)peer{
    [self.peers removeObject:peer];
    [Console writeLine: @"Peer has disconnected"];
}

- (void)mhUnicastSocket:(MHUnicastSocket *)mhUnicastSocket
        failedToConnect:(NSError *)error{
    [Console writeLine: @"Failed to connect..."];
}






#pragma mark - MulticastSocketDelegate methods
- (void)mhMulticastSocket:(MHMulticastSocket *)mhMulticastSocket
          failedToConnect:(NSError *)error
{
    [Console writeLine: @"Failed to connect..."];
}

- (void)mhMulticastSocket:(MHMulticastSocket *)mhMulticastSocket
         didReceivePacket:(MHPacket *)packet
{
    // Decode the incoming data to a UTF8 encoded string
    NSString *receivedMessage = [[NSString alloc] initWithData:packet.data encoding: NSUTF8StringEncoding];
    
    if([receivedMessage isEqualToString:@"-1-"]) {
        NSError *error;
       /* MHPacket *packet = [[MHPacket alloc] initWithSource:[self.mSocket getOwnPeer]
                                           withDestinations:[[NSArray alloc] initWithObjects:@"global", nil]
                                                   withData:[@"-2-" dataUsingEncoding:NSUTF8StringEncoding]];

        [self.mSocket sendPacket:packet error:&error];*/
        [Console writeLine: [NSString stringWithFormat:@"received packet from %@", packet.source]];
    }
    else if([receivedMessage isEqualToString:@"-2-"])
    {
        NSDate* d = [NSDate date];
        NSTimeInterval end = [d timeIntervalSince1970];
        NSTimeInterval timeInterval = end - self.start;
        [Console writeLine: [NSString stringWithFormat:@"Received reply in %.3f seconds", timeInterval]];
    }
}

@end
