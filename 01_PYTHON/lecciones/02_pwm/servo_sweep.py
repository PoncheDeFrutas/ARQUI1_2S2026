"""Lección 02: mover un servo mediante PWM."""

import RPi.GPIO as GPIO
import time

SERVO_PIN = 12   # usar pin con PWM hardware; 18 también funciona
FREQ_HZ = 50     # frecuencia típica de servos

# Duty aproximado para servos comunes (ajusta según tu modelo)
DUTY_MIN = 2.5   # ~0°
DUTY_MAX = 12.5  # ~180°
STEP = 0.5
DELAY = 0.05

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(SERVO_PIN, GPIO.OUT)

pwm = GPIO.PWM(SERVO_PIN, FREQ_HZ)
pwm.start(DUTY_MIN)


def sweep():
    # 0° -> 180°
    duty = DUTY_MIN
    while duty <= DUTY_MAX:
        pwm.ChangeDutyCycle(duty)
        time.sleep(DELAY)
        duty += STEP
    # 180° -> 0°
    duty = DUTY_MAX
    while duty >= DUTY_MIN:
        pwm.ChangeDutyCycle(duty)
        time.sleep(DELAY)
        duty -= STEP


try:
    while True:
        sweep()
except KeyboardInterrupt:
    print("Saliendo...")
finally:
    pwm.stop()
    GPIO.cleanup()
