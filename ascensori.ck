public class Ascensori {
    SndBuf2 ascensori[4];
    ADSR env(400::ms, 400::ms, .8, 100::ms)[4];
    Event playOff;
    int curr_choice;

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

    fun play_sample(int choice, float pos_percent, Pan2 my_dac) {
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
        ascensori[choice] => env[choice] => my_dac;
        env[choice].keyOn();
        env[choice].attackTime()+env[choice].decayTime() => now;
    }

    fun stop_playing(int choice, Pan2 my_dac) {
        if (choice < 0 || choice > 3) {
            <<<"Cannot stop sample number", choice>>>;
            return;
        }
        env[choice].keyOff();
        env[choice].releaseTime() => now;
        ascensori[choice] =< env[choice] =< my_dac;
    }

    fun change_rate(int choice, float new_rate) {
        if (choice < 0 || choice > 3) {
            <<<"Cannot change rate for number", choice>>>;
            return;
        }
        new_rate => ascensori[choice].rate;
    }
}
