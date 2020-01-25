// libsynth - Software synthesizer

use "list.eh"
use "rnd.eh"
use "math.eh"

use "synth.eh"
use "dataio.eh"
use "raw2wav.eh"

def linear_approximate(now_a: Double, min_a: Double, max_a: Double, min_b: Double, max_b: Double): Double {
    ((now_a - min_a) * (max_b - min_b)) / (max_a - min_a) + min_b }

def Oscillator.new(sr: Int, bd: Byte, w: Byte) {
    this.samplerate = sr
    this.bitdepth = bd
    if (this.bitdepth == 8) {
        this.max_ampli = 255
        this.min_ampli = 0
        this.offset = 0x80 }
    else if (this.bitdepth == 16) {
        this.max_ampli = 32767
        this.min_ampli = -32768
        this.offset = 0 }
    else { // INVALID BITDEPTH!!!
        this = null }
    this.cycle = 300
    this.wave = w
    // square specific
    this.duty = 0.5
    // triangle specific
    this.halfcycle = 150
    // noise specific
    this.alternator = 0
    this.duty_counter = -1 }

def Oscillator.set_frequency(note: Float) {
    this.cycle_counter = (this.cycle_counter * (this.samplerate/note)) / this.cycle
    this.cycle = this.samplerate / note
    this.halfcycle = this.cycle / 2.0 }

def Oscillator.get_data(): Int {
    var data: Int = 0
    switch (this.wave) {
        WAVE_SQUARE: {
            if (this.cycle_counter > (this.cycle * this.duty)) data = this.max_ampli - this.offset else data = this.min_ampli - this.offset }
        WAVE_TRIANGLE: {
            if (this.cycle_counter < this.halfcycle)
                data = linear_approximate(this.cycle_counter, 0, this.halfcycle, this.min_ampli, this.max_ampli) - this.offset
            else
                data = linear_approximate(this.cycle_counter, this.halfcycle, this.cycle, this.max_ampli, this.min_ampli) - this.offset }
        WAVE_SAW: {
            data = linear_approximate(this.cycle_counter, 0, this.cycle, this.max_ampli, this.min_ampli) - this.offset }
        WAVE_SINE: {
            data = linear_approximate(sin(deg2rad(linear_approximate(this.cycle_counter, 0, this.cycle, 0, 359))), -1, 1, this.min_ampli, this.max_ampli) - this.offset }
        WAVE_ABSSINE: {
            data = linear_approximate(sin(deg2rad(linear_approximate(this.cycle_counter, 0, this.cycle, 0, 179))), -0, 1, this.min_ampli, this.max_ampli) - this.offset }
        WAVE_NOISE: {
            this.duty_counter -= 1
            if (this.duty_counter < 0) {
                if (this.alternator == this.max_ampli) this.alternator = this.min_ampli - this.offset else this.alternator = this.max_ampli - this.offset
                this.duty_counter = abs(rnd(this.frequency.cast(Int))) }
            data = this.alternator - this.offset } }
    this.cycle_counter += 1
    if (this.cycle_counter > this.cycle) this.cycle_counter = 0
    data }

def Synth.new(source: Oscillator, a: Int, d: Int, s: Double, r: Int, sustained: Bool = false) {
    this.source = source
    this.set_adsr(a, d, s, r)
    this.sustained = sustained
    this.phase = ADSR_READY
    this.mastervolume = 1.0
    this.samplecounter = 0 }

def Synth.set_adsr(a: Double, d: Double, s: Double, r: Double) {
    this.attack = a
    this.attack_samples = a * this.source.samplerate
    this.decay = d * this.source.samplerate
    this.sustain = s
    this.release = r * this.source.samplerate }

def Synth.set_duty_sweep(l: Int, start_duty: Double, end_duty: Double) {
    this.duty_sweep_len = l
    this.duty_sweep_start_duty = start_duty
    this.duty_sweep_end_duty = end_duty
    this.duty_sweep_counter = 0 }

def Synth.attack_note(note: Float) {
    this.source.set_frequency(note)
    this.phase = ADSR_ATTACK
    this.samplecounter = 0
    this.duty_sweep_counter = 0
    this.duty_sweep_running = this.duty_sweep_enabled }

def Synth.slide_note(note: Float) {
    this.source.frequency = note }

def Synth.off_note() {
    this.phase = ADSR_RELEASE }

def Synth.get_data(): Int {
    var data: Int = 0
    if (this.duty_sweep_enabled) {
        this.source.duty = linear_approximate(this.duty_sweep_counter, 0, this.duty_sweep_len, this.duty_sweep_start_duty, this.duty_sweep_end_duty)
        this.duty_sweep_counter += 1
        if (this.duty_sweep_counter > this.duty_sweep_len) this.duty_sweep_counter -= 1 }
    switch (this.phase) {
        ADSR_READY: {
            data = 0 }
        ADSR_ATTACK: {
            data = this.source.data * linear_approximate(this.samplecounter, 0, this.attack, 0.0, 1.0)
            this.samplecounter += 1
            if (this.samplecounter >= this.attack) {
                this.samplecounter = 0
                this.phase = ADSR_DECAY } }
        ADSR_DECAY: {
            data = this.source.data * linear_approximate(this.samplecounter, 0, this.decay, 1, this.sustain)
            this.samplecounter += 1
            if (this.samplecounter >= this.decay) {
                this.samplecounter = 0
                if (this.sustained) this.phase = ADSR_SUSTAIN else this.phase = ADSR_RELEASE } }
        ADSR_SUSTAIN: {
            data = this.source.data * this.sustain }
        ADSR_RELEASE: {
            data = this.source.data * linear_approximate(this.samplecounter, 0, this.release, this.sustain, 0)
            this.samplecounter += 1
            if (this.samplecounter >= this.release) {
                this.phase = ADSR_READY } } }
    data * this.mastervolume + this.source.offset }


def Mixer.new(path: String, sr: Int, bd: Byte, datasize: Long = null) {
    this.synths = new List()
    this.count = 0
    this.bitdepth = bd
    if (datasize == null) {
        this.output = fopen_w(path) }
    else {
        if (bd == 16) datasize *= 2
        this.output = stream2wav(path, 1, sr, bd, datasize) } }

def Mixer.add_synth(s: Synth) {
    this.synths.add(s)
    this.count += 1 }

def Mixer.close() {
    this.output.flush()
    this.output.close()
    this = null }

def Mixer.write_data(samples: Int) {
    var r: Long = 0
    for (var n=0, n<samples, n+=1) {
        r = 0
        for (var i=0, i<this.count, i+=1) {
            r += this.synths[i].cast(Synth).data }
        r /= this.count
        if (this.bitdepth == 8)
            this.output.writebyte(r)
        else if (this.bitdepth == 16) {
            this.output.writebyte(r)
            this.output.writebyte(r >> 8) } } }