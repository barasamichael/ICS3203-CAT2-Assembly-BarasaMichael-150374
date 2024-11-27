; PROGRAM OVERVIEW
; ================
; This assembly program simulates a simple sensor-based control system that 
; evaluates sensor input and adjusts the status of a motor and alarm accordingly. 
; The actions taken are determined by the sensor input value compared against 
; defined thresholds (HIGH_LEVEL and MODERATE_LEVEL).
; 
; STEPS
; =====
; 
; Prompting for Sensor Input
; --------------------------
; Writes a prompt message (Enter sensor value: ) to standard output 
; 	using a syscall (system write).
; The prompt text is stored in the .data section, and its memory location is 
; 	passed in the rsi register to the syscall.
;
; Reading User Input
; ------------------ 
; Reads the user input (up to 10 characters) into a buffer input_buffer using a syscall (sys_read).
; The input_buffer is defined in the .data section as a 10-byte array. It holds the user’s input temporarily.
;
; Converting Input to Integer
; ---------------------------
; The input (ASCII digits) is converted to an integer using a subroutine (atoi).
; The subroutine processes each character in input_buffer sequentially.
; It uses registers and arithmetic instructions to compute the numeric value.
;
; Storing and Reading Sensor Value
; -------------------------------- 
; The sensor value is stored in sensor_value, a 32-bit location in the .data section.
; The eax register, which contains the result of atoi, is moved into the memory 
; 	location reserved for sensor_value.
;
; Evaluating Sensor Value
; ----------------------- 
; The sensor value is compared to thresholds (HIGH_LEVEL = 80, MODERATE_LEVEL = 
; 	50) using cmp and conditional jump instructions (jg, je).
; +------------+
; | Logic Flow |
; +------------+
; * If the sensor value > 80, the program jumps to the high_level label.
; * If the sensor value > 50 but <= 80, it jumps to moderate_level.
; * Otherwise, it executes the low_level block.
;
; Adjusting Motor and Alarm Status
; -------------------------------- 
; - Low Level: Motor ON (motor_status = 1), Alarm OFF (alarm_status = 0).
; - Moderate Level: Both OFF (motor_status = 0, alarm_status = 0).
; - High Level: Both ON (motor_status = 1, alarm_status = 1).
;
; Memory Handling
; ---------------
; The program writes the statuses directly to memory locations (motor_status 
; 	and alarm_status).
; These are defined in the .data section as single bytes.

; Displaying Status
; -----------------
; The program prints the motor and alarm statuses (either ON or OFF) based on 
; 	their memory values.
; For the port interaction the status messages are output via system write.
; For example, on_msg or off_msg is selected based on the value of motor_status 
;	and alarm_status.
;
; Exiting the Program
; ------------------- 
; The program terminates cleanly using the system exit syscall.

; HANDLING CHALLENGES
; ===================

; Efficient Memory Access
; -----------------------
; 1. Direct memory manipulation required precise addressing.
; 2. Correct alignment of data (e.g., 32-bit for sensor_value and 8-bit for 
; 	motor_status) was crucial to avoid unintended overwrites.
;
; Threshold Comparison Logic
; -------------------------- 
; Implementing multiple thresholds with jumps (cmp and jg) involved careful 
; 	organization of the conditions to avoid logic errors.
;
; Subroutines for Integer Operations
; ----------------------------------
; Conversion of ASCII to integers (atoi) and the use of arithmetic in assembly 
; 	are non-trivial.
; Mismanagement of registers during these operations could corrupt data.
; 
; Status Display Logic
; --------------------
;Using conditional jumps (je, jmp) to select between ON and OFF messages added 
; 	complexity in branching.
global _start

