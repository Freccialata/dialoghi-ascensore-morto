@import "distance.ck"
@import "ascensori.ck"

class RandomRuntime {
    fun random_sample_choice() {
        while (true) {
            Math.random2f(10, 30)::second => now;
            if (Math.randomf() > 0.55) {
                a.stop_playing(a.curr_choice);
                a.play_sample(Math.random2(0, 3), 0);
                // <<<"Change to:", a.curr_choice>>>;
            }
        }
    }
    fun random_noise() {
        Noise nn => Pan2 n;
        .005 => n.gain;
        while (true) {
            Math.random2f(100, 450)::ms => dur loop_t;
            Math.random2f(-.3, .3) => n.pan;
            n => dac;
            loop_t => now;
            n =< dac;
            loop_t => now;
        }
    }
    fun kf_sweep() {
        800 => int min_freq;
        8000 => int max_freq;
        min_freq => float x;
        0 => int swap;
        while (true) {
            x => a.kf.freq;
            0.2::ms => now;
            if (swap) {
                1/1.0003 *=> x;
            } else {
                1.0003 *=> x;
            }
            if (x < min_freq) {
                0 => swap;
            } else if (x > max_freq) {
                1 => swap;
            }
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
// spork ~ r.kf_sweep();

// spork ~ a.play_sample(1, 0);
spork ~ a.play_sample(0, 0);
while(true) {
    Distancer.dist_event => now;
    (Distancer.dist_event.howClose/10.0)*2 => float norm_dist;
    <<<norm_dist, "">>>;
    a.change_rate(a.curr_choice, norm_dist);
}
