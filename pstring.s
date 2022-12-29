# 208968560 Dan Saada
# Ex3
# Compile with: gcc pstring.s

    .data

	.section	.rodata		    # read only data section
format_invalid_input: .string "invalid input!\n"

    .text

.global pstrlen
.type pstrlen, @function
# This function receives a pointer to a Pstring and returns the length of the Pstring's string.
# rdi = Pstring pointer
pstrlen:
    pushq   %rbp                # save the old frame pointer
    movq    %rsp,%rbp           # create the new frame pointer
    
    movzbq  (%rdi),%rax         # rax = pstring length (In the lower address, the size of the string is stored in one byte)
    
    movq    %rbp,%rsp           # restore the old stack pointer - release all used memory
    popq    %rbp                # restore old frame pointer (the caller function frame)
    ret                         # return to caller function

.global replaceChar
.type replaceChar, @function
# This function receives a pointer to a Pstring and two chars, and replaces each instance of oldChar with newChar.
# The function returns a pointer to the Pstring (after the changing of the string).
# rdi = pstring pointer, rsi = old char, rdx = new char
replaceChar:
    pushq   %rbp                # save the old frame pointer
    movq    %rsp,%rbp           # create the new frame pointer

    movq    %rdi,%rax           # saving the returned pointer to the Pstring in rax
    movzbq  (%rdi),%rcx         # rcx = string's length

.replaceChar_condition:
    cmpq    $0,%rcx             # while rcx > 0 --> goto statement of the loop
    jg .replaceChar_statement   # else continue
    
    movq    %rbp,%rsp           # restore the old stack pointer - release all used memory
    popq    %rbp                # restore old frame pointer (the caller function frame)
    ret                         # return to caller function

.replaceChar_statement:
    incq     %rdi               # go to the next char (at the first iteration basicaly skips the stored length)
    movzbq  (%rdi),%r8          # r8 = current char
    decq     %rcx               # decrease length of the string by 1
    cmpb    %r8b,%sil           # compare between current char and old char
    jne .replaceChar_condition  # if they are not equal --> goto loop condition
    movb    %dl,(%rdi)          # else, current char = new char
    jmp .replaceChar_condition  # end of loop --> goto loop condition

.global pstrijcpy
.type pstrijcpy, @function
# This function receives two pointers to Pstring, and two chars i and j, and first of all checks the validation of the parameters.
# Then the function copies the src substring p2[i:j] into the dst string p1 in the position p1[i:j].
# After the insertion the function returns a pointer to p1.
# rdi = p1, rsi = p2, rdx = i, rcx = j
pstrijcpy:
    pushq   %rbp                # save the old frame pointer
    movq    %rsp,%rbp           # create the new frame pointer
    
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    movq    %rdi,%r12           # r12 = p1
    movq    %rsi,%r13           # r13 = p2
    movq    %rdx,%r14           # r14 = i
    movq    %rcx,%r15           # r15 = j

    call    is_valid            # check if args are valid
    cmpq    $1,%rax             # compare rax (returned value from is_valid) to 1
    je  .cpy                    # if rax = 1 (the args are valid) --> goto lable cpy

.pstrijcpy_return:
    movq   %r12,%rax            # rax = p1
    popq   %r15
    popq   %r14
    popq   %r13
    popq   %r12

    movq    %rbp,%rsp           # restore the old stack pointer - release all used memory
    popq    %rbp                # restore old frame pointer (the caller function frame)
    ret                         # return to caller function

.cpy:
    movq    %r12,%rdi           # rdi = p1
    movq    %r13,%rsi           # rsi = p2
    movq    %r14,%rdx           # rdx = i
    movq    %r15,%rcx           # rcx = j

    leaq    (%rdi,%rdx),%rdi    # rdi = p1[i]           
    leaq    (%rsi,%rdx),%rsi    # rsi = p2[i]
    subq    %rdx, %rcx          # rcx = j - i

