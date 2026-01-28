# Lab 3 Part 4 - Data Generator System Overview

## โครงสร้างทั่วไป (System Architecture)

Part 4 นี้เป็นระบบ **Data Generator** ที่ทำงานบน **Basys3 FPGA** โดยมี 3 ส่วนหลัก:

---

## ไฟล์ที่สำคัญ

### 1. `data_generator.v` - Core Module

**วัตถุประสงค์:** สร้าง data stream ตามคำสั่ง

#### Inputs:
- `clk` - Clock signal (100 MHz)
- `rst` - Reset signal (ตั้ง initial state)
- `start` - Signal เพื่อเริ่มการสร้าง data
- `data_length` - จำนวน data ที่ต้องสร้าง (0-255)

#### Outputs:
- `data_out` - ค่า data ที่ออกมา (8 bits)
- `data_valid` - Signal บอกว่า data_out มีค่า valid หรือไม่

#### ลอจิก:
```
State: IDLE
├─ ถ้า start=1 → เปลี่ยนไป GENERATING
└─ ถ้า start=0 → รอ

State: GENERATING
├─ สร้าง data: 0, 1, 2, 3, ... data_length
├─ ตั้ง data_valid=1 เพื่อบอกว่ามี data
└─ ถ้า data_out ≥ data_length → กลับไป IDLE
```

**ตัวอย่าง:**
- ถ้า `data_length=5` → output ลำดับ: 0, 1, 2, 3, 4, 5 แล้วหยุด

---

### 2. `design_under_test_top.v` - Top Module (Integration)

**วัตถุประสงค์:** เชื่อมต่อ data_generator กับเครื่องมือ debug บน FPGA

#### ประกอบด้วย 3 ส่วน:

#### A. **VIO (Virtual I/O)** - ควบคุมจากคอมพิวเตอร์
```verilog
vio_data_generator_conf vio_inst
```
- ใช้ควบคุม signal จากเดสก์ทอป ผ่าน USB
- **probe_out0** → `start` (ปุ่มเริ่มต้น)
- **probe_out1** → `rst` (ปุ่ม reset)
- **probe_out2** → `data_length` (slider เพื่อตั้งจำนวน data)

#### B. **Data Generator** - Module หลัก
```verilog
data_generator dut_inst
```
- DUT (Device Under Test) ที่ทำงานจริง
- ได้ input จาก VIO
- ส่ง output ไป ILA

#### C. **ILA (Integrated Logic Analyzer)** - Oscilloscope บน FPGA
```verilog
ila_data_out ila_inst
```
- จับ `data_out` และ `data_valid`
- บันทึก waveform เพื่อดูผลลัพธ์ในเดสก์ทอป
- ใช้ Vivado Logic Analyzer เพื่อดู

---

### 3. `part_4_constraint.xdc` - FPGA Constraints

**วัตถุประสงค์:** กำหนด hardware pins และ timing

```xdc
create_clock -period 10.000 -name Clk ...
```
- กำหนด clock period = 10 ns → Frequency = 100 MHz

```xdc
set_property PACKAGE_PIN W5 [get_ports clk]
```
- บอก FPGA ว่า pin `W5` บน Basys3 คือ clock pin

```xdc
set_property IOSTANDARD LVCMOS33 [get_ports clk]
```
- ตั้ง voltage standard = 3.3V (ระดับมาตรฐานของ Basys3)

---

## Flow การทำงาน (Data Flow)

```
┌─────────────────────────────────────────────────────────────┐
│                     Basys3 FPGA Board                       │
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │     VIO      │    │Data Generator│    │     ILA      │  │
│  │ (Control)    │───→│   (DUT)      │───→│  (Monitor)   │  │
│  │              │    │              │    │              │  │
│  │ start ←──────┤    │ clk ←────────────────┬          │  │
│  │ rst ←────────┤    │ rst ←────┐   │      │          │  │
│  │ data_length  │    │ start    │   │      │          │  │
│  └──────────────┘    │ data_len │   │      │          │  │
│        ↑             │          │   │      │          │  │
│        │             └──────────┘   │      │          │  │
│   USB Computer                      │      └──────────┘  │
│   (Vivado)                          │                    │
│                                     └────→ Waveform Viewer
│                                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## สรุปข้อมูล (Summary)

| ส่วนประกอบ | ที่ตั้ง | หน้าที่ |
|-----------|---------|--------|
| **data_generator** | Module หลัก | สร้าง sequence data ตามเงื่อนไข |
| **VIO** | Input Control | ให้ผู้ใช้ควบคุม start, rst, data_length จากคอม |
| **ILA** | Output Monitor | บันทึก waveform ของ data_out, data_valid |
| **XDC** | Pin Mapping | ระบุ clock pin และ timing |

---

## การใช้ งาน (How to Use)

1. **Synthesize & Implement** ใน Vivado
2. **Program FPGA** ลงบน Basys3
3. **เปิด Vivado Hardware Manager**
4. ใช้ **VIO Dashboard** เพื่อ:
   - ตั้ง `data_length` (เช่น 10)
   - กด `start` = 1
5. ดู **Logic Analyzer** เพื่อเห็น data sequence ที่ output

---

## Expected Output

**ถ้า data_length=5:**
```
Time  | data_out | data_valid
------|----------|----------
0 ns  |    0     |    0
10 ns |    0     |    1
20 ns |    1     |    1
30 ns |    2     |    1
40 ns |    3     |    1
50 ns |    4     |    1
60 ns |    5     |    1
70 ns |    0     |    0  (กลับ IDLE)
```
