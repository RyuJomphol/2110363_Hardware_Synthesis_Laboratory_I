## Problem 4: JK flip-flop

## 1️⃣ Basic Syntax: Module / input / output / reg
ริ่มจากโครงสร้างพื้นฐานของ Verilog module

```verilog
module jkff (
    input  J,
    input  K,
    input  clk,
    output reg Q
);
```

อธิบายทีละส่วน:

* `module jkff`
  → ประกาศชื่อโมดูลว่า jkff

* `input J, K`
  → เป็นสัญญาณควบคุมของ JK Flip-Flop

  * J = Set / Toggle

  * K = Reset / Toggle

* `input clk`
  → สัญญาณนาฬิกา (Clock)
  → Flip-Flop จะเปลี่ยนค่า เฉพาะตอนขอบขาขึ้น (posedge)

* `output reg Q`
  → Q เป็น output ที่ต้อง **เก็บสถานะได้**
  → จึงต้องประกาศเป็น `reg` (เพราะใช้ใน always block)

## 2️⃣ อธิบาย JK Flip-Flop (แนวคิด)

JK Flip-Flop **เป็น Sequential Logic**
หมายความว่า:

* Output (Q) ไม่ได้ขึ้นกับ input ปัจจุบันอย่างเดียว

* แต่ขึ้นกับ ค่าก่อนหน้า (Qprev) ด้วย

ตารางพฤติกรรมของ JK Flip-Flop:

|J|	K|	การทำงาน|Q|
| ---- | ---- | ---- | ---- |
|0	|0	|Hold|Q
|0	|1	|Reset|0
|1	|0	|Set|1
|1	|1	|Toggle|~Q

## 3️⃣ อธิบายรูปภาพเป็น ASCII Diagram

อธิบายเป็นภาพ ASCII ให้เข้าใจ flow ของสัญญาณ
```lua

        +------------------+
 J ---->|                  |
        |                  |----> Q
 K ---->|   JK Flip-Flop   |
        |                  |
 clk -->|  (posedge clk)  |
        +------------------+


```
หรือมองเชิงเวลา (Timing):
```markdown

clk:  ┌─┐   ┌─┐   ┌─┐
      │ │   │ │   │ │
──────┘ └───┘ └───┘ └──


```
**J,K ถูกอ่านค่าเฉพาะ ↑ (posedge)
Q จะเปลี่ยนค่าเฉพาะตอนนี้เท่านั้น**

## 4️⃣ อธิบายโค้ดที่ต้องทำ (Solution)

**โค้ดเต็มตามโจทย์:**
```verilog
module jkff (
    input  J,
    input  K,
    input  clk,
    output reg Q
);
    always @(posedge clk) begin
        case ({J, K})
            2'b00: Q <= Q;     // Hold
            2'b01: Q <= 1'b0;  // Reset
            2'b10: Q <= 1'b1;  // Set
            2'b11: Q <= ~Q;    // Toggle
        endcase
    end


endmodule
```
---

**อธิบายทีละบรรทัด**
```verilog
always @(posedge clk)
```

* `always @(posedge clk)`
  → บอกว่าเป็น Sequential Logic
  → โค้ดข้างในจะทำงานทุกครั้งที่ clk มีขอบขาขึ้น

```verilog
case ({J, K})
```
* `{J, K}` คือการ concat สัญญาณ 2 บิต

* ทำให้ตรวจสอบค่าได้ง่ายเป็น 4 กรณี:

  *  `00`, `01`, `10`, `11`

**แต่ละกรณีของ JK Flip-Flop**
```verilog
2'b00: Q <= Q;     // Hold
```

* J=0, K=0 → **Hold**

* Q คงค่าเดิม (ไม่เปลี่ยน)

```verilog
2'b01: Q <= 1'b0;  // Reset
```

* J=0, K=1 → **Reset**

* Q ถูกบังคับเป็น 0

```verilog
2'b10: Q <= 1'b1;  // Set
```

* J=1, K=0 → **Set**

* Q ถูกบังคับเป็น 1

```verilog
2'b11: Q <= ~Q;    // Toggle
```

* J=1, K=1 → **Toggle**

* Q เปลี่ยนจาก 0 → 1 หรือ 1 → 0

👉 ใช้ `<=` (non-blocking assignment)
เพราะเป็น **Sequential Logic**

