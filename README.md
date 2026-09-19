# Zynq SoC Hardware/Software Co-Design: AXI4-Lite Floating-Point Accelerator

## Overview
This project demonstrates a complete Hardware/Software co-design flow on a Xilinx Zynq-7000 SoC (ZedBoard). It integrates a custom-designed, 2-stage pipelined 32-bit Floating-Point Unit (FPU) into the Programmable Logic (PL) as an AXI4-Lite Custom IP. The accelerator is controlled and monitored by the ARM Cortex-A9 Processing System (PS) using a bare-metal C software stack. 

Instead of relying on inefficient polling, the software utilizes the Zynq Generic Interrupt Controller (GIC) to handle asynchronous physical button presses, dynamically updating the operands and triggering the hardware accelerator.

## Key Features
* **Custom AXI4-Lite IP:** The FPU was packaged as a custom peripheral using the Vivado IP Packager, exposing memory-mapped registers to the ARM processor for seamless data and control transfer.
* **Pipelined FPU:** A custom 32-bit floating-point adderoptimized with a 2-stage pipeline to improve timing closure and clock frequency.
* **Interrupt-Driven Bare-Metal Drivers:** Developed standalone drivers using `XScuGic` and `XGpio` to manage hardware interrupts, eliminating CPU wait-cycles.
* **Hardware Debouncing:** Custom RTL modules (`debounce.v`) ensure clean edge detection for physical Zedboard inputs.

## System Architecture
The system bridges the gap between the Processing System (PS) and Programmable Logic (PL) via the AMBA AXI4 standard:
1. **Processing System (PS):** The ARM Cortex-A9 core runs the C application, initializes the GIC, handles interrupts, and writes operands to the memory-mapped registers.
2. **AXI Interconnect:** Routes AXI4-Lite transactions from the ARM master to the FPU slave and GPIO peripherals.
3. **Programmable Logic (PL):** Houses the `fpadd_pipelined` module wrapped in an AXI4-Lite interface. 
    * `Register 0 (0x00)`: Control Register. Enable/Disable computation.
    * `Register 4 (0x04)`: Operand A, 32-bit FP.
    * `Register 8 (0x08)`: Operand B, 32-bit FP.

## Repository Structure
* `/hw`: Verilog source files for the FPU (`fpadd_pipelined.v`), debouncers, SSD drivers, and top-level wrappers.
* `/sw`: Bare-metal C application (`btn_interupts.c`) running on the ARM Cortex-A9.
* `/constraints`: XDC file containing the ZedBoard physical pin mappings for LEDs, switches, buttons, and Seven-Segment Displays.

## Development Environment
* **Hardware Design & Synthesis:** Xilinx Vivado 
* **Software Development:** Xilinx Vitis Unified Software Platform
* **Target Board:** ZedBoard Zynq Evaluation and Development Kit (xc7z020clg484-1)
