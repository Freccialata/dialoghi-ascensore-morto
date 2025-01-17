public class RampRate {
    static KBHit kb;

    0 => static int ramp_instance;
    fun static ramp_rate(float new_rate, SndBuf2 a_player) {
        // ramp up/down to new rate, re-start ramping after each rate change
        ramp_instance + 1 => ramp_instance;
        10::ms => dur ramp_velocity;
        0.001 => float ramp_step;
        a_player.rate() => float last_rate;
        // <<<"new rate:", new_rate>>>;
        if (new_rate <= last_rate) { // ramp down
            while (a_player.rate() >= new_rate) {
                a_player.rate() - ramp_step => a_player.rate;
                ramp_velocity => now;
                if (ramp_instance > 1) {
                    break;
                }
            }
        }
        if (new_rate >= last_rate) { // ramp up
            while (a_player.rate() <= new_rate) {
                a_player.rate() + ramp_step => a_player.rate;
                ramp_velocity => now;
                if (ramp_instance > 1) {
                    break;
                }
            }
        }
        ramp_instance - 1 => ramp_instance;
        // <<<"ramped rate:", a_player.rate()>>>;
    }

    0 => static int loop_instance;
    0 => static int loop_stop;
    fun static loop_section(int new_pos, dur sec_dur, SndBuf2 @ a_player) {
        <<<"Loop!", new_pos*1.0/a_player.samples(), sec_dur/1::second>>>;
        1 +=> loop_instance;
        0 => loop_stop;
        while (loop_stop != 1) {
            new_pos => a_player.pos;
            sec_dur => now;
            if (loop_instance != 1) {
                break;
            }
        }
        1 -=> loop_instance;
        <<<"Stop!", new_pos*1.0/a_player.samples(), sec_dur/1::second, "INSTANCE", loop_instance>>>;
    }

    fun static key_listener_loop(SndBuf2 ascensori[]) {
        0 => int curr_file;
        ascensori[curr_file] @=> SndBuf2 @ a_player;
        a_player => dac;
        0 => int mode;
        0 => float offset;
        500::ms => dur sec_dur;
        0 => int new_pos;
        Std.ftoi(a_player.samples()*.9) => a_player.pos;
        while( true )
        {
            kb => now;
            while( kb.more() )
            {
                kb.getchar() => int key;
                // <<< "ascii: ", key >>>;
                if (key >= 48 && key <= 57) { // 0-9 digits
                    key-48 => int digit_val;
                    if (mode == 0) {
                        (digit_val / 10.0)+offset => float new_rate;
                        spork ~ ramp_rate(new_rate, a_player);
                    } else if (mode == 1) {
                        Std.ftoi(a_player.samples() * (digit_val / 10.0)) => new_pos;
                        spork ~ loop_section(new_pos, sec_dur, a_player);
                    }
                    else if (mode == 2) {
                        digit_val*100::ms + offset::second => sec_dur;
                        spork ~ loop_section(new_pos, sec_dur, a_player);
                    }
                } else if (key == 43) { // + key
                    1 => offset;
                } else if (key == 45) { // - key
                    0 => offset;
                } else if (key == 109) { // m for 'mode' switch
                    (mode+1)%3 => mode;
                    <<<"mode", mode>>>;
                } else if (key == 99) { // c for 'continue' -> stop loop_section
                    1 => loop_stop;
                } else if (key == 110) { // n for 'next'
                    a_player.pos()*1.0 / a_player.samples() => float relative_pos;
                    a_player =< dac;
                    (curr_file + 1) % ascensori.size() => curr_file;
                    ascensori[curr_file] @=> a_player;
                    a_player => dac;
                    <<<curr_file, relative_pos>>>;
                    Std.ftoi(a_player.samples()*relative_pos) => a_player.pos;
                }
            }
        }
    }
}