.pstrijcpy_while:
    incq    %rdi                # go to the next char
    incq    %rsi                # go to the next char
    movzbq  (%rsi),%r8          # r9 = p2[i] char
    movb    %r8b,(%rdi)         # p1[i] = p2[i]
    decq    %rcx                # rcx--
    cmpq    $0, %rcx            # compare 0 to remainning length
    jge .pstrijcpy_while        # if rcx >= 0 --> loop again
    
    jmp .pstrijcpy_return       # when exiting the while loop go to the return lable

.global swapCase
.type swapCase, @function
# This function replace every uppercase English letter (A-Z) with an lowercase English letter (a-z).
# In a similar way replace each lowercase English letter with an uppercase English letter.
# ASCII characters that are not letters can also appear in the string, and won't be change.
# rdi = Pstring pointer
swapCase:
    pushq   %rbp                # save the old frame pointer
    movq    %rsp,%rbp           # create the new frame pointer

    movzbq  (%rdi),%rdx         # rdx = pstring length
    movq    %rdi,%rax           # rax = pstring address

.swapCase_condition:             
    cmpq    $0,%rdx             # compare 0 to remainning length
    jg  .swapCase_statement     # if rdx > 0 --> goto statement

.swapCase_return:  
    movq    %rbp,%rsp           # restore the old stack pointer - release all used memory
    popq    %rbp                # restore old frame pointer (the caller function frame)
    ret                         # return to caller function

.swapCase_statement:
    incq    %rdi                # go to the next char
    movzbq  (%rdi),%r8          # r8 = current char
    cmpb    $64,%r8b            # compare the ASCII value of current char with 64
    ja  .greater_then_64        # if current char > 64 --> goto lable greater_then_64

    decq    %rdx                # rdx-- (decrease pstring's length)
    jmp .swapCase_condition     # else, loop again

.greater_then_64:
    cmpb    $90,%r8b            # compare the ASCII value of current char with 90
    ja  .greater_then_90        # if current char > 90 --> goto lable greater_then_90
    addq    $32,(%rdi)          # else (64 < current char < 90) --> change upper case to lower case by adding 32
    jmp .decrease_length        # goto decrease rdx and continue to the next character

.greater_then_90:
    cmpb    $96, %r8b           # compare the ASCII value of current char with 96
    ja  .greater_then_96        # if current char > 96 --> goto lable greater_then_96
    jmp .decrease_length        # else, goto decrease rdx and continue to the next character

.greater_then_96:
    cmpb    $123, %r8b          # compare the ASCII value of current char with 123
    jb  .upper_case             # if 96 < current char < 123 --> upper case it. 
    jmp .decrease_length        # else, goto decrease rdx and continue to the next character

.upper_case:
    subb    $32,(%rdi)          # subtract 32 from lower case letter to make it upper case 

.decrease_length:
    decq    %rdx                # rdx-- (decrease pstring's length)
    jmp .swapCase_condition     # goto check condition again

.global pstrijcmp
.type pstrijcmp, @function
# This function receives two pointers to Pstring, and two chars i and j, and first of all checks the validation of the parameters.
# Then the function compares between the substrings p1[i:j] and p2[i:j].
# After the comparation the function returns: 1: if the ASCII lexicographic value of p1[i:j] > p2[i:j]
#                                            -1: if the ASCII lexicographic value of p1[i:j] < p2[i:j]
#                                             0: if the ASCII lexicographic value of p1[i:j] = p2[i:j]
#                                            -2: if the indices i or j exceed the limits of p1 and p2 length ("invalid input" message would be printed)
# rdi = p1, rsi = p2, rdx = i, rcx = j
pstrijcmp:
    pushq   %rbp                # save the old frame pointer
    movq    %rsp,%rbp           # create the new frame pointer

    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    movq    %rdi,%r12           # r12 = p1
    movq    %rsi,%r13           # r13 = p2
    movq    %rdx,%r14           # r14 = i
    movq    %rcx,%r15           # r15 = j

    call    is_valid            # check if args are valid
    cmpq    $1,%rax             # compare rax (returned value from is_valid) to 1
    je  .cmp                    # if rax = 1 (the args are valid) --> goto lable cmp

    popq   %r15
    popq   %r14
    popq   %r13
    popq   %r12

    movq    $-2,%rax            # else, rax = -2 and return
    movq    %rbp,%rsp           # restore the old stack pointer - release all used memory
    popq    %rbp                # restore old frame pointer (the caller function frame)
    ret                         # return to caller function

