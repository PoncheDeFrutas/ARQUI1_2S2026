"""Lección 01: leer un botón con una interrupción por flanco."""

import RPi.GPIO as GPIO
import time

BUTTON_PIN = 17
LED_PIN = 18
BOUNCE_MS = 120

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(LED_PIN, GPIO.OUT, initial=GPIO.LOW)
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

led_state = False


def on_button(channel):
    global led_state
    led_state = not led_state
    GPIO.output(LED_PIN, led_state)
    print(f"Callback: LED {'ON' if led_state else 'OFF'}")


GPIO.add_event_detect(BUTTON_PIN, GPIO.FALLING, callback=on_button, bouncetime=BOUNCE_MS)

try:
    while True:
        time.sleep(0.1)  # bucle principal libre para otras tareas
except KeyboardInterrupt:
    print("Saliendo...")
finally:
    GPIO.cleanup()
