# 208968560 Dan Saada
# Ex3
# Compile with: gcc func_select.s

    .data

	.section	.rodata		    # read only data section
        s:       .string "%s"
        d:       .string "%d"
format_31:       .string "first pstring length: %d, second pstring length: %d\n"
format_32:       .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
format_35_36:    .string "length: %d, string: %s\n"
format_37:       .string "compare result: %d\n"
format_def:      .string "invalid option!\n"

      .align 8                  # align address to multiple of 8
    .L_SWITCH:
   .quad .L31
   .quad .L32
   .quad .L33
   .quad .L34
   .quad .L35
   .quad .L36
   .quad .L37
   .quad .L_DEF

    .text
    
 .global run_func
 .type run_func, @function
# This function gets two pstrings and  auser's choice for an action and with the help of
# a switch case preform the requested task.
# rdi = user's choice, rsi = p1, rdx = p2
 run_func:
    pushq   %rbp                # save the old frame pointer
    movq    %rsp,%rbp           # create the new frame pointer 

    pushq   %r12
    pushq   %r13
    movq    %rsi,%r12           # r12 points to p1
    movq    %rdx,%r13           # r13 points to p2
    pushq   %r14
    pushq   %r15

    leaq    -31(%rdi),%rdi      # compute user's choice x = x - 31
    cmpq    $6,%rdi             # compare x and 6 (actually does %rdi-6)
    ja .L_DEF                   # ja is related to unsigned numbers, that is:
                                # rdi > 6 --> goto L_DEF 
                                # rdi < 0 --> goto L_DEF
    cmpq    $4,%rdi             # if the user choose case L35, go to case L37
    je  .L37                    # the logic of the beginning of L35 and L37 are similar                            
    jmp    *.L_SWITCH(,%rdi,8)  # goto address of lable L_SWITCH + 8*X

# Using the pstrlen function, calculate the length of the two pstrings and print their lengths.
.L31:
    movq    %r12,%rdi           # rdi = p1
    call    pstrlen             # get p1 length
    movq    %rax,%r14           # r14 = p1 length

    movq    %r13,%rdi           # rdi = p2
    call    pstrlen             # get p2 length
    movq    %rax,%rdx           # rdx = p2 length
    movq    %r14,%rsi           # rsi = p1 length

    movq	$format_31,%rdi	    # the string is the first paramter passed to the printf function
    xorq    %rax,%rax           # rax = 0
    call    printf              # print wanted string
    jmp .func_select_return     # goto return lable

# Receiving two characters from the user: oldChar - the character that needs to be replaced
#                                         newChar - the new character 
# Using the replaceChar function, replace in both strings each instance of oldChar in newChar and print them.
.L32:
    subq    $16,%rsp            # creating a scope on the stack for saving user input
    movq    $s,%rdi             # reading format
    leaq    -16(%rbp),%rsi      # set scanf to save input in -16(%rbp)
    xorq    %rax,%rax           # rax = 0
    call    scanf               # -16(%rbp) = old char
    movq    -16(%rbp),%r14      # r14 = old char
    
    movq    $s,%rdi             # reading format
    leaq    -8(%rbp),%rsi       # set scanf to save input in -8(%rbp)
    xorq    %rax,%rax           # rax = 0
    call    scanf               # -8(%rbp) = new char
    movq    -8(%rbp),%r15       # r15 = new char
    
    movq    %r12,%rdi           # rdi = p1  
    movq    %r14,%rsi           # rsi = old char
    movq    %r15,%rdx           # rdx = new char
    call    replaceChar         # replace old char with new char in p1
              
    movq    %r13,%rdi           # rdi = p2
    movq    %r14,%rsi           # rsi = old char
    movq    %r15,%rdx           # rdx = new char
    call    replaceChar         # replace old char with new char in p2

    movq    %rax,%r8            # r8 = p2 after replaceChar 
    leaq    1(%r8),%r8          # r8 = p2's string
    movq    %r12,%rcx           # rcx = p1 after replaceChar 
    leaq    1(%rcx),%rcx        # rcx = p1's string (The string is stored in the following addresses after the first byte)

    movq    %r14,%rsi           # rsi = old char
    movq    %r15,%rdx           # rdx = new char
    movq    $format_32,%rdi     # printing format
    xorq    %rax,%rax           # rax = 0
    call    printf              # print wanted string
    jmp .func_select_return     # goto return lable

# Same as L32
.L33:
    jmp .L32                    # goto lable L32

# There isn't an option for the user to insert 34 --> goto default
.L34:
    jmp .L_DEF                  # jump to default

