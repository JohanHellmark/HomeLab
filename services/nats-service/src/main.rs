use std::{thread, time::Duration};
fn main() -> std::io::Result<()> {
    let nc = nats::connect("nats.nats.svc.cluster.local")?;

    // Using a threaded handler.
    nc.subscribe("bar")?.with_handler(move |msg| {
        println!("Received {}", &msg);
        Ok(())
    });
    loop {
        println!("Waiting for messages...");
        thread::sleep(Duration::from_secs(10));
    }
}
