import time

from hcsr04 import HCSR04

sensor = HCSR04(
    trig_pin=23,
    echo_pin=24,
)

try:
    while True:
        distance = sensor.median()

        if distance is None:
            print("Lectura inválida")
        else:
            print(f"Distancia: {distance:.1f} cm")

        time.sleep(0.2)

except KeyboardInterrupt:
    print("Saliendo...")

finally:
    sensor.cleanup()
