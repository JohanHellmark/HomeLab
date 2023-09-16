use std::io;
use std::{thread, time::Duration};

fn main() -> io::Result<()> {
    println!("Hello, world!");
    let nc = nats::connect("10.233.18.151")?;
    let mut counter: i32 = 0;
    loop {
        counter = counter + 1;
        thread::sleep(Duration::from_secs(10));
        nc.publish("bar", format!("Sending You A Message: {}", counter))?;
        println!("{}", counter)
    }
}
