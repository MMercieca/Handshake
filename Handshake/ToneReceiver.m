//
//  ToneReceiver.m
//  Handshake
//
//  Created by Matthew Mercieca on 7/5/14.
//  Copyright (c) 2014 Matthew Mercieca. All rights reserved.
//

#import "ToneReceiver.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

@interface ToneReceiver() <AVCaptureAudioDataOutputSampleBufferDelegate>

@property (strong, nonatomic) AVCaptureSession* captureSession;
@property (nonatomic) int baseBin;
@property (nonatomic) int baseFrequency;
@property (nonatomic) int sampleWindow;
@property (nonatomic) int sampleRate;
@property (nonatomic) int step;
@end

@implementation ToneReceiver

-(ToneReceiver*)initWithBaseFrequency:(int)baseFrequency withSampleRate:(int)sampleRate andSampleWindow:(int)sampleWindow
{
   self = [super init];
   
   if (self)
   {
      self.baseFrequency = baseFrequency;
      self.sampleWindow = sampleWindow;
      self.sampleRate = sampleRate;
      self.step = (int)(sampleRate / sampleWindow);
      
      [self totalHackToGetAroundAppleNotSettingIOBufferDuration];
   }
   
   return self;
}

-(void)start
{
   AVAudioSession *session = [AVAudioSession sharedInstance];
   [session setActive:YES error:nil];
   
   self.captureSession = [[AVCaptureSession alloc] init];
   AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
   AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
 
   [self.captureSession addInput:input];
   
   AVCaptureAudioDataOutput *output = [[AVCaptureAudioDataOutput alloc] init];
   dispatch_queue_t queue = dispatch_queue_create("Sample callback", DISPATCH_QUEUE_SERIAL);
   [output setSampleBufferDelegate:self queue:queue];
   [self.captureSession addOutput:output];
   
   [self.captureSession startRunning];
}

-(void)stop
{
   [self.captureSession stopRunning];
   
   AVAudioSession *session = [AVAudioSession sharedInstance];
   [session setActive:NO error:nil];
}

- (void)totalHackToGetAroundAppleNotSettingIOBufferDuration
{
   self.captureSession = [[AVCaptureSession alloc] init];
   AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
   AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
   
   [self.captureSession addInput:input];
   
   AVCaptureAudioDataOutput *output = [[AVCaptureAudioDataOutput alloc] init];
   dispatch_queue_t queue = dispatch_queue_create("Sample callback", DISPATCH_QUEUE_SERIAL);
   [output setSampleBufferDelegate:self queue:queue];
   [self.captureSession addOutput:output];
   
   [self.captureSession startRunning];
   [self.captureSession stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
   //StackOverflow: http://stackoverflow.com/questions/14088290/passing-avcaptureaudiodataoutput-data-into-vdsp-accelerate-framework
   
   //Debugging EXC_BAD_ACCESS
   //http://loufranco.com/blog/understanding-exc_bad_access
   
   // trying http://batmobile.blogs.ilrt.org/fourier-transforms-on-an-iphone/
   
   CMItemCount numSamples = CMSampleBufferGetNumSamples(sampleBuffer);
   CMBlockBufferRef audioBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
   size_t lengthAtOffset;
   size_t totalLength;
   char *inSamples;
   CMBlockBufferGetDataPointer(audioBuffer, 0, &lengthAtOffset, &totalLength, &inSamples);
   
   CMAudioFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
   const AudioStreamBasicDescription *desc = CMAudioFormatDescriptionGetStreamBasicDescription(format);
   assert(desc->mFormatID == kAudioFormatLinearPCM);
   if (desc->mChannelsPerFrame == 1 && desc->mBitsPerChannel == 16)
   {
      if (*inSamples == '\0')
      {
         return;
      }
      
      // Convert samples to floats
      float *samples = malloc(numSamples * sizeof(float));
      vDSP_vflt16((short *)inSamples, 1, samples, 1, numSamples);
      
      // Setup the FFT
      int fftRadix = log2(numSamples);
      int halfSamples = (int)(numSamples / 2);
      FFTSetup setup = vDSP_create_fftsetup(fftRadix, FFT_RADIX2);
      
      // Populate *window with the values for a hamming window function
      float *window = (float *)malloc(sizeof(float) * numSamples);
      vDSP_hamm_window(window, numSamples, 0);
      
      // Window the samples
      vDSP_vmul(samples, 1, window, 1, samples, 1, numSamples);
      
      // Define complex buffer
      COMPLEX_SPLIT A;
      A.realp = (float *) malloc(halfSamples * sizeof(float));
      A.imagp = (float *) malloc(halfSamples * sizeof(float));
      
      // Pack samples:
      vDSP_ctoz((COMPLEX*)samples, 2, &A, 1, numSamples/2);
      
      // Perform a forward FFT using fftSetup and A
      // Results are returned in A
      vDSP_fft_zrip(setup, &A, 1, fftRadix, FFT_FORWARD);
      
      // Convert COMPLEX_SPLIT A result to magnitudes
      float amp[numSamples];
      amp[0] = A.realp[0]/(numSamples*2);
      
      // Find the max
      int maxIndex = 0;
      float maxMag = 0.0;
      
      // We can't detect anyting reliably above the Nyquist frequency
      // which is bin n / 2 and bin 0 should always empty.
      for(int i=1; i<halfSamples; i++)
      {
         amp[i]=A.realp[i]*A.realp[i]+A.imagp[i]*A.imagp[i];
         if (amp[i] > maxMag)
         {
            maxMag = amp[i];
            maxIndex = i;
         }
      }
      
      NSNumber* toSend = [[NSNumber alloc] initWithInt:maxIndex];
      
      if (self.delegate)
      {
         [self.delegate didReceiveTone:toSend];
      }
       
      //NSLog(@"Char: %c at %d", (char)(maxIndex - self.baseBin), maxIndex);
   }
}

@end
