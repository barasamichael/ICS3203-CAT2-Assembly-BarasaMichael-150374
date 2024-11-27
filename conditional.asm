; Documentation: Control Flow and Conditional Logic 
; -------------------------------------------------
;
; 1. JE (Jump if Equal) in "output_zero" case:
;    - After comparing EAX (the converted number) with 0, JE is used to
;      directly jump to the "output_zero" label.
;
; 2. JL (Jump if Less) in "output_negative" case:
;    - After the CMP instruction, JL checks if the value in EAX is less than 0 
;      ensuring branching to the NEGATIVE case when the number is negative.
;
; 3. Unconditional JMP for flow control:
;    - JMP is used after handling each case (POSITIVE, NEGATIVE, ZERO) to
;      direct program execution to "exit_program".

global _start

section .data
    prompt          db 'Enter a number: ', 0
    positive_msg    db 'The number is POSITIVE', 10, 0
    negative_msg    db 'The number is NEGATIVE', 10, 0
    zero_msg        db 'The number is ZERO', 10, 0
    input_buffer    db 10 dup(0)

section .bss
    ; unused

section .text
_start:
    ; Prompt the user
    mov     eax, 4              ; system write
    mov     ebx, 1              ; standard output
    mov     ecx, prompt
    mov     edx, 15             ; The length of the prompt
    int     0x80

    ; Read user input
    mov     eax, 3              ; system read
    mov     ebx, 0              ; standard input
    mov     ecx, input_buffer
    mov     edx, 10             ; Read upto 10 bytes of data
    int     0x80

    ; Convert input string to integer
    mov     esi, input_buffer
    call    atoi                ; Store result in EAX

    ; Compare EAX to zero
    cmp     eax, 0
    je      output_zero         ; Jump if equal to zero
    jl      output_negative     ; Jump if less than zero
    ; If greater than zero, fall through to positive case

output_positive:
    ; Output "POSITIVE" message
    mov     eax, 4              ; system write
    mov     ebx, 1              ; standard output
    mov     ecx, positive_msg
    mov     edx, 23             ; Length of the message
    int     0x80
    jmp     exit_program        ; Exit after displaying message

output_negative:
    ; Output "NEGATIVE" message
    mov     eax, 4              ; system write
    mov     ebx, 1              ; standard output
    mov     ecx, negative_msg
    mov     edx, 23
    int     0x80
    jmp     exit_program        ; Exit the program after displaying message

output_zero:
    ; Output "ZERO" message
    mov     eax, 4              ; system write
    mov     ebx, 1              ; standard output
    mov     ecx, zero_msg
    mov     edx, 19
    int     0x80

exit_program:
    ; Exit the program
    mov     eax, 1              ; sys_exit
    xor     ebx, ebx
    int     0x80

; Subroutine: ASCII to Integer Conversion (atoi)
atoi:
    ; Convert the ASCII string at ESI to an integer in EAX
    xor     eax, eax            ; Clear EAX (result)
    xor     ebx, ebx            ; Clear EBX (sign flag)
    ; Use ECX as a temporary register for the digit value

atoi_loop:
    lodsb                       ; Load byte at [ESI] into AL and increment ESI
    cmp     al, 0x0A            ; Check for newline (Enter key)
    je      atoi_done           ; Exit loop if newline is found
    cmp     al, 0x00            ; Check for null terminator
    je      atoi_done           ; Exit loop if null terminator is found
    cmp     al, '-'             ; Check for a minus sign
    jne     atoi_digit_check    ; If not '-', check for digit
    inc     ebx                 ; Mark as negative if '-' is found
    jmp     atoi_loop           ; Continue loop

atoi_digit_check:
    cmp     al, '0'             ; Check if character is less than '0'
    jl      atoi_done           ; If less, exit
    cmp     al, '9'             ; Check if character is greater than '9'
    jg      atoi_done           ; If greater, exit
    sub     al, '0'             ; Convert ASCII to numeric value
    imul    eax, 10             ; Multiply current result by 10
    movzx   ecx, al             ; Move digit value into ECX (zero-extend)
    add     eax, ecx            ; Add digit value to EAX
    jmp     atoi_loop           ; Continue loop

atoi_done:
    test    ebx, ebx            ; Check if the number is negative
    jz      atoi_end            ; If not negative, skip negation
    neg     eax                 ; Negate the result if negative

atoi_end:
    ret
