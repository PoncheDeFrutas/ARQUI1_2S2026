"""Lección 02: generar tonos con PWM en un buzzer pasivo."""

import RPi.GPIO as GPIO
import time

BUZZER_PIN = 12

# Frecuencias de ejemplo (Hz)
TONES = [262, 330, 392, 523]  # do, mi, sol, do
DURATION = 0.5                # segundos por tono

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(BUZZER_PIN, GPIO.OUT)

pwm = GPIO.PWM(BUZZER_PIN, TONES[0])
pwm.start(50)  # duty 50% para buzzer pasivo

try:
    while True:
        for f in TONES:
            pwm.ChangeFrequency(f)
            print(f"Tono: {f} Hz")
            time.sleep(DURATION)
except KeyboardInterrupt:
    print("Saliendo...")
finally:
    pwm.stop()
    GPIO.cleanup()
