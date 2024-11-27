; Challenges
;-----------
; Accessing array elements via memory addresses required carefull consideration
; Out-of-bounds (Segmentation error) was a head-ache
; Swapping elements was not straightforward and required additional memory address


section .data
    prompt db "Enter a single digit (0-9): ", 0       ; Prompt user for input
    prompt_len equ $ - prompt                         ; Calculate length of prompt string
    newline db 10                                     ; Newline character for printing
    invalid_input_msg db "Invalid input! Please enter a digit (0-9).", 0   ; Error message for invalid input
    invalid_input_len equ $ - invalid_input_msg       ; Calculate length of invalid input message

section .bss
    array resb 5    ; Reserve 5 bytes for array where we will store digits
    input resb 2    ; Reserve 2 bytes for input buffer (character + newline)

section .text
    global _start

_start:
    ; Initialize array index (r12 serves as a counter to store digits in array)
    xor r12, r12    ; Clear r12 register to use it as an index (0 to 4)

input_loop:
    ; Print prompt to enter a digit (0-9)
    mov rax, 1      ; system write
    mov rdi, 1      ; standard output
    mov rsi, prompt ; Address of prompt string
    mov rdx, prompt_len  ; Length of prompt string
    syscall         ; Perform syscall to print the prompt

    ; Read character from user input
    mov rax, 0      ; system read
    mov rdi, 0      ; standard input
    mov rsi, input  ; Address of input buffer
    mov rdx, 2      ; Read 2 bytes (character + newline)
    syscall         ; Perform syscall to read input

    ; Check if input is a valid digit (0-9)
    mov al, [input]      ; Load input character into al register
    cmp al, '0'          ; Compare with ASCII value of '0'
    jl invalid_input     ; Jump to invalid_input label if less than '0'
    cmp al, '9'          ; Compare with ASCII value of '9'
    jg invalid_input     ; Jump to invalid_input label if greater than '9'

    ; Store valid character in array at index r12
    mov [array + r12], al    ; Store input digit in the array at position r12
    inc r12                  ; Increment r12 to point to next index in the array

    ; Check if we need more input (we need exactly 5 digits)
    cmp r12, 5
    jl input_loop          ; If r12 is less than 5, continue loop for more input

    ; Reverse array in place using two pointers (left and right indices)
    mov r12, 0      ; Left index (r12 = 0)
    mov r13, 4      ; Right index (r13 = 4, as we have 5 elements)

reverse_loop:
    ; Check if left index is greater than or equal to right index (exit loop)
    cmp r12, r13
    jge print_array  ; If left index >= right index, exit reversal loop and print array

    ; Step 1: Swap elements at r12 (left index) and r13 (right index)
    mov al, [array + r12]    ; Load left element (r12) from array into the al register
    mov bl, [array + r13]    ; Load right element (r13) from array into the bl register

    ; Step 2: Store swapped elements
    mov [array + r12], bl    ; Store value from the right index (bl) in the left index (r12)
    mov [array + r13], al    ; Store value from the left index (al) in the right index (r13)

    ; Step 3: Move indices towards each other (left index increases, right index decreases)
    inc r12                  ; Increment left index (r12) to move towards the center of the array
    dec r13                  ; Decrement right index (r13) to move towards the center of the array

    ; Step 4: Repeat loop until left index is greater than or equal to right index
    jmp reverse_loop         ; Continue loop to reverse the next pair of elements

print_array:
    ; Print reversed array
    mov r12, 0              ; Reset counter to start printing from the first index of the array

print_loop:
    ; Get character from array at index r12
    mov al, [array + r12]
    mov [input], al         ; Store it in input buffer

    ; Print character
    mov rax, 1              ; sys_write system call number (1 = write)
    mov rdi, 1              ; File descriptor for stdout (1 = standard output)
    mov rsi, input          ; Address of input buffer
    mov rdx, 1              ; Print 1 byte (1 character)
    syscall                 ; Perform syscall to print the character

    ; Print newline after each character
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Increment index and check if all characters have been printed
    inc r12
    cmp r12, 5
    jl print_loop           ; Continue printing if we haven't reached end of the array

exit:
    mov rax, 60            ; sys_exit system call number (60 = exit)
    xor rdi, rdi           ; Exit status code 0 (successful)
    syscall                 ; Perform syscall to exit

invalid_input:
    ; Print invalid input message
    mov rax, 1             ; sys_write system call number (1 = write)
    mov rdi, 1             ; File descriptor for stdout (1 = standard output)
    mov rsi, invalid_input_msg
    mov rdx, invalid_input_len
    syscall

    ; Restart input loop after invalid input
    jmp input_loop
