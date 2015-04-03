//
//  ViewController.m
//  consoleViewer
//
//  Created by quarta on 26/02/15.
//  Copyright (c) 2015 quarta. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <MHMultihopDelegate>
@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet UITextField *inputView;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@property (copy) void (^send)(void);

@property (nonatomic)NSUInteger count;

@property (nonatomic)NSMutableArray *peers;

@property (nonatomic) NSTimeInterval start;
@end


@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [Console init:self.logView withTextField:self.inputView withEnterButton:self.enterButton];
    self.mhHandler = [[MHMultihop alloc] initWithServiceType:@"test"];
    self.mhHandler.delegate = self;
    
    self.peers = [[NSMutableArray alloc] init];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    [appDelegate setMultihopHandler:self.mhHandler];
    
    NSString *str = @"";
    self.count = 0;
    
    for (int i = 0; i < 1000; i++)
    {
        str = [NSString stringWithFormat:@"%@%@", str, @"0000000000"];
    }

    
    [Console writeLine:[NSString stringWithFormat:@"Length: %d bytes", str.length]];
    
    ViewController * __weak weakSelf = self;
    
    
    self.send = ^{
        if (weakSelf)
        {
            MHPacket *packet = [[MHPacket alloc] initWithSource:[weakSelf.mhHandler getOwnPeer]
                                               withDestinations:weakSelf.peers
                                                       withData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            NSError *error;
            [weakSelf.mhHandler sendPacket:packet error:&error];

            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), weakSelf.send);
        }
    };
    
    
    
    [Console writeLine: @"You are currently alone."];

    [self.mhHandler discover];
    
    [Console writeLine:@"Type Enter for sending a message"];
    [Console readLine:@selector(continueProc:) withObject:self];
}


- (void)continueProc:(NSString*)data {
    /*NSError *error;
    if ([data isEqualToString:@""])
    {
        NSDate* d = [NSDate date];
        self.start = [d timeIntervalSince1970];
        [self.mhHandler sendData:[@"-1-" dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    }
    else
    {
        [self.mhHandler sendData:[data dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    }*/
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1000 * NSEC_PER_MSEC)), dispatch_get_main_queue(), self.send);
    
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


#pragma mark - MHMultipeerDelegate methods

- (void)mhHandler:(MHMultihop *)mhHandler didReceivePacket:(MHPacket *)packet{
    // Decode the incoming data to a UTF8 encoded string
    NSString *receivedMessage = [[NSString alloc] initWithData:packet.data encoding: NSUTF8StringEncoding];

    if([receivedMessage isEqualToString:@"-1-"]) {
        NSError *error;
        MHPacket *packet = [[MHPacket alloc] initWithSource:[self.mhHandler getOwnPeer]
                                           withDestinations:self.peers
                                                   withData:[@"-2-" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self.mhHandler sendPacket:packet error:&error];
    }
    else if([receivedMessage isEqualToString:@"-2-"])
    {
        NSDate* d = [NSDate date];
        NSTimeInterval end = [d timeIntervalSince1970];
        NSTimeInterval timeInterval = end - self.start;
        [Console writeLine: [NSString stringWithFormat:@"Received reply in %.3f seconds", timeInterval]];
    }
    else
    {
        self.count++;
        
        if(self.count % 100 == 0)
        {
            [Console writeLine: [NSString stringWithFormat:@"msg n %d", self.count]];//[NSString stringWithFormat:@"Msg: %@", receivedMessage]];
        }
    }
    
}

- (void)mhHandler:(MHMultihop *)mhHandler isDiscovered:(NSString *)info peer:(NSString *)peer
      displayName:(NSString *)displayName{
    [self.peers addObject:peer];
    [Console writeLine: [NSString stringWithFormat:@"Peer has connected: %@", displayName]];
}

- (void)mhHandler:(MHMultihop *)mhHandler hasDisconnected:(NSString *)info peer:(NSString *)peer{
    [self.peers removeObject:peer];
    [Console writeLine: @"Peer has disconnected"];
}

- (void)mhHandler:(MHMultihop *)mhHandler failedToConnect:(NSError *)error{
    [Console writeLine: @"Failed to connect..."];
}




@end
