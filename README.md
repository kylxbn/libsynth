# libsynth
Software synthesizer for AlchemyOS

This is an Ether library for Alchemy OS that aims to provide a software synthesizer library for easily generating sounds and rendering them to WAV files.

This library provides generators for various waveforms including square waves, triangle waves, sawtooth and noise. Square wave duty cycle is customizable.
The generators have ADSR (attack / decay / sustain / release) customizability support built-in. Just set the ADSR values, and send note on events to the generators,
and it will generate sound for you.

It includes a built-in mixer so you can connect several generators to the mixer and get their outputs mixed into one bytestream. Writing directly into WAV files is
supported via [libraw2wav](https://github.com/kylxbn/libraw2wav).
