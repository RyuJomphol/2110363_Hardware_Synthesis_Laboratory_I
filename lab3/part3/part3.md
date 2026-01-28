# Lab 3 Part 3 - Testbench Guide (Guía de Prueba)

## Problem 1: Full Adder 4-bit Testbench (`full_adder_4_bits_tb.v`)

### วัตถุประสงค์ (Objective)
Testbench นี้ออกแบบมาเพื่อ**ตรวจสอบความถูกต้องของ Full Adder 4-bit** โดยทดสอบ**ทุกการรวมกันของ input**

### โครงสร้างของ Testbench

#### 1. **การประกาศ Signals (Signal Declaration)**
```verilog
reg  [3:0] a;      // Input A (4 bits) - สามารถกำหนดค่าได้
reg  [3:0] b;      // Input B (4 bits) - สามารถกำหนดค่าได้
reg        cin;     // Carry In (1 bit) - สามารถกำหนดค่าได้
wire [3:0] sum;     // Output Sum (4 bits) - สังเกตผลลัพธ์
wire       cout;     // Output Carry Out (1 bit) - สังเกตผลลัพธ์
```
- **`reg`** = สามารถเก็บค่าและเปลี่ยนแปลงได้ (สำหรับ input)
- **`wire`** = สัญญาณออกมา (สำหรับ output)

#### 2. **Instantiation ของ Device Under Test (DUT)**
```verilog
full_adder_4_bits dut (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
);
```
เชื่อมต่อ input/output ของ DUT กับ signals ของ testbench

#### 3. **Monitoring Output**
```verilog
$monitor("Time=%0t | a=%d b=%d cin=%b | sum=%d cout=%b", $time, a, b, cin, sum, cout);
```
- **`$monitor`** = แสดงค่า input/output ตรวจสอบเอง ทุกครั้งที่มีการเปลี่ยนแปลง
- `%0t` = เวลา (time)
- `%d` = ค่าตัวเลข (decimal)
- `%b` = ค่าแบบ binary

#### 4. **Test Pattern (nested loops)**
```verilog
for (i = 0; i < 16; i = i + 1) begin      // a: 0 to 15 (2^4 = 16 ค่า)
    for (j = 0; j < 16; j = j + 1) begin  // b: 0 to 15 (2^4 = 16 ค่า)
        for (k = 0; k < 2; k = k + 1) begin // cin: 0 to 1 (2^1 = 2 ค่า)
            a = i;
            b = j;
            cin = k;
            #10;  // หน่วงเวลา 10 ns เพื่อให้ output ปรับตัว
        end
    end
end
```
- **ทดสอบทั้งหมด**: 16 × 16 × 2 = **512 การรวมกัน**
- **`#10`** = รอ 10 nanoseconds เพื่อให้วงจรคำนวณผลลัพธ์
- เช่น: a=5, b=3, cin=1 ต้องได้ sum=9, cout=0

#### 5. **Waveform Dump**
```verilog
$dumpfile("full_adder_4_bits_tb.vcd");
$dumpvars(0, full_adder_4_bits_tb);
```
บันทึก waveform ลงไฟล์ `.vcd` เพื่อดูผลการจำลอง

---

## Problem 2: FSM Testbench (`fsm_tb.v`)

### วัตถุประสงค์ (Objective)
Testbench นี้ออกแบบมาเพื่อ**ตรวจสอบความถูกต้องของ FSM (Finite State Machine)** โดยทดสอบ**การเปลี่ยน state ตามลำดับ**

### โครงสร้างของ Testbench

#### 1. **Signal Declaration**
```verilog
reg        clk;      // Clock - สร้าง clock signal
reg        reset;    // Reset - ตั้งค่า initial state
reg        data_in;  // Input Data (1 bit) - ควบคุม state transition
wire [1:0] data_out; // Output (2 bits) - แสดง state ปัจจุบัน
```
- FSM นี้มี 4 states: A, B, C, D (ต้องการ 2 bits เพื่อแสดง)

#### 2. **Clock Generation**
```verilog
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
```
- **`forever`** = วนลูปไม่สิ้นสุด
- **`#5 clk = ~clk`** = ทุก 5 ns ให้ clock เปลี่ยนสถานะ
- ผลลัพธ์: Period = 10 ns, Frequency = 100 MHz

#### 3. **Task สำหรับ Input**
```verilog
task apply;
    input din;
    begin
        data_in = din;
        @(posedge clk); #1;  // รอ clock edge ขึ้น + หน่วง 1 ns
    end
endtask
```
- **`@(posedge clk)`** = รอจนกว่า clock จะขึ้น (rising edge)
- **`#1`** = หน่วง 1 nanosecond หลังจาก clock edge
- ใช้ `apply(1)` หรือ `apply(0)` เพื่อป้อน data input

#### 4. **Initialization & Reset**
```verilog
reset = 0;
data_in = 0;

reset = 1;
@(posedge clk); #1;
reset = 0;
```
- ตั้ง reset = 1 เพื่อ reset FSM ไปที่ initial state (โดยปกติ State A)
- รอ 1 clock pulse
- ตั้ง reset = 0 เพื่อให้ FSM ทำงานตามปกติ

#### 5. **State Transition Test Cases**
```verilog
apply(1); // A -> B   (input=1 ให้ state เปลี่ยนจาก A ไป B)
apply(1); // B -> C   (input=1 ให้ state เปลี่ยนจาก B ไป C)
apply(1); // C -> B   (input=1 ให้ state เปลี่ยนจาก C ไป B)
apply(0); // B -> D   (input=0 ให้ state เปลี่ยนจาก B ไป D)
apply(0); // D -> A   (input=0 ให้ state เปลี่ยนจาก D ไป A)
```
**Sequence นี้ทดสอบ:**
- state A, B, C, D ทั้งหมด
- transition ที่สำคัญ เช่น C->B, D->A
- input=0 และ input=1 มีผลต่อ state transitions อย่างไร

---

## สรุปความแตกต่าง (Summary)

| ลักษณะ | Problem 1 (Full Adder) | Problem 2 (FSM) |
|-------|------------------------|-----------------|
| **ประเภท** | Combinational Circuit | Sequential Circuit |
| **Clock** | ไม่มี | มี (10 ns period) |
| **Input Pattern** | ทดสอบ **ทุกชุด** (512 รวมกัน) | ทดสอบ **ลำดับเฉพาะ** |
| **Test Count** | Exhaustive (512 test cases) | Directed (10 transitions) |
| **Output Check** | sum และ cout ตรวจสอบด้วย `$monitor` | data_out (state) ตรวจสอบด้วย waveform |
| **Delay** | `#10` between tests | Synchronized with clock |

---

## วิธีการใช้ (How to Use)

### Problem 1:
```bash
cd lab3/part3/problem-1
make TARGETS=full_adder_4_bits_tb
# หรือใช้ cocotb test
```

### Problem 2:
```bash
cd lab3/part3/problem-2
make TARGETS=fsm_tb
# หรือใช้ cocotb test
```

จากนั้นดู `.vcd` file ใน waveform viewer เพื่อดูผลการจำลอง
