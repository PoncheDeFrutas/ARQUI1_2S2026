import smbus
import time

address = 0x48  # Address of the I2C device (PCF8591)
A0 = 0x40  # Channel A0
# A1 = 0x41  # Channel A1
# A2 = 0x42  # Channel A2
# A3 = 0x43  # Channel A3

bus = smbus.SMBus(1)  # Create an I2C bus object

while True:
    bus.write_byte(address, A0)  # Select channel A0
    value = bus.read_byte(address)  # Read the value from the device
    print(f"Value from A0: {value}")  # Print the value read from channel A0
    time.sleep(1)  # Wait for 1 second before the next read
