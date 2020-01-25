// libsynth - Software synthesizer

use "list.eh"
use "dataio.eh"

// ADSR Status/phase
const ADSR_READY: Byte = 0
const ADSR_ATTACK: Byte = 1
const ADSR_DECAY: Byte = 2
const ADSR_SUSTAIN: Byte = 3
const ADSR_RELEASE: Byte = 4

// oscillator waveforms
const WAVE_SQUARE = 0
const WAVE_TRIANGLE = 1
const WAVE_SAW = 2
const WAVE_SINE = 3
const WAVE_ABSSINE = 4
const WAVE_NOISE = 5

type Oscillator {
    samplerate: Int = 0,
    bitdepth: Byte = 8,
    offset: Int = 0,
    frequency: Float = 0,
    cycle: Float = 0,
    cycle_counter: Float = 0,
    wave: Byte = 0,
    max_ampli: Int = 0,
    min_ampli: Int = 0,
    // square specific
    duty: Double = 0.5,
    // triangle specific
    halfcycle: Float = 0,
    // noise specific
    alternator: Int = 0,
    duty_counter: Int = 0 }

def Oscillator.new(sr: Int, bd: Byte, w: Byte);
def Oscillator.set_frequency(note: Float);
def Oscillator.get_data(): Int;


type Synth {
    source: Oscillator = null,
    attack: Double = 0,
    attack_samples: Int = 0,
    decay: Double = 0,
    decay_samples: Int = 0,
    sustain: Double = 0,
    release: Double = 0,
    release_samples: Int = 0,
    sustained: Bool = false,
    phase: Byte = 0,
    mastervolume: Double = 1.0,
    samplecounter: Int = 0,
    duty_sweep_enabled: Bool = false,
    duty_sweep_running: Bool = false,
    duty_sweep_counter: Int = 0,
    duty_sweep_len: Int = 0,
    duty_sweep_start_duty: Double = 0.5, 
    duty_sweep_end_duty: Double = 0.01 }

def Synth.new(source: Oscillator, a: Int, d: Int, s: Double, r: Int, sustained: Bool = false);
def Synth.set_duty_sweep(l: Int, start_duty: Double, end_duty: Double);
def Synth.set_adsr(a: Double, d: Double, s: Double, r: Double);
def Synth.attack_note(note: Float);
def Synth.off_note();
def Synth.get_data(): Int;


type Mixer {
    synths: List = null,
    kinds: List = null,
    count: Byte = 0,
    output: OStream = null,
    bitdepth: Byte = 0 }

def Mixer.new(path: String, sr: Int, bd: Byte, datasize: Long = null);
def Mixer.add_synth(s: Synth);
def Mixer.close();
def Mixer.write_data(samples: Int);

// easy list of piano note keys and equivalent frequency
const C8: Float = 4186.01

const B7: Float = 3951.07
const As7: Float = 3729.31
const A7: Float = 3520
const Gs7: Float = 3322.44
const G7: Float = 3135.96
const Fs7: Float = 2959.96
const F7: Float = 2793.83
const E7: Float = 2637.02
const Ds7: Float = 2489.02
const D7: Float = 2349.32
const Cs7: Float = 2217.46
const C7: Float = 2093.00

const B6: Float = 1975.53
const As6: Float = 1864.66
const A6: Float = 1760
const Gs6: Float = 1661.22
const G6: Float = 1567.98
const Fs6: Float = 1479.98
const F6: Float = 1396.91
const E6: Float = 1318.51
const Ds6: Float = 1244.51
const D6: Float = 1174.66
const Cs6: Float = 1108.73
const C6: Float = 1046.50

const B5: Float = 987.767
const As5: Float = 932.328
const A5: Float = 880
const Gs5: Float = 830.609
const G5: Float = 783.991
const Fs5: Float = 739.989
const F5: Float = 698.456
const E5: Float = 659.255
const Ds5: Float = 622.254
const D5: Float = 587.33
const Cs5: Float = 554.365
const C5: Float = 523.251

const B4: Float = 493.883
const As4: Float = 466.164
const A4: Float = 440
const Gs4: Float = 415.305
const G4: Float = 391.995
const Fs4: Float = 369.994
const F4: Float = 349.228
const E4: Float = 329.628
const Ds4: Float = 311.127
const D4: Float = 293.665
const Cs4: Float = 277.183
const C4: Float = 261.626

const B3: Float = 246.942
const As3: Float = 233.082
const A3: Float = 220
const Gs3: Float = 207.652
const G3: Float = 195.998
const Fs3: Float = 184.997
const F3: Float = 174.614
const E3: Float = 164.814
const Ds3: Float = 155.563
const D3: Float = 146.832
const Cs3: Float = 138.591
const C3: Float = 130.813

const B2: Float = 123.471
const As2: Float = 116.541
const A2: Float = 110
const Gs2: Float = 103.826
const G2: Float = 97.9989
const Fs2: Float = 92.4986
const F2: Float = 87.3071
const E2: Float = 82.4069
const Ds2: Float = 77.7817
const D2: Float = 73.4162
const Cs2: Float = 69.2957
const C2: Float = 65.4064

const B1: Float = 61.7354
const As1: Float = 58.2705
const A1: Float = 55
const Gs1: Float = 51.9131
const G1: Float = 48.9994
const Fs1: Float = 46.2493
const F1: Float = 43.6535
const E1: Float = 41.2034
const Ds1: Float = 38.8909
const D1: Float = 36.7081
const Cs1: Float = 34.6478
const C1: Float = 32.7032

const B0: Float = 30.8677
const As0: Float = 29.1352
const A0: Float = 27.5