//
//  ToneGenerator.m
//  Handshake
//
//  Created by Matthew Mercieca on 6/29/14.
//  Copyright (c) 2014 Matthew Mercieca. All rights reserved.
//

// Largely based on:
//    https://github.com/hollance/AudioBufferPlayer
//    http://christianfloisand.wordpress.com/2013/07/30/building-a-tone-generator-for-ios-using-audio-units/
//    http://atastypixel.com/blog/using-remoteio-audio-unit/
//    http://stackoverflow.com/questions/10180500/how-to-use-kaudiosessionproperty-overridecategorymixwithothers
//    http://www.cocoawithlove.com/2010/10/ios-tone-generator-introduction-to.html

#import "ToneGenerator.h"
#import <AVFoundation/AVFoundation.h>

#define SAMPLE_RATE 44100

@interface ToneGenerator()

@property (nonatomic) double frequency;
@property (nonatomic) double theta;
@property (strong, nonatomic) AVAudioSession *audioSession;
@property (nonatomic) AudioComponentInstance toneUnit;

@property (strong, nonatomic) AVAudioRecorder *recorder;

@end

@implementation ToneGenerator

-(ToneGenerator*)init
{
   self = [super init];
   
   self.audioSession = [AVAudioSession sharedInstance];
   NSError *nsError;
   [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&nsError];

   return self;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
   ToneGenerator* toneGenerator = (__bridge ToneGenerator*)inClientData;
   [toneGenerator stop];
}

-(void)playFrequency:(double)frequency forDuration:(double)duration
{
   [self.audioSession setActive:true error:nil];
   self.frequency = frequency;
   // Create the audio unit as shown above
   [self createToneUnit];
   
   // Start playback
   AudioOutputUnitStart(_toneUnit);
   
   NSDate *future = [NSDate dateWithTimeIntervalSinceNow: (duration/1000) ];
   [NSThread sleepUntilDate:future];
   self.frequency = 0;
   self.theta = 0;
   AudioOutputUnitStop(self.toneUnit);
   AudioUnitUninitialize(self.toneUnit);
   AudioComponentInstanceDispose(self.toneUnit);
   self.toneUnit = nil;
}

-(void)stop
{
   if (self.toneUnit)
   {
      AudioOutputUnitStop(self.toneUnit);
      AudioUnitUninitialize(self.toneUnit);
      AudioComponentInstanceDispose(self.toneUnit);
      self.toneUnit = nil;
   }
   
   [self.audioSession setActive:false error:nil];
}

- (void)createToneUnit
{
	// Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &_toneUnit);
	//NSAssert1(toneUnit, @"Error creating unit: %ld", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = (__bridge void *)self;
	err = AudioUnitSetProperty(self.toneUnit,
                              kAudioUnitProperty_SetRenderCallback,
                              kAudioUnitScope_Input,
                              0,
                              &input,
                              sizeof(input));
	
   const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = SAMPLE_RATE;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
   kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (self.toneUnit,
                               kAudioUnitProperty_StreamFormat,
                               kAudioUnitScope_Input,
                               0,
                               &streamFormat,
                               sizeof(AudioStreamBasicDescription));
}

OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
	// Fixed amplitude is good enough for our purposes
	const double amplitude = 1;
   
	// Get the tone parameters out of the view controller
	//ToneGeneratorViewController *viewController = (ToneGeneratorViewController *)inRefCon;
   ToneGenerator *toneGenerator = (__bridge ToneGenerator*)inRefCon;
   double theta = toneGenerator->_theta;
   double frequency = toneGenerator->_frequency;
	
	double theta_increment = 2.0 * M_PI * frequency / SAMPLE_RATE;
   
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	toneGenerator->_theta = theta;
   
	return noErr;
}

@end
