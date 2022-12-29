# 208968560 Dan Saada
# Ex3
# Compile with: gcc run_main.s

	.data

	.section	.rodata			# read only data section
		d: .string "%d"
    	s: .string "%s"
	
	.text						# the beginnig of the code
.globl	run_main				# the label "run_main" is used to state the initial point of this program
.type	run_main, @function		# the label "run_main" representing the beginning of a function
# the main function:
run_main:
	pushq	%rbp				# save the old frame pointer
	movq	%rsp,%rbp	    	# create the new frame pointer
	subq     $528,%rsp			# creating a scope on the stack for getting p1,p2 and user input

  	# reading first pstring
    movq    $d,%rdi        		# reading format
    leaq    -256(%rbp),%rsi     # set scanf to save input in -256(%rbp)
    xorq    %rax,%rax			# rax = 0
    call    scanf				# -256(%rbp) = pstring's length
    
    movq    $s,%rdi        		# reading format
    leaq    -255(%rbp),%rsi     # set scanf to save input in -255(%rbp)
    xorq    %rax,%rax			# rax = 0
    call    scanf				# -255(%rbp) = pstring's string

	# reading second pstring
    movq    $d,%rdi        		# reading format
    leaq    -512(%rbp),%rsi     # set scanf to save input in -512(%rbp)
    xorq    %rax,%rax			# rax = 0
    call    scanf				# -512(%rbp) = pstring's length

	movq    $s,%rdi        		# reading format
    leaq    -511(%rbp),%rsi     # set scanf to save input in -511(%rbp)
    xorq    %rax,%rax			# rax = 0
    call    scanf				# -511(%rbp) = pstring's string

	# reading user's choice
    movq    $d,%rdi        		# reading format
    leaq    -528(%rbp),%rsi     # set scanf to save input in -528(%rbp)
    xorq    %rax, %rax			# rax = 0
    call    scanf				# -528(%rbp) = user's choice

	movq    -528(%rbp),%rdi     # first argument: rdi = user's choice
    leaq    -256(%rbp),%rsi     # second argument: rsi = p1
    leaq    -512(%rbp),%rdx     # third argument: rdx = p2

 	call    run_func			

	movq	$0,%rax	    		# rax = 0
	movq	%rbp,%rsp	    	# restore the old stack pointer - release all used memory.
	popq	%rbp		    	# restore old frame pointer (the caller function frame)
	ret					    	# return to caller function