# After receiving from the user two numbers (in lable L37): i - a start index
#                                                           j - an end index
# Call the pstrijcpy function, with i and j, which copies the substring  p2[i:j] (source) into p1[i:j] (destination).
# After the replacement print p1 and p2 with their length.
.L35:
    call    pstrijcpy           # all arguments for function call are already set from L37
    movq    %r12,%rdx           # rdx = p1
    movzbq  (%rdx),%rsi         # rsi = p1 length (In the lower address, the size of the string is stored in one byte)
    leaq    1(%rdx),%rdx        # rdx = p1's string after pstrijcpy (The string is stored in the following addresses after the first byte)
          
    movq    $format_35_36,%rdi  # printing format
    xorq    %rax,%rax           # rax = 0
    call    printf              # print p1 length and string
    
    movq    %r13,%rdx           # rdx = p2
    movzbq  (%rdx),%rsi         # rsi = p2 length
    leaq    1(%rdx),%rdx        # rdx = p2's string
    
    movq    $format_35_36,%rdi  # printing format
    xorq    %rax,%rax           # rax = 0
    call    printf              # print p2 length and string
    jmp .func_select_return     # goto return lable


# Using the swapCase function, in each pstring replace every uppercase English letter (A-Z)
# with an lowercase English letter (a-z).
# In a similar way replace each lowercase English letter with an uppercase English letter.
# After the replacement, print the two pstrings.
.L36:
    movq    %r12,%rdi           # rdi = p1
    call    swapCase            # swapCase(p1)
    movq    %r12,%rdx           # rdx = p1 after swapCase call
    movzbq  (%rdx),%rsi         # rsi = p1 length (In the lower address, the size of the string is stored in one byte)
    leaq    1(%rdx),%rdx        # rdx = p1 swaped string (The string is stored in the following addresses after the first byte)
    
    movq    $format_35_36,%rdi  # printing format
    xorq    %rax,%rax           # rax = 0
    call    printf              # print p1
    
    movq    %r13,%rdi           # rdi = p2
    call    swapCase            # swapCase(p2)
    movq    %r13,%rdx           # rdx = p2 after swapCase call
    movzbq  (%rdx),%rsi         # rsi = p2 length
    leaq    1(%rdx),%rdx        # rdx = p2 swaped string
    
    movq    $format_35_36,%rdi  # printing format
    xorq    %rax,%rax           # rax = 0
    call    printf              # print p2
    jmp .func_select_return     # goto return lable

# Receive from the user two numbers: i - a start index
#                                    j - an end index.
# Check the user's case selection: 35 - jump to L35
#                                  37 - continue on this lable 
# On this lable, call the pstrijcmp function, with i and j, and compare p1 and p2 between the indexs i and j. 
# After the comparison, print the result by the format.
.L37:
    subq    $32, %rsp           # creating a scope on the stack for saving user input
    movq    %rdi, -16(%rbp)     # -32(%rbp) = case
    
    movq    $d,%rdi             # reading format
    leaq    -24(%rbp),%rsi      # set scanf to save input in -24(%rbp)
    xorq    %rax,%rax           # rax = 0
    call    scanf               # -24(%rbp) = i
    movq    -24(%rbp),%r14      # r14 = i
    
    movq     $0,-32(%rbp)       # reset garbage value in -32(%rbp)
    movq    $d,%rdi             # reading format
    leaq    -32(%rbp),%rsi      # set scanf to save input in -32(%rbp)
    xorq    %rax,%rax           # rax = 0
    call    scanf               # -32(%rbp) = j
    movq    -32(%rbp),%r15      # r15 = j
    
    movq    %r12,%rdi           # rdi = p1
    movq    %r13,%rsi           # rsi = p2
    movq    %r14,%rdx           # rdx = i
    movq    %r15,%rcx           # rcx = j

    cmpq    $4,-16(%rbp)        # compare case number with 5                 
    je      .L35                # if case = 35 go to L35

    call    pstrijcmp           # else, case = 37 --> continue with this label
    
    movq    %rax, %rsi          # rsi = compared value between p1 and p2 according to i and j indexs
    movq    $format_37,%rdi     # printing format
    xorq    %rax,%rax           # rax = 0
    call    printf
    jmp .func_select_return     # goto return lable

.L_DEF:                     
    movq    $format_def,%rdi    # printing format
    xorq    %rax,%rax           # rax = 0
    call    printf              # print wanted string
    jmp .func_select_return     # goto return lable

.func_select_return:
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12

    movq    %rbp,%rsp           # restore the old stack pointer - release all used memory
    popq    %rbp                # restore old frame pointer (the caller function frame)
    ret
