## Part 3 – Introduction to Digital Simulation 
### Problem 1: 2-bit Full Adder Testbench (Cocotb)

## 1️⃣ Basic Simulation and Testing
ก่อนอื่นต้องปูพื้นฐานให้น้องเข้าใจว่า

🔹 **ทำไมต้อง Simulation?**

* วงจรดิจิทัล แก้ไขไม่ได้ง่าย หลังผลิตเป็นฮาร์ดแวร์จริง

* Simulation คือการ “ทดลองรันวงจร” ด้วยคอมพิวเตอร์

* เราใช้ testbench ป้อนอินพุต → ดูเอาต์พุต → เช็คว่าถูกต้องหรือไม่

🔹 **Cocotb คืออะไร?**

* Cocotb คือ Python-based testbench

* ใช้ Python ควบคุม Verilog/VHDL

* ข้อดี:

  * เขียนง่าย อ่านเข้าใจ

  * ใช้ loop ทดสอบทุกกรณีได้สะดวก

  * เหมาะกับการ Exhaustive test (ลองทุก input)

## 2️⃣ อธิบาย Full Adder 2-bit

🔹 **อินพุต**

* `A` : เลข 2 บิต (0–3)

* `B` : เลข 2 บิต (0–3)

* `Cin` : carry-in (0 หรือ 1)

🔹 **เอาต์พุต**

* `Sum` : ผลรวม 2 บิต

* `Cout` : carry-out 1 บิต

🔹 **หลักการคำนวณ**
```ini
result = A + B + Cin
Sum  = result[1:0]   (2 บิตล่าง)
Cout = result[2]     (บิตที่เกิน)
```

## 3️⃣ อธิบายรูปภาพเป็น ASCII Diagram

อธิบายเป็นภาพ ASCII ให้เข้าใจ flow ของสัญญาณ
```less

        A[1:0] ----\
                    +----> 2-bit Full Adder ----> Sum[1:0]
        B[1:0] ----/               |
                                    ----> Cout
            Cin ------------------/


```
หรือมองตัวเลข
```markdown
 A   B   Cin   |  Cout   Sum
------------------------------
 0   0    0    |   0     00
 0   1    1    |   0     10
 3   3    1    |   1     11

```
👉 ดังนั้น testbench ที่ดี ต้องลองครบทุกกรณี

## 4️⃣ อธิบายโค้ด Testbench ที่ต้องทำ (Solution)

**โค้ดเต็มตามโจทย์:** เอามาจาก **Part 2-2** เป็นส่วนใหญ่
```python
@cocotb.test()
async def fulladder_2bit_test(dut):
    # Create a logger for this testbench
    logger = logging.getLogger("fulladder_2bit_test")
    logger.info("Starting Full Adder 2-bit Testbench")
    
    passed_count = 0
    total_count = 0
    
    # Test all possible 4-bit values for a and b, and both values of cin
    for a in range(4):  # 0 to 4 for 2-bit
        for b in range(4):  # 0 to 4 for 2-bit
            for cin in range(2):  # 0 or 1 for carry in
                dut.A.value = a
                dut.B.value = b
                dut.Cin.value = cin
                
                await Timer(1, unit="ns")
                
                # Calculate expected result
                result = a + b + cin
                expected_sum = result & 0b11  # Lower 4 bits
                expected_cout = (result >> 2) & 0b1  # Carry out bit
                
                actual_sum = int(dut.Sum.value)
                actual_cout = int(dut.Cout.value)
                
                total_count += 1
                
                sum_match = actual_sum == expected_sum
                cout_match = actual_cout == expected_cout
                
                if sum_match and cout_match:
                    passed_count += 1
                
                status = "PASS" if (sum_match and cout_match) else "FAIL"
                
                assert sum_match, f"Sum mismatch at a={a}, b={b}, cin={cin}: got {actual_sum}, expected {expected_sum}"
                assert cout_match, f"Cout mismatch at a={a}, b={b}, cin={cin}: got {actual_cout}, expected {expected_cout}"
```
---

**อธิบายทีละบรรทัด**

**4.1 Import ที่จำเป็น**
```python
import cocotb
from cocotb.triggers import Timer
import logging
```

* `@cocotb.test()` → บอกว่านี่คือ test

* `Timer` → รอเวลาให้สัญญาณนิ่ง

* `logging` → แสดง log ระหว่างรัน

**4.2 โครงสร้าง Test หลัก**
```python
@cocotb.test()
async def fulladder_2bit_test(dut):
```

* `dut` = Device Under Test (โมดูล Verilog)

* ใช้ `async` เพราะ Cocotb ทำงานแบบ event-driven

**4.3 Loop ทดสอบทุกความเป็นไปได้ (Exhaustive Test)**
```python
for a in range(4):      # 00 ถึง 11
    for b in range(4):  # 00 ถึง 11
        for cin in range(2):  # 0 หรือ 1
```

จำนวนทั้งหมด:
```
4 × 4 × 2 = 32 cases
```

* ✔ ครบทุก input combination
* ✔ เหมาะกับ combinational logic

**4.4 ป้อนค่าเข้า DUT**
```python
dut.A.value = a
dut.B.value = b
dut.Cin.value = cin
```

จากนั้นรอเวลาเล็กน้อยให้วงจรคำนวณ
```python
await Timer(1, unit="ns")
```

**4.5 คำนวณผลลัพธ์ที่ “ควรจะได้” (Golden Model)**
```python
result = a + b + cin
expected_sum = result & 0b11
expected_cout = (result >> 2) & 0b1
```

📌 จุดสอนน้อง:

* `& 0b11` → เอาแค่ 2 บิตล่าง

* `>> 2` → เลื่อนบิตไปดู carry

**4.6 อ่านค่าจริงจากวงจร**

```python
actual_sum = int(dut.Sum.value)
actual_cout = int(dut.Cout.value)
```

**4.7 ตรวจสอบผลลัพธ์ (Assertion)**
```python
assert sum_match, f"Sum mismatch at a={a}, b={b}, cin={cin}"
assert cout_match, f"Cout mismatch at a={a}, b={b}, cin={cin}"
```

💡 ถ้าผิด:

* Simulation จะ Fail ทันที

* เห็น input ที่ทำให้พังชัดเจน

**4.8 เปิด waveform ด้วย GTKWave/Surfer เพื่อดู**

* A, B, Cin

* Sum, Cout

* ตรวจการเปลี่ยนแปลงตามเวลา

จะได้ภาพดังใน Report

