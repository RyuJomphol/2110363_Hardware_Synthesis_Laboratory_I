# Basys3 4-Digit 7-Segment Display (Verilog Guide)

## 1. วิเคราะห์โจทย์ (Problem Analysis)

โปรเจกต์นี้มีเป้าหมายเพื่อออกแบบวงจรด้วย Verilog สำหรับบอร์ด **Basys3 FPGA**  
เพื่อควบคุม **7-segment display จำนวน 4 หลัก** โดยใช้

- **Switches (16-bit)** สำหรับกำหนดค่าที่จะแสดงผล
- **Clock (clk)** สำหรับควบคุมการทำงานของระบบ
- **Button (btnC)** ใช้เป็น **synchronous reset (active-high)**

### แนวคิดหลักของระบบ
- สวิตช์ 16 บิต ถูกแบ่งออกเป็น 4 กลุ่ม กลุ่มละ 4 บิต  
  - `sw[15:12]` → หลักที่ 1 (ซ้ายสุด)
  - `sw[11:8]`  → หลักที่ 2
  - `sw[7:4]`   → หลักที่ 3
  - `sw[3:0]`   → หลักที่ 4 (ขวาสุด)
- แต่ละกลุ่ม 4 บิต แทนค่า **เลขฐานสิบหก (0–F)**
- ใช้เทคนิค **multiplexing** เพื่อสลับเปิดทีละ digit อย่างรวดเร็ว  
  ทำให้ผู้ใช้เห็นเหมือนทั้ง 4 หลักติดพร้อมกัน
- ต้องมี **clock divider** เพื่อทำให้การสลับ digit ช้าลงจนเหมาะสมกับสายตามนุษย์

---

## 2. โครงสร้างระบบ (System Structure)

ระบบถูกแบ่งออกเป็น 2 โมดูลหลัก

1. `top_modules`  
   - โมดูลหลัก (Top-level)
   - ควบคุม clock, reset, digit selection และ AN
2. `seven_segment`  
   - โมดูลแปลงค่าเลขฐานสิบหก (0–F)
   - เป็นสัญญาณควบคุม segment (a–g)

---

## 3. อธิบายโค้ด (Code Explanation)

### 3.1 Top Module : `top_modules`

#### พอร์ตของโมดูล
```verilog
input clk,
input btnC,
input [15:0] sw,
output reg [3:0] an,
output [6:0] seg,
output dp
```

* `clk` : clock หลักของบอร์ด (100 MHz)
* `btnC` : synchronous reset (active-high)
* `sw` : ค่าที่ใช้แสดงผลบน 7-segment
* `an` : เลือก digit ที่กำลัง active (active-low)
* `seg` : ควบคุม segment a–g
* `dp` : decimal point (ปิดตลอด)

### 3.2 Clock Divider (Slow Clock)

```verilog
reg [16:0] slow_clock_counter = 0;
reg slow_clock = 0;

always @(posedge clk) begin
    slow_clock_counter <= slow_clock_counter + 1;
    if (slow_clock_counter == 0)
        slow_clock <= ~slow_clock;
end
```

* ใช้ลดความเร็ว clock จาก 100 MHz
* `slow_clock` ใช้สำหรับสลับ digit
* การใช้ counter overflow เป็นวิธี divide clock แบบง่าย

### 3.3 Digit Counter (เลือกหลักที่แสดงผล)

```verilog
reg [1:0] counter = 0;

always @(posedge slow_clock) begin
    if (btnC)
        counter <= 0;
    else
        counter <= counter + 1;
end
```

* `counter` วิ่งตั้งแต่ 0 → 3
* ใช้เลือกว่ากำลังแสดง digit ไหน
* `btnC` ทำหน้าที่ reset แบบ synchronous

### 3.4 Multiplexing Logic

```verilog
always @(*) begin
    case (counter)
        2'd0: begin
            digit = sw[15:12];
            an    = 4'b0111;
        end
        2'd1: begin
            digit = sw[11:8];
            an    = 4'b1011;
        end
        2'd2: begin
            digit = sw[7:4];
            an    = 4'b1101;
        end
        2'd3: begin
            digit = sw[3:0];
            an    = 4'b1110;
        end
    endcase
end
```

* เลือกค่า digit จาก switch
* เปิดใช้งาน AN เพียงหลักเดียว (active-low)
* เป็นหัวใจของการทำ **4-digit multiplexing**

### 3.5 Seven Segment Decoder

```verilog
module seven_segment(
    input [3:0] in,
    output reg [6:0] out
);
```

* แปลงเลขฐาน 16 (0–F)
* เป็นรูปแบบ active-low (เหมาะกับ Basys3)
```verilog
4'h0: out = 7'b1000000;
4'h1: out = 7'b1111001;
...
4'hF: out = 7'b0001110;
```

### 4. Constraint File (XDC)

* กำหนด pin ให้กับ
  * Clock
  * Switches
  * 7-segment (seg, an, dp)
  * Button
* ใช้ IOSTANDARD เป็น `LVCMOS33`
* กำหนด clock period = 10 ns (100 MHz)
