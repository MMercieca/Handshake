//
//  ToneTranslator.m
//  Handshake
//
//  Created by Matthew Mercieca on 7/5/14.
//  Copyright (c) 2014 Matthew Mercieca. All rights reserved.
//

#import "ToneTranslator.h"

@interface ToneTranslator()

@property (nonatomic) int base;
@property (nonatomic) int baseBin;
@property (nonatomic) int step;
@end

@implementation ToneTranslator

-(ToneTranslator*)initWithBase:(int)base andWindowSize:(int)windowSize andSampleRate:(int)sampleRate
{
   self = [super init];
   
   if (self)
   {
      self.base = base;
      self.step = (int) (sampleRate / windowSize);
      self.baseBin = (int) (self.base / self.step);
   }
   NSLog(@"%d %d %d", self.base, self.step, self.baseBin);
   return self;
}

-(double)getFrequencyForChar:(char)c
{
   return (double) ((int)c * self.step) + self.base;
}


-(char)getCharForBin:(int)bin
{
   if (bin == self.baseBin)
   {
      return '\1';
   }
   else if (bin > self.baseBin)
   {
      return (char) (bin - self.baseBin);
   }
   return '\0';
}

@end
