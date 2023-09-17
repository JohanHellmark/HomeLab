import time
from opentelemetry import trace
import random

tracer = trace.get_tracer("diceroller.tracer")

def do_roll():
    while True: 
        with tracer.start_as_current_span("do_roll") as rollspan:
            res = random.randint(1, 6)
            rollspan.set_attribute("roll.value", res)
        time.sleep(10)

if __name__ == "__main__":
    do_roll()