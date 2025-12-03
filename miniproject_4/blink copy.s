    lui x1, 0xFFFFF     # x1 = 0xFFFFF000
    addi x2, x1, -4     # x2 = 0xFFFFFFFC (LEDS Address)
    addi x3, x1, -8     # x3 = 0xFFFFFFF8 (Millis Address)

loop:
    lw x4, 0(x3)        # Load millis into x4
    srli x5, x4, 6      # Shift right by 6 to slow down blinking for visibility
                        # Bits of millis driving LEDs:
                        # Blue (LSB) <- Millis[13:6]
                        # Green      <- Millis[21:14]
                        # Red        <- Millis[29:22]
    sw x5, 0(x2)        # Write to LEDs
    beq x0, x0, loop    # Jump back to loop (approx offset -12)

