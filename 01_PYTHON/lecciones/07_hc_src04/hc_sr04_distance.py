from hcsr04 import HCSR04

sensor = HCSR04(23, 24)

try:
    while True:
        distance = sensor.read()

        if distance is not None:
            print(f"{distance:.1f} cm")

finally:
    sensor.cleanup()
