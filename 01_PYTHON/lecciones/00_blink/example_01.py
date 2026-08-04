"""Lección 00: hacer parpadear un LED conectado a GPIO21."""

import RPi.GPIO as GPIO
import time

# void septup()
LED_PIN = 21

# Configuración de Modo de Pines
GPIO.setmode(GPIO.BCM)

# Configuración de Pines
GPIO.setup(LED_PIN, GPIO.OUT)

# Desactivar advertencias
GPIO.setwarnings(False)

# void loop()
try:
    while True:
        print("Blinking LED...")
        GPIO.output(LED_PIN, GPIO.HIGH)         # Enciende el LED
        time.sleep(1)                           # Espera 1 segundo
        GPIO.output(LED_PIN, GPIO.LOW)          # Apaga el LED
        time.sleep(1)                           # Espera 1 segundo
except KeyboardInterrupt:                       # Permite salir del programa con Ctrl+C
        print("Exiting program...")
finally:                                        # Asegura que los recursos se limpien correctamente
        GPIO.cleanup()
        print("GPIO cleanup done.")

# librerias

# void setup()

# void loop()
