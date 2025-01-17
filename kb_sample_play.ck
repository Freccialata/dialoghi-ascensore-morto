public class KbSamplePlay {

    fun static key_listener_loop(SndBuf2 ascensori[]) {
        0 => int curr_file;
        ascensori[curr_file] @=> SndBuf2 @ a_player;

        Hid kb;
        HidMsg msg;
        MultiKeyPress m;
        if( !kb.openKeyboard(0) ) me.exit();
        <<< "keyboard '" + kb.name() + "' ready", "" >>>;
        while( true )
        {
            kb => now;
            while( kb.recv( msg ) )
            {
                if (msg.isButtonDown()) {
                    msg.which => int key;
                    if (m.is_pressed(key) == 1) {
                        continue;
                    }
                    Std.mtof( msg.which + 45 ) => float kfreq;
                    SampleAsNote sn(key, kfreq);
                    m.append(sn);
                    spork ~ sn.play_sin();
                    80::ms => now;
                } else if (msg.isButtonUp()) {
                    msg.which => int key;
                    m.remove(key);
                }
            }
        }
    }
}

class SampleAsNote {
    int key;
    float freq;
    Event playOff;

    fun @construct(int ikey, float ifreq) {
        ikey => key;
        ifreq => freq;
    }

    fun play_sin() {
        SinOsc sin_player(freq) => ADSR env => dac;
        .12 => sin_player.gain;
        env.keyOn();
        while (true) {
            env.releaseTime()+env.attackTime() => now;
            playOff => now;
            env.keyOff();
        }
        sin_player =< env =< dac;
        <<<"Stopped">>>;
    }

    fun play_sample(SndBuf2 @ a_player) {
        a_player => ADSR env => dac;
        // TODO implement multi sample playing
        // kfreq*init_freq => a_player.rate;
        // Std.ftoi(a_player.samples()*.22) => a_player.pos;
        env.keyOn();
        while (true) {
            env.releaseTime()+env.attackTime() => now;
            playOff => now;
            env.keyOff();
        }
        a_player =< env =< dac;
        <<<"Stopped">>>;
    }
}

class MultiKeyPress {
    SampleAsNote sn_keys[0];

    fun int is_pressed(int key) {
        for( SampleAsNote playing_sn : sn_keys ) {
            if (playing_sn.key == key) {
                return 1;
            }
        }
        return 0;
    }

    fun append(SampleAsNote sn) {
        sn_keys << sn;
    }

    fun remove(int the_key) {
        for( 0 => int i; i < sn_keys.size(); i++ ) {
            if (sn_keys[i].key == the_key) {
                sn_keys[i].playOff.signal();
                sn_keys.popOut(i);
            }
        }
    }
}
