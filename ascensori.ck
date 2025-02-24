public class Ascensori {
    SndBuf2 ascensori[4];
    ADSR env(400::ms, 400::ms, .8, 100::ms)[4];
    Event playOff;
    int curr_choice;

    Spectacle spect;
    .5 => spect.mix;
    spect.range(100,4100);
    20 => spect.bands;
    0.3 => spect.feedback;
    KasFilter kf;
    .9 => kf.gain;
    .2 => kf.resonance;
    .3 => kf.accent;
    5000 => kf.freq;

    fun @construct(string @ files_ascensori[]) {
        for(int i : Std.range(files_ascensori.size())) {
            files_ascensori[i] => ascensori[i].read;
            if( !ascensori[i].ready() ) {
                <<<"Error opening file", files_ascensori[i]>>>;
                me.exit();
            }
            .8 => ascensori[i].gain;
            1 => ascensori[i].loop;
        }
    }

    fun play_sample(int choice, float pos_percent) {
        if (choice < 0 || choice > 3) {
            <<<"Cannot select sample number", choice>>>;
            return;
        }
        if (pos_percent < 0 || pos_percent > 1) {
            <<<pos_percent, "is not a position percentage between 0 and 1">>>;
            return;
        }
        choice => curr_choice;
        Std.ftoi(ascensori[choice].samples()*pos_percent) => ascensori[choice].pos;
        ascensori[choice] => env[choice] => kf => dac;
        // ascensori[choice] => env[choice] => spect => kf => dac;
        env[choice].keyOn();
        env[choice].attackTime()+env[choice].decayTime() => now;
    }

    fun stop_playing(int choice) {
        if (choice < 0 || choice > 3) {
            <<<"Cannot stop sample number", choice>>>;
            return;
        }
        env[choice].keyOff();
        env[choice].releaseTime() => now;
        ascensori[choice] =< env[choice] =< kf =< dac;
        // ascensori[choice] =< env[choice] =< spect =< kf =< dac;
    }

    fun change_rate(int choice, float new_rate) {
        if (choice < 0 || choice > 3) {
            <<<"Cannot change rate for number", choice>>>;
            return;
        }
        new_rate => ascensori[choice].rate;
    }
}
