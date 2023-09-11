fn main() -> std::io::Result<()> {
    let nc = nats::connect("10.233.18.151")?;

    // Using a threaded handler.
    na.subscribe("bar")?.with_handler(move |msg| {
        println!("Received {}", &msg);
        Ok(())
    });
    Ok(())
}
