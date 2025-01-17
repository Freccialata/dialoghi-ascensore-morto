@import "ramp_rate.ck"
@import "kb_sample_play.ck"

[me.dir() + "wav/ascensore-1.wav",
me.dir() + "wav/ascensore-2.wav",
me.dir() + "wav/ascensore-3.wav",
me.dir() + "wav/ascensore-4.wav"] @=> string files_ascensori[];

SndBuf2 ascensori[files_ascensori.size()];
for(int i : Std.range(files_ascensori.size())) {
    files_ascensori[i] => ascensori[i].read;
    if( !ascensori[i].ready() ) {
        <<<"Error opening file", files_ascensori[i]>>>;
        me.exit();
    }
    .4 => ascensori[i].gain;
    1 => ascensori[i].loop;
}

RampRate.key_listener_loop(ascensori);
// KbSamplePlay.key_listener_loop(ascensori);
