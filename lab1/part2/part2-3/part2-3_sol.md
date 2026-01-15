## Problem 3: Implement the D flip-flop with synchronous reset

## 1️⃣ Basic Syntax: Module / input / output / reg
เริ่มจากโครงสร้างพื้นฐานของภาษา **Verilog**

```verilog
module dff_sync_reset (
    input  clk,
    input  rst,
    input  D,
    output reg Q
);
```

อธิบายทีละส่วน:

* `module dff_sync_reset`
  → ประกาศโมดูล ชื่อ ต้องตรงกับโจทย์

* `input clk`
  → สัญญาณนาฬิกา (Clock)

* `input rst`
  → สัญญาณ reset แบบ synchronous (active high)

* `input D`
  → ข้อมูล 1 บิต ที่จะเก็บใน flip-flop

* `output reg Q`
  → ค่าเอาต์พุตที่เก็บสถานะ
  ❗ ต้องใช้ `reg` เพราะค่า Q ถูกเปลี่ยนใน `always block`

## 2️⃣ อธิบาย D Flip-Flop (แนวคิด)

**D Flip-Flop คือวงจรลอจิกแบบ Sequential Logic**

**คุณสมบัติสำคัญ:**

* เก็บค่า D

* เปลี่ยนค่าเฉพาะตอน ขอบขาขึ้นของ clock (posedge clk)

* มี memory → ค่าจะค้างอยู่จนกว่าจะถึง clock รอบถัดไป

**Synchronous Reset คืออะไร?**

* reset จะ ทำงานพร้อม clock เท่านั้น

* ถ้า rst = 1 แต่ clock ยังไม่ขึ้น → ยังไม่ reset

* reset จะเกิด ที่ posedge clk เท่านั้น

**เปรียบเทียบง่าย ๆ:**

* ❌ Asynchronous reset → reset ได้ทันที

* ✅ Synchronous reset → reset เฉพาะตอน clock ขึ้น

## 3️⃣ อธิบายรูปภาพเป็น ASCII Diagram

ภาพการทำงานของ D Flip-Flop พร้อม synchronous reset สามารถเขียนเป็น ASCII ได้ดังนี้
```lua

          +----------------+
   D ---->|                |
          |   D Flip-Flop  |----> Q
  clk --->|   (posedge)    |
          |                |
  rst --->|  Sync Reset    |
          +----------------+


```
หรือมองเชิงเวลา (Timing):
```markdown

clk :  ___/‾‾‾\___/‾‾‾\___
rst :  _________‾‾‾_______
D   :  0___1_______0______
Q   :  0___1___0__________
          ↑     ↑
       sample   reset


```
* ลูกศร ↑ คือ `posedge clk`

* ถ้า `rst = 1` ที่จุดนั้น → Q = 0

* ถ้า `rst = 0` → Q รับค่า D

## 4️⃣ อธิบายโค้ดที่ต้องทำ (Solution)

**โค้ดเต็มตามโจทย์:**
```verilog
module dff_sync_reset (
    input  clk,
    input  rst,
    input  D,
    output reg Q
);

    always @(posedge clk) begin
        if (rst)
            Q <= 1'b0;   // synchronous reset
        else
            Q <= D;      // latch D on rising edge
    end

endmodule
```
---

**อธิบายทีละบรรทัด**
```verilog
always @(posedge clk)
```

* บอกว่า **ทำงานเฉพาะตอน clock ขอบขาขึ้น**

* นี่คือหัวใจของ Flip-Flop

```verilog
if (rst)
    Q <= 1'b0;
```

* ถ้า reset เป็น 1 ตอน clock ขึ้น

* ให้ Q กลับเป็น 0

* `<=` คือ non-blocking assignment (ใช้กับ sequential logic)

```verilog
else
    Q <= D;
```

* ถ้าไม่ reset

* เก็บค่า D ลงใน Q

