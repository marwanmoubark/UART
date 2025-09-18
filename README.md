# UART Communication Project  


**Course:** Digital Design Using FPGA / NTI  
**Student:** Marwan Mobarak   

---

## 📌 Introduction  
The Universal Asynchronous Receiver-Transmitter (UART) is one of the most widely used serial communication protocols. It provides a simple and efficient way to transmit and receive data between digital systems without the need for a shared clock.  

This project was developed as part of the course requirements to design and implement a **UART module in Verilog HDL**, simulate its functionality, and verify correct operation using testbenches.  

---

## 🎯 Objectives  
- To design and implement a **UART Transmitter (TX)** and **UART Receiver (RX)**.  
- To simulate the behavior of the UART protocol in **Verilog HDL**.  
- To verify data integrity during serial communication.  
- To gain practical experience in **hardware description languages (HDL)** and **digital system design**.  

---

## ⚙️ Project Specifications  
- **Data Format:** 1 start bit, 8 data bits, 1 stop bit (8N1).  
- **Baud Rate:** Parameterized (default: 9600 bps).  
- **Clock Frequency:** Configurable (tested with 100 MHz system clock).  
- **Transmission:** LSB-first.  
- **Modules:**  
  - `UART_TX.v` → UART Transmitter  
  - `UART_RX.v` → UART Receiver  
  - `UART_top.v` → Integration module  

---


---

## 🧪 Methodology  
1. **UART Transmitter (TX):**  
   - Adds start bit, shifts out 8-bit data, and appends stop bit.  
   - Controlled by baud rate generator.  

2. **UART Receiver (RX):**  
   - Detects start bit, samples incoming bits at correct baud intervals.  
   - Reconstructs 8-bit data and validates stop bit.  

3. **Testbench:**  
   - Stimulates both TX and RX modules.  
   - Verifies correctness of transmitted vs. received data.  
   - Observed in simulation waveform.  

---

## 📊 Results  
- The UART TX successfully transmitted data with correct timing.  
- The UART RX correctly received and reconstructed transmitted data.  
- Simulation waveforms confirmed proper synchronization between TX and RX.  


---

## ✅ Conclusion  
This project successfully demonstrated the design and implementation of a UART communication system in Verilog HDL. The results verified that the modules can reliably transmit and receive serial data using the standard 8N1 format.  

---

## 🚀 Future Work  
- Implement **parity bit support** for error detection.  .  
- Test on an FPGA development board.  
