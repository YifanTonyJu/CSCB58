# Name: Yifan Ju
# UTorID: 1009920828

.data 
promptA: .asciiz "Enter an int A: "
promptB: .asciiz "Enter an int B: "
promptC: .asciiz "Enter an int C: "
resultSum: .asciiz "A + B + C = "

.globl main
.text

main: 
	# print promptA
	li $v0, 4		      
	la $a0, promptA
	syscall    

	# save the input in $t0
	li $v0, 5
	syscall 
	move $t0, $v0

        # print promptB
	li $v0, 4
	la $a0, promptB
	syscall

        # save the input in $t1
	li $v0, 5
	syscall 
	move $t1, $v0
	
	# print promptC
	li $v0, 4
	la $a0, promptC
	syscall

        # save the input in $t2
	li $v0, 5
	syscall 
	move $t2, $v0

	# calculate (A + B) + C and save in $t3
	add $t3, $t0, $t1 
	add $t3, $t3, $t2
	
	# print prompt resultSum
	li $v0, 4
	la $a0, resultSum
	syscall

        # save the number in $t3 to $a0 and print $a0
	li $v0, 1
	move $a0, $t3
	syscall 

        # end
	li $v0, 10
	syscall
