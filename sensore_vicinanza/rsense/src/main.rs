use std::error::Error;
use std::thread;
use std::time::{Duration, Instant};
use std::net::UdpSocket;

use rppal::gpio::{Gpio, InputPin, OutputPin};
use rosc::{OscMessage, OscPacket, OscType};
use circular_buffer::CircularBuffer;

// Gpio uses BCM pin numbering
const GPIO_TRIGGER: u8 = 22;
const GPIO_ECHO: u8 = 27;
const WINDOW_SIZE: usize = 25;
const THRESHOLD: usize = 200;
const START_MAX: f32 = 700.0;

struct MovingMax {
    window: CircularBuffer<WINDOW_SIZE, f32>,
    moving_max: f32,
}

impl MovingMax {
    fn new() -> Self {
        MovingMax {
            window: CircularBuffer::<WINDOW_SIZE, f32>::new(),
            moving_max: START_MAX,
        }
    }

    fn calc_moving_max(&mut self, val: f32) -> f32 {
        if val < THRESHOLD as f32 {
            return self.moving_max;
        }
        self.window.push_back(val);
        if self.window.len() >= WINDOW_SIZE {
            self.moving_max = self.window.iter().fold(f32::NEG_INFINITY, |max, &val| max.max(val));
        }
        return self.moving_max
    }
}


fn main() -> Result<(), Box<dyn Error>> {
    let mut pin_trig = Gpio::new()?.get(GPIO_TRIGGER)?.into_output();
    let pin_echo = Gpio::new()?.get(GPIO_ECHO)?.into_input();

    let mut mov_max = MovingMax::new();

    let to_address: &str = "127.0.0.1:7015";
    let socket = UdpSocket::bind("0.0.0.0:0").expect("couldn't bind to socket address");

    loop {
        let distance = get_distance(&mut pin_trig, &pin_echo);
        let curr_max = mov_max.calc_moving_max(distance);
        let norm_distance = distance / curr_max;
        let osc_bytes = rosc::encoder::encode(&OscPacket::Message(OscMessage {
            addr: "/distance".into(),
            args: vec![OscType::Float(norm_distance.clamp(0.0, 1.0))],
        }))
        .unwrap();
        // println!("{:.2} | {:.2} | {}", distance, norm_distance, curr_max);
        socket
            .send_to(&osc_bytes, to_address)
            .expect("couldn't send data");
        thread::sleep(Duration::from_millis(10));
    }
}

fn get_distance(pin_trig: &mut OutputPin, pin_echo: &InputPin) -> f32 {
    // # set Trigger to HIGH
    pin_trig.set_high();

    // # set Trigger after 0.01ms to LOW
    thread::sleep(Duration::from_nanos(1));
    pin_trig.set_low();

    let mut start_time = Instant::now();
    let mut stop_time = Instant::now();

    while pin_echo.is_low() {
        start_time = Instant::now();
    }
    while pin_echo.is_high() {
        stop_time = Instant::now();
    }

    // # time difference between start and arrival
    let time_elapsed = stop_time.duration_since(start_time).as_secs_f64();
    // # multiply with the sonic speed (34300 cm/s)
    // # and divide by 2, because there and back
    (time_elapsed as f32 * 34300.0) / 2.0
}
