import time

import RPi.GPIO as GPIO


class HCSR04:
    SPEED_OF_SOUND = 34300

    def __init__(self, trig_pin: int, echo_pin: int):
        self.trig_pin = trig_pin
        self.echo_pin = echo_pin

        GPIO.setmode(GPIO.BCM)
        GPIO.setwarnings(False)

        GPIO.setup(trig_pin, GPIO.OUT)
        GPIO.setup(echo_pin, GPIO.IN)

    def read(self) -> float | None:
        GPIO.output(self.trig_pin, GPIO.LOW)
        time.sleep(0.0002)

        GPIO.output(self.trig_pin, GPIO.HIGH)
        time.sleep(0.00001)
        GPIO.output(self.trig_pin, GPIO.LOW)

        timeout = time.monotonic() + 0.02

        while GPIO.input(self.echo_pin) == GPIO.LOW:
            if time.monotonic() > timeout:
                return None

        start = time.monotonic()

        while GPIO.input(self.echo_pin) == GPIO.HIGH:
            if time.monotonic() > timeout:
                return None

        end = time.monotonic()

        return (end - start) * self.SPEED_OF_SOUND / 2

    def cleanup(self):
        GPIO.cleanup()
