import time
import board

from adafruit_ads1x15 import ADS1115, AnalogIn, ads1x15

i2c = board.I2C()

ads = ADS1115(i2c)

channel3 = AnalogIn(ads, ads1x15.Pin.A3)

try:
    while True:
        voltage = channel3.voltage
        value = channel3.value

        print(f"Channel 3 Voltage: {voltage:.2f} V")
        print(f"Channel 3 Value: {value}")

        time.sleep(1)

except KeyboardInterrupt:
    print("Program interrupted by user.")
