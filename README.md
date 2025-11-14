## Microcoded Blackjack Computer

A fully custom **microprogrammed CPU** built from scratch on a Basys-3 FPGA, complete with a handcrafted **instruction set**, **assembler**, **memory architecture**, **I/O system**, and a fully playable Blackjack game rendered through VGA and controlled with a keyboard. The project spans hardware design, toolchain creation, and full assembly-level game logic.

---

## Skills Demonstrated

* Digital logic design (VHDL)
* Microarchitecture & control logic
* Instruction Set Architecture (ISA) design
* Memory system implementation (uMem, pMem, stack, ROM)
* FPGA development (Basys-3, VGA, keyboard input)
* Writing a complete assembler and program loader
* Assembly-level game logic programming
* Hardware–software co-design
* Simulation, synthesis, and debugging workflows

---

## Project Overview

This project implements a complete **from-scratch microcoded computer** capable of running the card game Blackjack. It is based on an extended version of the Björn Lindskog microprogrammed CPU architecture from Linköping University.

### CPU Architecture

* 16-bit register and memory width
* Microcoded control unit and instruction decoding
* ALU with flag control (Z, N, C, V)
* Stack-based subroutine handling (PUSH, POP, JSR, RET, IRET)
* Bootloader initialization via UART
* ROM-based microcode for deterministic execution

### Instruction Set

The ISA includes arithmetic, logic, branching, memory access, and stack operations. Example instructions:
`ADD`, `ADDI`, `CMP`, `LDI`, `LD`, `ST`, `BEQ`, `BNE`, `JSR`, `RET`, `ORI`, `ANDI`, etc.

A custom **assembler** translates human-readable assembly into executable machine code.

### Blackjack Game Implementation

* 6 decks (312 cards) encoded in primary memory
* Shuffle system using randomized shuffle vectors
* Complete game loop written in assembly
* VGA text-mode rendering
* Keyboard input for hits, stands, and menu navigation
* Tile-based graphics stored in ROM

### Graphics & I/O

* VGA output (640×480) with tile rendering
* USB/PS2 keyboard interface
* Support for future sprite animations