## How it works

This design creates **two independent PWM channels** (each with a complementary output), and their duty cycles + alignment modes are set by an SPI interface.

- UI pins:
  - `ui_in[0]` = system clock
  - `ui_in[1]` = SPI SCLK
  - `ui_in[2]` = SPI MOSI
  - `ui_in[3]` = SPI SS (active low)
  - `ui_in[4]` = async reset (active high)

Internally each PWM channel can work in:
- **edge–aligned** mode: up counter
- **center–aligned** mode: up/down counter (triangular)

Duty is 4 bits (0–15).  
SPI writes 5 bits per channel: 4 bits duty + 1 bit mode.  
Order: first 5 bits configure PWM1, the next 5 bits configure PWM2.

Outputs:
- `uo[0]` = PWM1
- `uo[1]` = PWM1 inverted
- `uo[2]` = PWM2
- `uo[3]` = PWM2 inverted

---

## How to test

1) Drive a stable clock into `ui_in[0]` (tens of kHz or low MHz recommended).  
2) Apply **ui_in[4] = 1** for ~1 cycle to reset, then back to 0 to run.  
3) With SPI in **MODE 1** (CPOL=0, CPHA=1):
   - Pull SS low
   - Shift MSB-first:

| channel | data   | meaning              |
|---------|--------|----------------------|
| PWM1    | DDDD M | duty (4) + mode (1)  |
| PWM2    | DDDD M | duty (4) + mode (1)  |

`M=0` → edge aligned  
`M=1` → center aligned

Example: set PWM1=8/15 center and PWM2=4/15 edge  
- send: `1000 1` then `0100 0`

4) Observe the four outputs on the logic analyzer or scope.  
They will update every time a full 5-bit frame is clocked into each channel.

---

## External hardware

No external hardware is required.

(If desired, this can drive H-bridge gate drivers or LED loads, but this is optional and not required for functional demonstration.)
