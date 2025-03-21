class Dist extends Event {
    float howClose;
}

public class Distancer {
    static Dist dist_event;

    fun static keyboard_listener() {
        KBHit kb;
        while( true )
        {
            kb => now;
            while( kb.more() )
            {
                kb.getchar() => int key;
                if (key >= 48 && key <= 57) { // 0-9 digits
                    key-48 => int digit_val;
                    if (digit_val == 0) {
                        10 => digit_val; // Hack
                    }
                    digit_val/10.0 => dist_event.howClose;
                    dist_event.broadcast();
                }
            }
        }
    }

    fun static osc_listener() {
        OscIn oin;
        OscMsg msg;
        7015 => oin.port;
        oin.addAddress( "/distance" );
        while( true )
        {
            oin => now;
            while( oin.recv(msg) ) {
                if( msg.typetag == "f" ) {
                    msg.getFloat(0) => dist_event.howClose;
                    dist_event.broadcast();
                }
            }
        }
    }

    fun static run() {
        // spork ~ keyboard_listener();
        spork ~ osc_listener();
    }
}
