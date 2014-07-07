//
//  ToneReceiver.h
//  Handshake
//
//  Created by Matthew Mercieca on 7/5/14.
//  Copyright (c) 2014 Matthew Mercieca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToneReceiver : NSObject

-(ToneReceiver*)initWithBaseFrequency:(int)baseFrequency withSampleRate:(int)sampleRate andSampleWindow:(int)sampleWindow;
-(void)start;
-(void)stop;

@property (nonatomic, assign) id delegate;

@end

@protocol ToneReceiverProtocol

-(void)didReceiveTone:(NSNumber*)fromBin;

@end