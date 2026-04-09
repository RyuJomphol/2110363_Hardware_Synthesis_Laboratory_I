import serial

# For serial port, adjust to your board
# On Linux, it might be something like "/dev/ttyUSB0" or "/dev/ttyACM0"
# On Windows, it might be "COM3" or similar. You can check your device manager to find the correct port.
# On MacOS, it might be something like "/dev/tty.usbserial-XXXX" or "/dev/tty.usbmodemXXXX"
SERIAL_PORT = "COM4"   # change this
BAUDRATE = 115200
INPUT_FILE = "memory.txt"

def main():

    ser = serial.Serial(SERIAL_PORT, BAUDRATE, timeout=1)

    address = 0
    
    with open(INPUT_FILE, "r") as f:
        for line in f:
            line = line.strip()

            if len(line) != 32:
                continue

            if not all(c in "01" for c in line):
                continue

            for i in range(0, 32, 8):
                byte_str = line[i:i+8]
                byte_value = int(byte_str, 2)
                address_header = address & 0xFF  # Get the lower 8 bits of the address
                print(f"Address: {address_header:02X}, Byte {i//8}: {byte_str} -> {byte_value}")
                header_byte = address_header.to_bytes(1, byteorder="big")  # Convert to single byte
                data_byte = byte_value.to_bytes(1, byteorder="big")  # Convert to single byte
                print(f"Header: {header_byte}, Data: {data_byte}")
                address += 1
                ser.write(header_byte)
                ser.write(data_byte)
        print("Finished sending Instruction Memory data")

        # issue soft reset command to all module
        reset_header = (0x80).to_bytes(1, byteorder="big")  # MSB set to 1 for reset command
        ser.write(reset_header)
        print("Sent reset command")

    ser.close()

if __name__ == "__main__":
    main()