.cmp:
    movq    %r12,%rdi           # rdi = p1
    movq    %r13,%rsi           # rsi = p2
    movq    %r14,%rdx           # rdx = i
    movq    %r15,%rcx           # rcx = j
    
    leaq    1(%rdi,%rdx),%rdi   # rdi = p1[i]           
    leaq    1(%rsi,%rdx),%rsi   # rsi = p2[i]
    subq    %rdx,%rcx           # rcx = j - i

.pstrijcmp.compare:
    movzbq  (%rdi), %r8         # r8 = p1[i]
    movzbq  (%rsi), %r9         # r9 = p2[i]
    cmpb    %r9b, %r8b
    je  .pstrijcmp_condition    # if p1[i]=p2[i] --> goto next char
    ja  .p1_is_greater          # elif p1[i]>p2[i] -->  goto p1_is_greater
    movq    $-1, %rax           # else (p2 is greater), rax = -1
    
.pstrijcmp_return:
    popq   %r15
    popq   %r14
    popq   %r13
    popq   %r12

    movq    %rbp,%rsp           # restore the old stack pointer - release all used memory
    popq    %rbp                # restore old frame pointer (the caller function frame)
    ret                         # return to caller function
    
.p1_is_greater:
    movq    $1, %rax            # rax = 1
    jmp .pstrijcmp_return       # goto return lable

.pstrijcmp_condition:
    incq    %rsi                # go to next char on p2
    incq    %rdi                # go to next char on p1
    decq    %rcx                # rcx--
    cmpq    $0,%rcx             # compare 0 to remainning length
    jge .pstrijcmp.compare      # if rcx >= 0 --> go to next char
    
    movq    $0, %rax            # else, strings are equal
    jmp .pstrijcmp_return       # goto return lable

.global is_valid
.type is_valid, @function
# This function is an auxiliary function that checks if the recived args are valid
# Specifically checking: if i and j are in the p1 and p2 bounds
#                        if i<j
# The function returns: 1: if valid
#                      -2: if not valid 
# rdi = p1, rsi = p2, rdx = i, rcx = j
is_valid:
    pushq   %rbp                # save the old frame pointer
    movq    %rsp,%rbp           # create the new frame pointer
    
    movzbq  (%rsi), %r10        # r10 = p2 length
    cmpb    %r10b,%dl           # compare between i and p2's length
    jge     .invalid_input      # if i >= p2's length --> goto invalid_input
    cmpb    %r10b,%cl           # compare between j and p2's length
    jge     .invalid_input      # if j >= p2's length --> goto invalid_input

    movzbq  (%rdi), %r10        # r10 = p1 length
    cmpb    %r10b,%dl           # compare between i and p1's length
    jge     .invalid_input      # if i >= p1's length --> goto invalid_input
    cmpb    %r10b,%cl           # compare between j and p1's length
    jge     .invalid_input      # if j >= p1's length --> goto invalid_input
    
    cmpq     %rdx, %rcx         # compare between i and j  
    jl      .invalid_input      # if i > j --> goto invalid_input
    
    movq    $1, %rax            # rax = 1 passed all checks so return that args are valid

.is_valid_return:
    movq    %rbp,%rsp           # restore the old stack pointer - release all used memory
    popq    %rbp                # restore old frame pointer (the caller function frame)
    ret                         # return to caller function

.invalid_input:
    movq    $format_invalid_input,%rdi       
    xorq    %rax,%rax           # rax = 0
    call    printf              # prints : "invalid input!"
    movq    $-2,%rax            # rax = -2
    
    jmp .is_valid_return        # return