section .data
    sensor_value    dd 0        ; Simulated sensor input
    motor_status    db 0        ; Motor status: 0=OFF, 1=ON
    alarm_status    db 0        ; Alarm status: 0=OFF, 1=ON

    HIGH_LEVEL      equ 80
    MODERATE_LEVEL  equ 50

    prompt          db 'Enter sensor value: ', 0
    input_buffer    db 10 dup(0)
    motor_msg       db 'Motor Status: ', 0
    alarm_msg       db 'Alarm Status: ', 0
    on_msg          db 'ON', 10, 0
    off_msg         db 'OFF', 10, 0

section .bss
    ; Uninitialized data section

section .text
_start:
    ; Prompt for sensor value
    mov     rax, 1                  ; system write
    mov     rdi, 1                  ; standard output
    mov     rsi, prompt
    mov     rdx, 20                 ; Length of the prompt
    syscall

    ; Read user input
    mov     rax, 0                  ; sys_read
    mov     rdi, 0                  ; stdin
    mov     rsi, input_buffer
    mov     rdx, 10
    syscall

    ; Convert input to integer
    mov     rsi, input_buffer
    call    atoi                    ; Result in RAX

    ; Store sensor value
    mov     [sensor_value], eax

    ; Read sensor value
    mov     eax, [sensor_value]

    ; Determine actions based on sensor value
    cmp     eax, HIGH_LEVEL
    jg      high_level

    cmp     eax, MODERATE_LEVEL
    jg      moderate_level

low_level:
    ; Low level: Motor ON, Alarm OFF
    mov     byte [motor_status], 1
    mov     byte [alarm_status], 0
    jmp     display_status

moderate_level:
    ; Moderate level: Motor OFF, Alarm OFF
    mov     byte [motor_status], 0
    mov     byte [alarm_status], 0
    jmp     display_status

high_level:
    ; High level: Motor ON, Alarm ON
    mov     byte [motor_status], 1
    mov     byte [alarm_status], 1

display_status:
    ; Display motor status
    mov     rax, 1                  ; system write
    mov     rdi, 1                  ; standard output
    mov     rsi, motor_msg
    mov     rdx, 14
    syscall

    mov     al, [motor_status]
    cmp     al, 1
    je      motor_on
    jmp     motor_off

motor_on:
    mov     rax, 1                  ; system write
    mov     rdi, 1                  ; standard output
    mov     rsi, on_msg
    mov     rdx, 3
    syscall
    jmp     display_alarm

motor_off:
    mov     rax, 1                  ; system write
    mov     rdi, 1                  ; standard output
    mov     rsi, off_msg
    mov     rdx, 4
    syscall

display_alarm:
    ; Display alarm status
    mov     rax, 1                  ; system write
    mov     rdi, 1                  ; standard output
    mov     rsi, alarm_msg
    mov     rdx, 13
    syscall

    mov     al, [alarm_status]
    cmp     al, 1
    je      alarm_on
    jmp     alarm_off

alarm_on:
    mov     rax, 1                  ; system write
    mov     rdi, 1                  ; standard output
    mov     rsi, on_msg
    mov     rdx, 3
    syscall
    jmp     exit_program

alarm_off:
    mov     rax, 1                  ; system write
    mov     rdi, 1                  ; standard output
    mov     rsi, off_msg
    mov     rdx, 4
    syscall

exit_program:
    ; Exit the program
    mov     rax, 60                 ; system exit
    xor     rdi, rdi
    syscall

; Subroutine: ASCII to Integer Conversion (atoi)
atoi:
    xor     rax, rax                ; Clear RAX
    xor     rbx, rbx                ; Clear RBX for temporary storage
    mov     rbx, 10                 ; Multiplier (base 10)

atoi_loop:
    movzx   rcx, byte [rsi]         ; Load the next character
    cmp     rcx, 10                 ; Check for newline
    je      atoi_done
    sub     rcx, '0'                ; Convert ASCII to digit
    imul    rax, rbx                ; Multiply current value by 10
    add     rax, rcx                ; Add digit to result
    inc     rsi
    jmp     atoi_loop

atoi_done:
    ret
