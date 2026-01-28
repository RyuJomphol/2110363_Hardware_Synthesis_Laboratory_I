# Lab3 Part2 - การออกแบบระบบ Producer-Consumer

## ภาพรวม
Part 2 นี้สาธิตการเชื่อมต่อโมดูล (Module Connectivity) ในการออกแบบ HDL โดยแสดงการเชื่อมต่ออย่างถูกต้อง เชื่อมต่อบางส่วน และไม่เชื่อมต่อเลย

## คำอธิบายโค้ด

### 1. Module Producer (producer.v)

```verilog
module producer (
    input wire clk,
    output wire [7:0] data
);
  reg [7:0] data_reg = 0;
  assign data = data_reg;

  always @(posedge clk) begin
    data_reg <= data_reg + 1;
  end
endmodule
```

**หน้าที่**: สร้างข้อมูลขึ้นมา (Data Generator)

**อธิบายทีละบรรทัด**:
- `input wire clk` - สัญญาณนาฬิกาสำหรับซิงโครไนซ์
- `output wire [7:0] data` - เอาต์พุตข้อมูล 8-bit
- `reg [7:0] data_reg = 0` - ตัวจัดเก็บข้อมูล (0 ตั้งแต่เริ่มต้น)
- `assign data = data_reg` - เชื่อมต่อ register กับเอาต์พุต
- `data_reg <= data_reg + 1` - เพิ่มค่า 1 ในทุก clock cycle (0 → 1 → 2 → ... → 255 → 0)

**คุณสมบัติ**:
- Counter แบบวนลูป 8-bit
- ใช้เวลา 256 clock cycles เพื่อครบหนึ่งรอบ

---

### 2. Module Consumer (consumer.v)

```verilog
module consumer (
    input wire clk,
    input wire [7:0] data,
    output wire processed_data
);

  reg processed_data_reg = 0;
  assign processed_data = processed_data_reg;

  always @(posedge clk) begin
    processed_data_reg <= data[0] ^ data[1] ^ data[2] ^ data[3] ^ 
                          data[4] ^ data[5] ^ data[6] ^ data[7];
  end
endmodule
```

**หน้าที่**: ประมวลผลข้อมูล (Data Processor)

**อธิบายทีละบรรทัด**:
- `input wire [7:0] data` - รับข้อมูล 8-bit จาก producer
- `output wire processed_data` - เอาต์พุตข้อมูล 1-bit
- `processed_data_reg` - จัดเก็บผลลัพธ์
- `data[0] ^ data[1] ^ ... ^ data[7]` - **XOR ของทุกบิต** (Parity Bit)

**ตรรกะ XOR**:
```
Input:  1 0 1 0 1 1 0 0
         ^   ^   ^   ^   ^   ^   ^
Output: 1 (เป็น 1 ถ้าจำนวนบิต 1 เป็นจำนวนคี่)
```

**คุณสมบัติ**:
- คำนวณ parity bit (parity check)
- เอาต์พุต 1-bit ที่แสดงจำนวน 1 ในข้อมูลเป็นคี่หรือคู่

---

### 3. Module Top (top_module.v)

```verilog
module top_module (
    input wire clk,
    output wire [2:0] processed_data
);
```

**หน้าที่**: รวมโมดูลย่อย (Hierarchical Design)

เมื่อทำตามใบแลปเราจะได้รูปตามโจทย์
