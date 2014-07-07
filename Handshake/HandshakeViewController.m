//
//  HandshakeViewController.m
//  Handshake
//
//  Created by Matthew Mercieca on 6/28/14.
//  Copyright (c) 2014 Matthew Mercieca. All rights reserved.
//

#import "HandshakeViewController.h"
#import "IpHelper.h"
#import "ToneGenerator.h"
#import "ToneReceiver.h"
#import "ToneTranslator.h"

#define SAMPLE_RATE 44100
#define NUM_SAMPLES 1024
#define TRANSMIT_LENGTH 200

#define BASE 19000 //18000 Hz seems to be detectable (hearable?)
                   //140-160 Hz is not quite hearable

@interface HandshakeViewController () <ToneReceiverProtocol>

@property (strong, nonatomic) ToneGenerator* toneGenerator;
@property (strong, nonatomic) ToneReceiver* toneReceiver;
@property (strong, nonatomic) ToneTranslator* toneTranslator;
@property (strong, nonatomic) IBOutlet UILabel *heardLabel;
@property (strong, nonatomic) NSMutableString* heardText;
@property (nonatomic) BOOL charStarted;

@property (nonatomic) BOOL listening;
@property (strong, nonatomic) IBOutlet UIButton *listenButton;
@end

@implementation HandshakeViewController

- (void)viewDidLoad
{
   [super viewDidLoad];
   
   self.toneGenerator = [[ToneGenerator alloc] init];
   self.toneReceiver = [[ToneReceiver alloc] initWithBaseFrequency:BASE withSampleRate:SAMPLE_RATE andSampleWindow:NUM_SAMPLES];
   self.toneTranslator = [[ToneTranslator alloc] initWithBase:BASE andWindowSize:NUM_SAMPLES andSampleRate:SAMPLE_RATE];
   self.toneReceiver.delegate = self;
   
   self.listening = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
   [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   [self.toneGenerator stop];
}


- (IBAction)goClicked:(UIButton *)sender {
   NSString* ipAddress = [IpHelper getIpAddress];
   self.heardLabel.text = [NSString stringWithFormat:@"Sending: %@", ipAddress];
   
   for (int i = 0; i < [ipAddress length]; i++)
   {
      char ch = [ipAddress characterAtIndex:i];
      double frequency = [self.toneTranslator getFrequencyForChar:ch];
      [self.toneGenerator playFrequency:BASE forDuration:TRANSMIT_LENGTH];
      [self.toneGenerator playFrequency:frequency forDuration:TRANSMIT_LENGTH];
   }
   
   self.heardLabel.text = [NSString stringWithFormat:@"Sent: %@", ipAddress];
}

- (IBAction)listenClicked:(UIButton *)sender
{
   if (self.listening)
   {
      [self.toneReceiver stop];
      
      [self.listenButton setTitle:@"Listen" forState:UIControlStateNormal];
      self.listening = NO;
   }
   else
   {
      [self.listenButton setTitle:@"Stop Listening" forState:UIControlStateNormal];
      self.listening = YES;
      self.heardText = [NSMutableString stringWithString:@"Receiving: "];
      [self.heardLabel setText:self.heardText];
      self.charStarted = NO;
      [self.toneReceiver start];
   }
}

- (void)didReceiveTone:(NSNumber*)fromBin
{
   char c = [self.toneTranslator getCharForBin:[fromBin intValue]];
   
   if (c == '\0')
   {
      return;
   }
   
   if (c == '\1' && !self.charStarted)
   {
      self.charStarted = YES;
      return;
   }
   else if (c != '\1' && self.charStarted && c > ' ' && c < '~')
   {
      NSLog(@"char received: %c", c);
      self.heardText = [NSMutableString stringWithFormat:@"%@%c", self.heardText, c];
      dispatch_async(dispatch_get_main_queue(), ^{ self.heardLabel.text = self.heardText; });
      NSLog(@"%@", self.heardText);
      self.charStarted = NO;
   }
}

@end
