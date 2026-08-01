"""Lección 00: hacer parpadear un LED conectado a GPIO18."""

import RPi.GPIO as GPIO
import time

# Configuración de Modo de Pines
GPIO.setmode(GPIO.BCM)

# Configuración de Pines
GPIO.setup(18, GPIO.OUT)

# Desactivar advertencias
GPIO.setwarnings(False)

try:
    while True:
        try:
            print("Blinking LED...")
            GPIO.output(18, GPIO.HIGH)          # Enciende el LED
            time.sleep(1)                       # Espera 1 segundo
            GPIO.output(18, GPIO.LOW)           # Apaga el LED
            time.sleep(1)                       # Espera 1 segundo
        except RuntimeError as e:               # Maneja errores específicos de tiempo de ejecución
            print(f"RuntimeError: {e.args[0]}")
        except Exception as e:                  # Maneja cualquier otro tipo de excepción
            print(f"An error occurred: {e}")
except KeyboardInterrupt:                       # Permite salir del programa con Ctrl+C
        print("Exiting program...")
finally:                                        # Asegura que los recursos se limpien correctamente
        GPIO.cleanup()
