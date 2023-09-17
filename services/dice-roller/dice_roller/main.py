import time
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import ConsoleSpanExporter, BatchSpanProcessor
from opentelemetry.sdk.resources import SERVICE_NAME, Resource

import random


# Service name is required for most backends,
# and although it's not necessary for console export,
# it's good to set service name anyways.
resource = Resource(attributes={
    SERVICE_NAME: "your-service-name"
})

provider = TracerProvider(resource=resource)
processor = BatchSpanProcessor(ConsoleSpanExporter())
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

def do_roll():
    tracer = trace.get_tracer("my.tracer")
    while True: 
        with tracer.start_as_current_span("do_roll") as rollspan:
            res = random.randint(1, 6)
            rollspan.set_attribute("roll.value", res)
        time.sleep(2)

if __name__ == "__main__":
    do_roll()