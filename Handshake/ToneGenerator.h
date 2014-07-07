//
//  ToneGenerator.h
//  Handshake
//
//  Created by Matthew Mercieca on 6/29/14.
//  Copyright (c) 2014 Matthew Mercieca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToneGenerator : NSObject

-(ToneGenerator*)init;

-(void)playFrequency:(double)frequency forDuration:(double)duration;
-(void)stop;
@end
