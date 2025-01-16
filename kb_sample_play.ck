public class KbSamplePlay {
    static KBHit kb;

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
                Std.mtof(key) => float kfreq;
                key*1.0/255 => float krate;
                <<< "ascii: ", key, kfreq, krate >>>;
                krate => a_player.rate;
                // TODO add gate + envelope + loop a subsample section to play note from sample
            }
        }
    }
}