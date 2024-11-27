# ICS3203-CAT2-Assembly-BarasaMichael-150374

# **Assembly Code Programs**
This repository contains assembly language programs that demonstrate basic functionality for specific tasks, such as sensor control, array reversal, conditional display and factorial calculation. Below is an overview of each program, instructions for compiling and running the code, and insights gained during their development.

## **Programs Overview**
### **1. Sensor Control Simulation**
- **Purpose**  
  Simulates the behavior of a system that controls a motor and an alarm based on a sensor's input value.  
  - **Input:** A sensor value (integer).  
  - **Output:** Displays the status of the motor (ON/OFF) and alarm (ON/OFF) based on thresholds:
    - Low Level: Motor ON, Alarm OFF.
    - Moderate Level: Motor OFF, Alarm OFF.
    - High Level: Motor ON, Alarm ON.

### **2. Factorial Calculation**
- **Purpose**  
  Computes the factorial of a user-provided number between 0 and 12.  
  - **Input:** A number within the valid range (0-12).  
  - **Output:** Displays the factorial of the input.  
  Handles invalid inputs gracefully by printing an error message.

### **3. Conditional Logic Program**
- **Purpose**  
  Determines whether an input number is positive, negative, or zero using conditional branching (JE, JL, and JMP). 
  - **Input:** A random number. 
  - **Output:** The appropriate message ("POSITIVE", "NEGATIVE", "ZERO") based on the number's value.

### **4. Array Reversal Program**
- **Purpose**  
  Accepts five single-digit inputs, stores them in an array, reverses the array in place, and prints the reversed array.
  - **Input:** Five digits.  
  - **Output:** Reversed array, character by character, with each element on a new line.

---

## **Compilation and Execution**

### **Requirements**
- A Linux environment with `nasm` (Netwide Assembler) and `ld` (Linker) installed.
- A terminal for input/output.

### **Steps**

**1. Assemble the Code**
Use the `nasm` assembler to convert the `.asm` file into an object file `.o`. For each file:
```bash
nasm -f elf64 array_reversal.asm -o array_reversal.o
nasm -f elf64 conditional.asm -o conditional.o
nasm -f elf64 factorial.asm -o factorial.o
nasm -f elf64 sensor.asm -o sensor.o
```

**2. Link the Object File**
Link the generated object files using the `ld` linker to create executable files `.x`. For each file:
```bash
ld array_reversal.o -o array_reversal.x
ld conditional.o -o conditional.x
ld factorial.o -o factorial.x
ld sensor.o -o sensor.x
```

**3. Run the Program**
Execute the compiled programs. For each file:
```bash
./array_reversal.x
./conditional.x
./factorial.x
./sensor.x
```
---

## **Challenges**

### **Overall Challenges**
1. **Memory Management**
   - Accessing array elements via memory addresses required careful calculation and precision to avoid misalignment or incorrect addressing.
   - Preventing out-of-bounds access was critical to avoid segmentation faults, which required explicit bounds checking and disciplined pointer arithmetic.

2. **Swapping Elements**
   - Swapping array elements necessitated additional memory registers for temporary storage, which increased complexity in register management.
   - Mismanagement of registers during swaps risked data corruption.

3. **Control Flow Logic**
   - Implementing conditional branches for scenarios like threshold evaluation and status updates demanded precise understanding of jump instructions (e.g., `JE`, `JG`, `JMP`).
   - Designing multi-level branching (e.g., for sensor values) without logical conflicts posed additional challenges.

4. **Subroutine Design**
   - The development of utility subroutines (e.g., ASCII-to-integer conversion, factorial calculation) required meticulous handling of registers and stack frames.
   - Ensuring consistency in register states across subroutine calls was non-trivial and critical for program correctness.

5. **Input Validation**
   - Ensuring that user inputs fell within acceptable ranges was essential to prevent invalid memory writes.
   - Converting ASCII inputs to integers required robust handling of edge cases and ensuring the numeric range was preserved.

6. **Precision in Memory Usage**
   - Misalignment of memory (e.g., using a 32-bit memory location for a 64-bit register) introduced risks of overwriting adjacent data.

### **Specific Module Challenges**
- **Reversal Loop**
  - Managing pointers manually while swapping elements presented risks of alignment errors.
  - Avoiding infinite loops or premature termination due to incorrect loop termination logic.

- **Sensor Evaluation Logic**
  - Sequential threshold evaluation via conditional jumps required careful organization to prevent overlapping conditions.
  - Correctly updating motor and alarm statuses based on sensor thresholds added complexity in memory write operations.

- **Status Display**
  - Dynamically selecting and displaying the correct status messages using memory values involved juggling multiple conditional jumps effectively.

---

## **Insights**

### **Memory and Register Management**
- Effective use of registers (e.g., `RAX`, `RBX`) and the stack was crucial for temporary storage and ensuring data consistency.
- Adopting a clear convention for register usage (e.g., preserving `RAX` on the stack before overwriting) reduced errors and made the program more maintainable.

### **Control Flow Optimization**
- Leveraging conditional jumps like `JE` and `JNZ` streamlined program flow, enabling efficient branching without unnecessary checks.
- Unconditional jumps (`JMP`) provided clean exits from sections, reducing redundant code and simplifying logic.

### **Handling Subroutine Complexity**
- Modular design (e.g., dedicated subroutines for conversions, calculations) made the program easier to debug and extend.
- Adhering to consistent calling conventions minimized register corruption between the main program and subroutines.

### **Precision in Pointer Arithmetic**
- Correct pointer calculations were essential for array manipulation and ensured that data remained uncorrupted.
- Using indices to abstract pointer arithmetic improved clarity, especially in complex loops like element reversal.

### **Error Prevention**
- Proactive checks for array bounds and invalid inputs significantly reduced runtime errors.
- Avoiding direct memory writes without validation ensured data integrity.

## **Lessons Learned**
- Investing effort in robust input validation pays dividends in reducing errors in subsequent processing.
- Designing with clear separation between logic, memory management, and I/O simplifies troubleshooting and debugging.
- Assembly programming demands a disciplined approach to resource management and a detailed understanding of the underlying hardware.
