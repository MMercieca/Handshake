## Intro

A hackathon project trying to exchange information between devices with an ultrasonic tone.

I read that the [Chromecast used ultrasonic pairing to connect with devices not on the same wi-fi network](https://www.engadget.com/2014-06-27-chromecast-ultrasonic-pairing.html).
This was my attempt at getting two iOS devices to exhcange a short string of information.

## Challenges

1. Getting an iOS device to play a pure ultrasonic tone

iOS doesn't have a `beep` command like Basic and Pascal did.  To play a pure sine wave you have to write a pure sine wave directly to the autio device.
I had some trouble remembering my physics and the cats were not happy with the experiments.  Eventually I found what worked.

I could have created the sine waves as MP3s or another audio file and played just the right ones, but I wanted more flexability in the values I chose.  Also
that kind of felt like cheating and I wouldn't have leared as much.

2. Getting the tonal value of a sine wave.

I never had a reason to need a Fast Fourier Transform (FFT).  Fortunately there is an iOS library that makes this relatively easy, but learning the math behind it and why it worked
was a return to school.
