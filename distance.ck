class Dist extends Event {
    int howClose;
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
                    digit_val => dist_event.howClose;
                    dist_event.broadcast();
                }
            }
        }
    }

    fun static run() {
        spork ~ keyboard_listener();
    }
}
