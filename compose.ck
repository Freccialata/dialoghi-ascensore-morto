@import "distance.ck"
@import "ascensori.ck"

WvOut2 wave;
0 => int do_record;
if( me.args() ) me.arg(0) => Std.atoi => do_record;
if (do_record) {
    dac => wave => blackhole;
    "ascensor_" + do_record + ".wav" => string file_name;
    <<<"Recording to", file_name>>>;
    file_name => wave.wavFilename;
}

Spectacle spect;
.5 => spect.mix;
spect.range(100,4100);
20 => spect.bands;
0.3 => spect.feedback;
// MAIN chain
Pan2 my_dac => spect => dac;

class RandomRuntime {
    1 => float duration_modifier;
    [0.1, 0.2] @=> float low_range[];
    [1.1, 1.3] @=> float high_range[];

    fun random_sample_choice() {
        while (true) {
            if (Math.randomf() > 0.55) {
                a.stop_playing(a.curr_choice, my_dac);
                a.play_sample(Math.random2(0, 3), 0, my_dac);
                // <<<"Change to:", a.curr_choice>>>;
            }
            Math.random2f(10, 30)::second => now;
        }
    }
    fun random_noise() {
        Noise nn => Multicomb comb => ADSR env(5::ms, 5::ms, .8, 5::ms) => Pan2 n => my_dac;
        250::ms => comb.revtime;
        comb.set(90,680);
        .004 => n.gain;
        while (true) {
            Math.random2f(300, 800)::ms*duration_modifier => dur loop_t;
            Math.random2f(-.8, .8) => n.pan;
            comb.set(Math.random2(80, 200),Math.random2(600, 740));
            env.keyOn();
            loop_t => now;
            env.keyOff();
            loop_t => now;
        }
    }
    fun change_scramble_ranges() {
        [
            [0.1, 0.2],
            [0.3, 0.4],
            [0.4, 0.5]
        ] @=> float low_couples[][];
        [
            [0.65, 0.75],
            [0.8, 1],
            [1.1, 1.2]
        ] @=> float high_couples[][];
        while (true) {
            Math.random2(20, 30)::second => now;
            low_couples[Math.random2(0, low_couples.size()-1)] @=> low_range;
            high_couples[Math.random2(0, high_couples.size()-1)] @=> high_range;
        }
    }
    fun rate_scrambler() {
        0 => int idx;
        while (true) {
            if (idx == 0) {
                a.change_rate(a.curr_choice, Math.random2f(low_range[0], low_range[1]));
            } else if (idx == 1) {
                a.change_rate(a.curr_choice, Math.random2f(high_range[0], high_range[1]));
            } else {
                <<< "Warning idx", idx, "is not 0 or 1" >>>;
            }
            (idx + 1)%2 => idx;
            2::second*duration_modifier => now;
        }
    }
}

[me.dir() + "wav/ascensore-1.wav",
me.dir() + "wav/ascensore-2.wav",
me.dir() + "wav/ascensore-3.wav",
me.dir() + "wav/ascensore-4.wav"] @=> string files_ascensori[];

Ascensori a(files_ascensori);
Distancer.run();

RandomRuntime r;
spork ~ r.random_sample_choice();
spork ~ r.random_noise();
spork ~ r.rate_scrambler();
spork ~ r.change_scramble_ranges();

spork ~ a.play_sample(0, 0, my_dac);
while(true) {
    Distancer.dist_event => now;
    (Distancer.dist_event.howClose/10.0) => float norm_dist;
    <<<norm_dist, "">>>;
    norm_dist => r.duration_modifier;
}