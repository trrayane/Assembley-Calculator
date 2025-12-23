# Assembley-Calculator 🖥️

![Assembly](https://img.shields.io/badge/Language-Assembly-orange?style=for-the-badge&logo=assembly)
![DOSBox](https://img.shields.io/badge/Platform-DOSBox-lightgrey?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

---

## Overview 🎯

**Assembley-Calculator** is an **8086 Assembly language** project that provides two main functionalities:  

1. **Calculator** – supports arithmetic and logical operations  
2. **Base Converter** – converts between Decimal, Hexadecimal, and Binary  

The program features a **menu-driven interface** with **color-coded output**, **processor flag status display**, and **input validation**.  

---

## Features ✨

### Calculator Operations
- **Arithmetic**: Addition (+), Subtraction (-), Multiplication (*), Division (/)  
- **Logical**: AND (&), OR (|), XOR (x), NAND (n), NOR (o)  

### Base Conversion
- Decimal ↔ Hexadecimal  
- Decimal ↔ Binary  
- Binary ↔ Hexadecimal  

### Additional Features
- Processor **flag status display** (CF, PF, AF, ZF, SF, OF)  
- **Color-coded output**  
- **Interactive menu system**  
- **Input validation**  
- Clear screen functionality  

---

## Requirements ⚙️

- **DOSBox** or similar x86 emulator  
- **MASM** or compatible assembler  

---

## Usage 📝

### Assemble and Link
``bash
masm calculator.asm
link calculator
Run in DOSBox
bash
Copier le code
calculator.exe
Main Menu Options

C → Enter Calculator Mode

B → Enter Base Conversion Mode

Technical Details 🔧
Uses DOS interrupts for I/O operations

Implements conversion algorithms for multiple bases

Displays processor flags after operations

Includes error handling for invalid inputs

Fully menu-driven interface with color output

## Authors 👤

Terki Rayane

GitHub: [trrayane
](https://github.com/trrayane)
Email: rayaneterki55@gmail.com

Discord: tr_rayane

## License 📜

This project is licensed under the MIT License.
