use std::{thread, time::Duration};

fn main() -> std::io::Result<()> {
    let nc = nats::connect("10.233.18.151")?;

    // Using a threaded handler.
    nc.subscribe("bar")?.with_handler(move |msg| {
        println!("Received {}", &msg);
        Ok(())
    });
    thread::sleep(Duration::from_secs(5 * 60));
    Ok(())
}
