## Problem 2: 4-bit Full Adder

โมดูล `full_adder_4_bit` มีหน้าที่
บวกเลข 4-bit สองตัว (`a`, `b`) พร้อม carry-in (`cin`)
และให้ผลลัพธ์เป็น

* sum : ผลรวม 4-bit
* cout : carry-out 1-bit

## 1️⃣ Basic Syntax: module / input / output / assign
ใน Verilog เราจะประกาศโมดูลด้วยคำว่า `module` และระบุ input / output ให้ชัดเจน
```verilog
  module full_adder_4_bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire cin,
    output wire [3:0] sum,
    output wire cout
);
```

**อธิบายทีละส่วน**

* `a`, `b` เป็น เลข 4-bit → `[3:0]`

* `cin` เป็น carry-in 1-bit

* `sum` เป็นผลลัพธ์ 4-bit

* `cout` เป็น carry ที่ไหลออกจากบิตที่มากที่สุด (MSB)

วงจรนี้เป็น Combinational Logic
จึงใช้ `assign` ไม่มี `always` และไม่มี `clock`

## 2️⃣ อธิบายแนวคิดของ Full Adder

**Full Adder (1-bit)**
 รับอินพุต 3 ตัว

* `a`
* `b`
* `cin`

และให้ผลลัพธ์

* `sum`
* `cout`

สมการพื้นฐานคือ
```ini
sum  = a ⊕ b ⊕ cin
cout = ab + (a ⊕ b)cin
```

หรือเขียนเป็นขั้นตอนของสัญญาณ

```ini
step1 = in1 XNOR in2
step2 = step1 XOR in3
```
**4-bit Full Adder**
  คือการ นำ Full Adder 1-bit มาต่อกัน 4 ตัว

* บิตที่ 0 รับ `cin`

* carry จะไหลจากบิตล่าง → บิตบน

* carry สุดท้ายคือ `cout`

## 3️⃣ อธิบายรูปภาพเป็น ASCII

โครงสร้างของ 4-bit Full Adder สามารถมองแบบนี้ได้
![Alt text](https://vlsiverify.com/wp-content/uploads/2022/11/4bit_adder_subtractor.jpg)

แต่ใน Verilog
เรา **ไม่จำเป็นต้องต่อ FA ทีละตัวเอง**
เพราะตัวบวก (`+`) สามารถจัดการเรื่อง carry ให้เราอัตโนมัติ

## 4️⃣ อธิบายโค้ดที่ต้องทำ (Solution)

**โค้ดเต็ม**
```verilog
module full_adder_4_bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire cin,
    output wire [3:0] sum,
    output wire cout
);
    wire [4:0] tmp;

    assign tmp  = {1'b0, a} + {1'b0, b} + cin;
    assign sum  = tmp[3:0];
    assign cout = tmp[4];
endmodule
```
---

**อธิบายทีละบรรทัด**

**1) ตัวแปรชั่วคราว** `tmp`
```verilog
wire [4:0] tmp;
```

* ใช้ 5 บิต เพราะ

  * 4-bit + 4-bit + 1-bit → ผลรวมสูงสุดต้องใช้ 5 บิต

* บิตที่ 4 `(tmp[4])` คือ carry-out

**2) การต่อบิต** `{1'b0, a}`
```verilog
assign tmp = {1'b0, a} + {1'b0, b} + cin;
```

* `{1'b0, a}` คือการขยาย `a` จาก 4-bit → 5-bit

* ป้องกัน overflow หาย

* ตัวบวก `+` จะจัดการ carry chain ให้ทั้งหมด

ตัวอย่าง:
```makefile
a    = 1111 (15)
b    = 0001 (1)
cin  = 0
----------------
tmp  = 1_0000 (16)
```

**3) แยก sum และ cout**
```verilog
assign sum  = tmp[3:0];
assign cout = tmp[4];
```

* `sum` = 4 บิตล่าง

* `cout` = บิตบนสุด
