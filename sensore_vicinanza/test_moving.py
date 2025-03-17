import sys
from random import randrange
from time import sleep, time
from math import sin
from moving import MovingMax

def new_max():
    return randrange(500, 1100)

def get_ramp(curr_max, elapsed):
    return curr_max*.5*(sin(elapsed)+1)

def main():
    mover = MovingMax()
    t_start = time()
    curr_max = 700
    triggered = False
    print("elapsed;curr_max;moving_max;delta_max;val;real_norm_val;norm_val") # routable to > data.csv
    while True:
        elapsed = time() - t_start
        if int(elapsed) % 3 == 0 and not triggered: # new max every 3 seconds
            curr_max = new_max()
            triggered = True
        else:
            triggered = False
        val = get_ramp(curr_max, elapsed)
        moving_max = mover.calc_moving_max(val)
        norm_val = round(val/moving_max, 3)
        real_norm_val = round(val/curr_max, 3)
        print(int(elapsed), ";", curr_max, ";", moving_max, ";", abs(curr_max-moving_max), ";", val, ";", real_norm_val, ";", norm_val)
        if elapsed > 20: # Run for 20 seconds
            return
        sleep(.01)


if __name__ == "__main__":
    main()
