;; Copyright (c) 2019 - Victor Giovannoni vernalhav@usp.br
;;
;; This is free software and distributed under GNU GPL vr.3. Please
;; refer to the companion file LICENSING or to the online documentation
;; at https://www.gnu.org/licenses/gpl-3.0.txt for further information.

org 0x7c00
jmp main

; ===================================================
; Static variables
; ===================================================
start: db "Enter a number", 0xd, 0xa, 0x0
prime: db "Prime", 0xd, 0xa, 0x0
not_prime: db "Not prime", 0xd, 0xa, 0x0
new_line: db 0xd, 0xa, 0x0
; ===================================================

main:
    mov bx, start
    call printString    ; Prints intro string

    call scanNumber     ; Scans integer from keyboard to BX
    call newLine        ; Prints \r\n

    call isPrime        ; Sets DX to isPrime(bx)
    cmp dx, 0x1         ; if isPrime(bx) == true
    je print_prime      ; print "prime"
    jmp print_not_prime

print_prime:            ; prints "prime"
    mov bx, prime
    call printString
    jmp end

print_not_prime:        ; prints "not prime"
    mov bx, not_prime
    call printString
    jmp end

end:
    jmp main

; ======================================================
; Returns boolean value in DX indicating if BX is prime
; ======================================================
isPrime:
    push ax
    push bx
    push cx

    mov cx, 0x2 ; cx is the counter that will run from 2 to N - 1
    ; If I were trying to be more efficient I'd make it so that it would run until sqrt(n)

primeLoop:
    cmp bx, cx      ; if counter == n
    je resultPrime  ; return true

    mov dx, 0x0     ; Clears divident (was causing error without this line)
    mov ax, bx      ; Moves N to ax so it can be divided
    div cx          ; Divides it by the counter value

    cmp dx, 0x0         ; If remainder == 0
    je resultNotPrime   ; Return false

    add cx, 0x1     ; Increments counter
    jmp primeLoop

resultNotPrime:
    mov dx, 0x0     ; sets dx as 0 (false)
    jmp endPrimeRoutine

resultPrime:
    mov dx, 0x1     ; sets dx as 1 (true)
    jmp endPrimeRoutine

endPrimeRoutine:
    pop cx
    pop bx
    pop ax
    ret

; ======================================================


; ======================================================
; Prints null-terminated string whose address is in BX
; ======================================================
printString:
    push bx
    push cx

    jmp nullLoop
    ; bx is the address register
    ; cx is the char register

nullLoop:
    mov cl, [bx]
    cmp cl, 0x0
    je endPrintString

    call printChar
    add bx, 0x1
    jmp nullLoop

endPrintString:
    pop cx
    pop bx
    ret

newLine:
    ; Prints \r\n
    push bx
    mov bx, new_line
    call printString
    pop bx
    ret

; Prints a single character contained in CL
printChar:
    push ax

    ; Sets arguments for BIOS interrupt
    mov ah, 0x0e
    mov al, cl
    int 0x10

    pop ax
    ret
; ======================================================


; ======================================================
; Reads a 16-bit integer from the keyboard and stores it in BX
; This function does not check if actual numbers are being
; typed, and assumes a \n is the end of the number
;
; Memories of EntradaTeclado.java
; ======================================================
scanNumber:
    push ax
    push cx
    mov bx, 0

scanLoop:
    mov ah, 0x0
    int 0x16    ; Reads a single character from the keyboard

    cmp al, 13  ; Checks if char is '\n'
    je endNumberScan

    mov ah, 0xe ; Immediately prints it on screen (didn't call printChar because it's already in al)
    int 0x10

    movzx dx, al; Stores read digit in dx (zero-extendension from 8 to 16 bits)
    sub dx, '0' ; Transforms ASCII into integer (not checking if it is between '0' and '9')

    imul bx, 0xA

    add bx, dx  ; Adds digit that was just read

    jmp scanLoop

endNumberScan:
    pop cx
    pop ax
    ret
; ======================================================


; ======================================================
; Prints digit stored in CX
; ======================================================
printDigit:
    push cx

    add cx, '0'
    call printChar

    pop cx
    ret
; ======================================================

; Set boot signature correctly
times 510-($-$$) db 0
dw 0xaa55
