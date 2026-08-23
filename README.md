# Pipelined AES-128 Encryption

A hardware implementation and optimization of **AES-128 encryption** in Verilog, developed as a course project for **CS666: Hardware Security for Internet-of-Things at IIT Kanpur**.

## Project Overview

The project focuses on optimizing AES-128 encryption for hardware by designing a pipelined datapath and addressing the throughput and critical-path limitations of an iterative implementation.

## Key Work

- Implemented **AES-128 encryption** in Verilog for the **PYNQ-Z1** board.
- Designed a **fully pipelined AES datapath** with parallel key expansion.
- Applied **fine-grained pipelining** to SubBytes and KeyExpansionRound to reduce critical-path delay.
- Evaluated the optimized design using **Vivado and Vitis** on the PYNQ-Z1 platform.

## Results

- Increased synthesized AES-core frequency from **10 MHz to 375 MHz**.
- Achieved **128-bit block throughput per clock cycle** after pipeline fill.
- Achieved **27.5 Gbps system throughput at 215 MHz**.
- Achieved an initial latency of **76 ns**.

## Repository Structure

```text
CS666_Project/
├── AES128_Encryption_Verilog-r1/
├── AES128_Encryption_Verilog-r2/
├── AES128_Encryption_Verilog-r3/
├── AES128_Encryption_Verilog-r4/
├── CS666_AES.pdf
└── README.md
