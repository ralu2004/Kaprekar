# 🔢 Kaprekar's Constant Finder

**An x86 Assembly program that demonstrates the iterative process of reaching Kaprekar's constant (6174) from any four-digit number.**

---

## 📌 Overview

This project showcases an x86 Assembly implementation that takes a four-digit number and applies Kaprekar's routine until it converges to the constant 6174. The program also tracks the number of iterations required to reach this constant.

---

## 🔍 How It Works

Kaprekar's routine involves the following steps:

1. **Arrange the digits** of the number in descending and ascending order to form two new numbers.
2. **Subtract** the smaller number from the larger number.
3. **Repeat** the process with the result until the number 6174 is obtained.

For example, starting with the number 3524:

- 5432 (descending) - 2345 (ascending) = 3087
- 8730 - 378 = 8352
- 8532 - 2358 = 6174

---

## 🛠 Project Structure
```bash
Kaprekar/
├── README.md # Project documentation
├── DATA.TXT # Output file: the number of iterations for each 4-digit number
├── maclib.asm # Assembly macros
├── main.asm # Main program logic
└── proclib.asm # Procedure library
```

---

## ⚙️ Requirements

- **Assembler**: [NASM](https://www.nasm.us/)
- **Debugger/Emulator**: [DOSBox](https://www.dosbox.com/) or [EMU8086](http://www.emu8086.com/)
- **Operating System**: Windows/Linux/MacOS (with DOS emulator)

--- 

## 🚀 How to Run
# Option 1: Using DOSBox (classic)
1. **Clone the repository**:
   ```bash
   git clone https://github.com/ralu2004/Kaprekar.git
   cd Kaprekar
   ```
2. **Assemble the program:**
   ```bash
   nasm -f bin main.asm -o kaprekar.com
   ```
3. **Run the program using a DOS emulator:**
   ```bash
   dosbox kaprekar.com
   ```
4. **Input a four-digit number (e.g., 3524) when prompted.**

# Option 2: Using Visual Studio Code
1. **Open the project in VS Code.**
2. **Assemble main.asm with NASM (either in the terminal or using an extension):**
```bash
nasm -f bin main.asm -o kaprekar.com
```
3. **Run the resulting .com file:**
  Directly in the terminal, or
  Using an x86 emulator/extension inside VS Code.

4. **Enter a four-digit number when prompted. The program will iterate until it reaches Kaprekar’s constant 6174.**
   
--- 

##📄 License

This project is licensed under the MIT License.

---

##📬 Contact
GitHub profile: https://github.com/ralu2004

