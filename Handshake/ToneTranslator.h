//
//  ToneTranslator.h
//  Handshake
//
//  Created by Matthew Mercieca on 7/5/14.
//  Copyright (c) 2014 Matthew Mercieca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToneTranslator : NSObject

-(ToneTranslator*)initWithBase:(int)base andWindowSize:(int)windowSize andSampleRate:(int)sampleRate;
-(double)getFrequencyForChar:(char)c;
-(char)getCharForBin:(int)bin;

@end
