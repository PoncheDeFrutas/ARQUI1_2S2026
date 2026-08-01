"""Lección 01: leer un botón por sondeo con debounce."""

import RPi.GPIO as GPIO
import time

BUTTON_PIN = 17
LED_PIN = 18
DEBOUNCE_MS = 200  # tiempo mínimo entre pulsos válidos

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(LED_PIN, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

def now_ms():
    return time.time() * 1000

try:
    led_state = False
    last_press = 0
    while True:
        if GPIO.input(BUTTON_PIN) == GPIO.LOW:  # activo en LOW por pull-up
            t = now_ms()
            if t - last_press > DEBOUNCE_MS:
                led_state = not led_state
                GPIO.output(LED_PIN, led_state)
                print(f"Botón detectado. LED {'ON' if led_state else 'OFF'}")
                last_press = t
        time.sleep(0.02)  # reduce CPU y ayuda al debounce
except KeyboardInterrupt:
    print("Saliendo...")
finally:
    GPIO.cleanup()
