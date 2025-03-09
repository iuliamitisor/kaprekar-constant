# Assembly Language Project

This project is an x16 assembly language program designed for execution in a DOS environment.
It allows users to choose between automatic execution and manual input mode. The program includes modular macros and procedures for handling input, output, and numeric processing.

## Features
- User choice between automatic and manual execution modes.
- Utility macros for character input and output.
- Numeric input processing **with validation**.
- Modular design with separate files for macros and procedures.

## File Structure
- `main.asm` – Main program logic.
- `maclib.asm` – Macro definitions for input and output.
- `proclib.asm` – Data definitions and stored messages.

## How to Assemble and Run
1. Assemble with MASM or TASM:
   ```sh
   tasm main.asm
   tlink main.obj
