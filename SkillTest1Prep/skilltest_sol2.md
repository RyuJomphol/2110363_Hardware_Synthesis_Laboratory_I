**ภาพรวมโจทย์**

โมดูล `skilltest1_sol2.v` ให้ฟังก์ชันเดียวกับ `skilltest1_sol1.v` (เก็บค่า BCD 4 หลัก เริ่มที่ 1 และมี Trigger 4 บิต: +1, +2, *2, *3) แต่ปรับปรุงด้าน debounce ให้เป็น per-bit FSM ซึ่งทำให้การกดหลายปุ่มพร้อมกันถูกจัดการได้ดีกว่า

**การออกแบบโดยย่อ**

- ค่าเก็บจริงอยู่ใน `current_val` ขนาด 14 บิต (เพียงพอสำหรับ 0..9999)
- มีแฟล็ก `overflow_active` เมื่อผลลัพธ์เกิน 9999
- ใช้ per-bit debounce FSM: `db_state[3:0]` และ `db_counter[3:0]` แต่ละบิตมีสถานะ S_IDLE, S_COUNT, S_WAIT_REL
- เมื่อ FSM ของบิตใดเจอ rising edge จะสร้างพัลส์ชั่วคราวใน `trigger_action[i]` (หนึ่งค็อก) เพื่อให้บล็อก arithmetic อ่านพัลส์เดียว
- Arithmetic logic ตรวจสอบ `trigger_action` ทีละบิต (0..3) และอัปเดต `current_val` หรือเซ็ต `overflow_active`
- เอาต์พุต BCD แปลงจาก `current_val` แบบ combinational (ใช้ / และ % เพื่อแบ่งหลัก)

**Debounce FSM (per bit) — พฤติกรรม**

- S_IDLE: รอให้ `Trigger[i]` เป็น 1 -> สร้างพัลส์ใน `trigger_action[i]`, ไป S_COUNT
- S_COUNT: เพิ่ม `db_counter[i]` จนถึง 1023 -> ไป S_WAIT_REL
- S_WAIT_REL: รอให้ `Trigger[i]` กลับเป็น 0 -> กลับ S_IDLE

ASCII diagram (บิตเดียว):

  IDLE --(Trigger=1)--> COUNT --(counter==1023)--> WAIT_REL --(Trigger=0)--> IDLE

**โครงงานบล็อก (ASCII diagram)**

  Trigger[3:0] --> +------------------------------+
                 |  per-bit debounce FSM array    |
                 +--------------+---------------+
                                | trigger_action[3:0] (one-cycle pulses)
                                v
                       +-------------------------+
                       | Arithmetic / Overflow   |
                       |   (current_val update)  |
                       +-------------------------+
                                |
                                v
                       +-------------------------+
                       | Binary -> BCD (comb)    |
                       +-------------------------+
                                |
                                v
                         BCD3 BCD2 BCD1 BCD0 (outputs)

**ไฮไลท์โค้ดสำคัญ**

- Debounce array (ตัวอย่าง):

```verilog
for (i = 0; i < 4; i = i + 1) begin
  case (db_state[i])
    S_IDLE: if (Trigger[i]) begin trigger_action[i] <= 1; db_state[i] <= S_COUNT; end
    S_COUNT: if (db_counter[i] == 1023) db_state[i] <= S_WAIT_REL; else db_counter[i] <= db_counter[i] + 1;
    S_WAIT_REL: if (!Trigger[i]) db_state[i] <= S_IDLE;
  endcase
end
```

- Arithmetic (priority: bit0, bit1, bit2, bit3)

```verilog
if (trigger_action[0]) // +1
  if (current_val + 1 > 9999) overflow_active <= 1; else current_val <= current_val + 1;
else if (trigger_action[1]) // +2 ...
```

- Output combinational แปลงด้วย `/` และ `%` เป็น 4 หลัก BCD

**ข้อดีของการออกแบบนี้**

- Debounce ต่อบิต ทำให้รองรับการกดพร้อมกันหลายปุ่มได้ดี
- `current_val` ขนาด 14 บิต ประหยัดบิตกว่า 16 บิต
- การสร้างพัลส์หนึ่งรอบ (`trigger_action`) ช่วยหลีกเลี่ยงการทำ action ซ้ำจากปัญหาเดบอนซ์

**ข้อควรระวัง / ข้อเสนอแนะ**

- เช่นเดียวกัน การใช้การหาร (`/`) และ modulo (`%`) แบบ combinational อาจหนักเมื่อสังเคราะห์บน FPGA; ถ้าต้องการประสิทธิภาพเชิงฮาร์ดแวร์ ควรใช้วิธี Double Dabble (shift-add-3) เพื่อแปลงเป็น BCD
- ปรับขนาดตัวนับเดบอนซ์ (`db_counter`) ให้เหมาะกับความถี่นาฬิกาและเวลาที่ต้องการกรอง (ค่าปัจจุบันคือ 1024 รอบ)
- ถ้าต้องการรองรับการกดแบบ hold และผ่อนเป็น repeat-rate ต้องเปลี่ยน FSM ใน S_WAIT_REL ให้รองรับการ repeat

**ตัวอย่างการทดสอบ**

- เริ่มระบบ -> แน่ใจว่าเอาต์พุตแสดง `0001`
- กด `Trigger[0]` สั้น ๆ -> ค่าเพิ่มเป็น 0002 และ `debounce` ป้องกันการอ่านซ้ำ
- กด `Trigger[2]` (*2) เมื่อค่าใกล้ขอบ -> ตรวจสอบว่า `overflow_active` ถูกเซ็ตเมื่อผลลัพธ์ > 9999
