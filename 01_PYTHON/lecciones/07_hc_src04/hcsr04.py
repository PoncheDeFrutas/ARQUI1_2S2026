import time
import statistics

import RPi.GPIO as GPIO


class HCSR04:
    SPEED_OF_SOUND = 34300  # cm/s

    def __init__(
        self,
        trig_pin: int,
        echo_pin: int,
        timeout: float = 0.02,
    ):
        self.trig_pin = trig_pin
        self.echo_pin = echo_pin
        self.timeout = timeout

        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)

        GPIO.setup(self.trig_pin, GPIO.OUT)
        GPIO.setup(self.echo_pin, GPIO.IN)

        GPIO.output(self.trig_pin, GPIO.LOW)

    def distance(self) -> float | None:
        # Pulso TRIG de 10 us
        GPIO.output(self.trig_pin, GPIO.LOW)
        time.sleep(0.0002)

        GPIO.output(self.trig_pin, GPIO.HIGH)
        time.sleep(0.00001)

        GPIO.output(self.trig_pin, GPIO.LOW)

        start = time.monotonic()

        # Esperar inicio del pulso ECHO
        while GPIO.input(self.echo_pin) == GPIO.LOW:
            if time.monotonic() - start > self.timeout:
                return None

        pulse_start = time.monotonic()

        # Esperar fin del pulso ECHO
        while GPIO.input(self.echo_pin) == GPIO.HIGH:
            if time.monotonic() - pulse_start > self.timeout:
                return None

        pulse_end = time.monotonic()

        duration = pulse_end - pulse_start

        return (duration * self.SPEED_OF_SOUND) / 2

    def median(self, samples: int = 5) -> float | None:
        values = []

        for _ in range(samples):
            value = self.distance()

            if value is not None:
                values.append(value)

            time.sleep(0.05)

        if not values:
            return None

        return statistics.median(values)

    def cleanup(self):
        GPIO.cleanup()
