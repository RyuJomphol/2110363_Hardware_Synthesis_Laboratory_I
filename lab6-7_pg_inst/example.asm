START:
    lw x7, 80(x0)       # Load value from switches to register x7
    sw x10, 84(x0)      # Store value from register x10 to LEDs
    jal x4, START       # Go back to first instruction (for looping)