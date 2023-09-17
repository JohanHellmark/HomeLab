use log::{error, info, Level};
use opentelemetry::KeyValue;
use opentelemetry_appender_log::OpenTelemetryLogBridge;
use opentelemetry_sdk::logs::{Config, LoggerProvider};
use opentelemetry_sdk::Resource;
use std::{convert::Infallible, net::SocketAddr};

fn main() -> std::io::Result<()> {
    let nc = nats::connect("nats.nats.svc.cluster.local")?;
    let exporter = opentelemetry_stdout::LogExporterBuilder::default()
        // uncomment the below lines to pretty print output.
        // .with_encoder(|writer, data|
        //    Ok(serde_json::to_writer_pretty(writer, &data).unwrap()))
        .build();
    let logger_provider = LoggerProvider::builder()
        .with_config(
            Config::default().with_resource(Resource::new(vec![KeyValue::new(
                "test-service",
                "logs-basic-example",
            )])),
        )
        .with_simple_exporter(exporter)
        .build();

    // Setup Log Appender for the log crate.
    let otel_log_appender = OpenTelemetryLogBridge::new(&logger_provider);
    log::set_boxed_logger(Box::new(otel_log_appender)).unwrap();
    log::set_max_level(Level::Info.to_level_filter());
    // Using a threaded handler.
    nc.subscribe("bar")?.with_handler(move |msg| {
        info!("Received {}", &msg);
        Ok(())
    });

    loop {
        info!("Waiting for messages...");
        thread::sleep(Duration::from_secs(10));
    }
}
