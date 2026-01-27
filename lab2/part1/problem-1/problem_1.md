# Problem 1: Moore Finite State Machine (FSM)

ในบทเรียนนี้ เราจะออกแบบและทำความเข้าใจ **Moore Finite State Machine (FSM)** ตาม state diagram ที่กำหนด  
FSM จะเริ่มต้นที่สถานะ **IDLE (S0)** และเปลี่ยนสถานะตามอินพุต 1 บิต (`in`)  
โดยใช้ **synchronous active-high reset** เพื่อรีเซตระบบกลับสู่สถานะเริ่มต้น

> Moore FSM คือ FSM ที่เอาต์พุตขึ้นอยู่กับ *สถานะปัจจุบันเท่านั้น* ไม่ขึ้นกับอินพุตโดยตรง

![Moore FSM State Diagram](images/image.png)

---

## Module Specification

### Module Name moore_fsm


---

## Inputs

| Signal | Width | Description |
|------|------|------------|
| clk | 1 bit | Clock signal ที่ควบคุมการเปลี่ยนสถานะ |
| rst | 1 bit | Synchronous reset (active-high) ใช้รีเซต FSM |
| in  | 1 bit | อินพุตกำหนดการเปลี่ยนสถานะ |

---

## Outputs

| Signal | Width | Description |
|------|------|------------|
| out | 3 bit | เอาต์พุตที่ถูกกำหนดจากสถานะปัจจุบัน |

---

## State Encoding

FSM นี้มีทั้งหมด 6 สถานะ โดยเข้ารหัสเป็น 3 บิตดังนี้

| State | Encoding |
|------|----------|
| S0 (IDLE) | 000 |
| S1 | 011 |
| S2 | 100 |
| S3 | 101 |
| S4 | 010 |
| S5 | 001 |

ค่าเอาต์พุต `out` จะมีค่าเท่ากับรหัสของสถานะปัจจุบัน

---

## FSM Implementation

### Verilog Code

```verilog
module moore_fsm (
    input        clk,
    input        rst,
    input        in,
    output [2:0] out
);

    localparam S0 = 3'b000,
               S1 = 3'b011,
               S2 = 3'b100,
               S3 = 3'b101,
               S4 = 3'b010,
               S5 = 3'b001;

    reg [2:0] state, next_state;

    // State register (sequential logic)
    always @(posedge clk) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    // Next-state logic (combinational logic)
    always @(*) begin
        case (state)
            S0: next_state = S1;
            S1: next_state = (in ? S2 : S4);
            S2: next_state = (in ? S3 : S1);
            S3: next_state = (in ? S5 : S2);
            S4: next_state = (in ? S1 : S5);
            S5: next_state = S5;
            default: next_state = S0;
        endcase
    end

    // Moore output logic
    assign out = state;

endmodule
