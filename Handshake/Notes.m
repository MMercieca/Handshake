//
//  Notes.m
//  Handshake
//
//  Created by Matthew Mercieca on 7/5/14.
//  Copyright (c) 2014 Matthew Mercieca. All rights reserved.
//

#import "Notes.h"

@implementation Notes

@end

//NSLog(@"%f", desc->mSampleRate);
/*
 if (*samples == '\0')
 {
 return;
 }
 
 float *convertedSamples = malloc(numSamples * sizeof(float));
 
 
 vDSP_vflt16((short *)samples, 1, convertedSamples, 1, numSamples);
 
 */
/*
 //So, FFT here
 FFTSetup setup;
 int fftRadix = log2(numSamples);
 int halfSamples = (int)(numSamples / 2);
 // trying http://batmobile.blogs.ilrt.org/fourier-transforms-on-an-iphone/
 setup = vDSP_create_fftsetup(fftRadix, FFT_RADIX2);
 
 */

/*
 float *window = (float*)malloc(sizeof(float) * numSamples);
 vDSP_hamm_window(window, numSamples, 0);
 vDSP_vmul(self.convertedSamples, 1, window, 1, self.convertedSamples, 1, halfSamples);
 */


//float *outputLocation = malloc(sizeof(float) * numSamples);


/*
 DSPSplitComplex output;
 output.realp = (float *) malloc(halfSamples * sizeof(float));
 output.imagp = (float *) malloc(halfSamples * sizeof(float));
 */

//output.realp = outputLocation;
//output.imagp = &outputLocation[halfSamples];

// float *outputMemory = malloc(numSamples * sizeof *outputMemory);
/*
 DSPSplitComplex *output;
 output->realp = outputMemory;
 output->imagp = outputMemory + halfSamples;
 */

/*
 vDSP_ctoz((COMPLEX*)self.convertedSamples, 2, &output, 1, halfSamples);
 
 vDSP_fft_zrip(setup, &output, 2, fftRadix, FFT_FORWARD);
 
 float mag[numSamples];
 
 mag[0] = output.realp[0]/(numSamples*2);
 float maxMag = 0.0;
 int maxIndex = 1;
 
 for (int i = 1; i < numSamples; i++)
 {
 float currentMag = (output.realp[i] * output.realp[i]) + (output.imagp[i] * output.imagp[i]);
 if (currentMag > maxMag)
 {
 maxMag = currentMag;
 maxIndex = i;
 }
 }
 NSLog(@"Index: %d Max: %0.3f", maxIndex * 43, maxMag);
 
 */



/********************
 
 int fftRadix = log2(numSamples);
 int halfSamples = (int)(numSamples / 2);
 FFTSetup setup = vDSP_create_fftsetup(fftRadix, FFT_RADIX2);
 
 float *convertedSamples = malloc(numSamples * sizeof(float));
 
 vDSP_vflt16((short *)samples, 1, convertedSamples, 1, numSamples);
 
 DSPSplitComplex Observed;
 Observed.realp = malloc(halfSamples * sizeof(float));
 Observed.imagp = malloc(halfSamples * sizeof(float));
 
 vDSP_ctoz((DSPComplex *)samples, 2, &Observed, 1, halfSamples);
 
 vDSP_fft_zrip(setup, &Observed, 1, fftRadix, FFT_FORWARD);
 
 float max = 0.0;
 int maxIndex = 0;
 
 for (int i = 0; i < numSamples; i++)
 {
 float mag = (Observed.realp[i] * Observed.realp[i]) + (Observed.imagp[i] + Observed.imagp[i]);
 if (mag > max)
 {
 max = mag;
 maxIndex = i;
 }
 }
 
 //NSLog(@"Index: %d Max: %0.3f", maxIndex * 43, max);
 if (maxIndex > 0)
 {
 // NSLog(@"Char %c Index: %d", ((maxIndex - BASE)/STEP), maxIndex);
 }
 
 *******************/

