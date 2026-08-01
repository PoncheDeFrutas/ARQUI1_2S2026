"""Lección 01: distinguir una pulsación corta de una larga."""

import RPi.GPIO as GPIO
import time

BUTTON_PIN = 17
LED_PIN = 18
LONG_MS = 1500
DEBOUNCE_MS = 50

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(LED_PIN, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)


def now_ms():
    return time.time() * 1000


try:
    led_state = False
    press_start = None
    last_event = 0
    while True:
        level = GPIO.input(BUTTON_PIN)
        t = now_ms()

        if level == GPIO.LOW and press_start is None:
            # botón presionado
            if t - last_event > DEBOUNCE_MS:
                press_start = t
                last_event = t

        if level == GPIO.HIGH and press_start is not None:
            # botón liberado
            duration = t - press_start
            if duration >= LONG_MS:
                led_state = False
                GPIO.output(LED_PIN, led_state)
                print(f"Pulsación larga ({duration:.0f} ms) -> LED OFF")
            else:
                led_state = not led_state
                GPIO.output(LED_PIN, led_state)
                print(f"Pulsación corta ({duration:.0f} ms) -> LED {'ON' if led_state else 'OFF'}")
            press_start = None
            last_event = t

        time.sleep(0.02)
except KeyboardInterrupt:
    print("Saliendo...")
finally:
    GPIO.cleanup()
