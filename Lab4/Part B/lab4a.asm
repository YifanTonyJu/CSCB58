# Name: Yifan Ju
# UTorID: 1009920828

.data 
promptA: .asciiz "Enter an int A: "
promptB: .asciiz "Enter an int B: "
result42: .asciiz "A + 42 = "
resultSub: .asciiz "B - A = "
newline: .asciiz "\n"

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

	# calculate A + 42 and save in $t2
	add $t2, $t0, 42
	
	# calculate B - A and save in $t3
	sub $t3, $t1, $t0

	# print prompt result42
	li $v0, 4
	la $a0, result42
	syscall

        # save the number in $t2 to $a0 and print $a0
	li $v0, 1
	move $a0, $t2	
	syscall 

        # change to a new line
	li $v0, 4
	la $a0, newline
	syscall 

        # print prompt resultSub
	li $v0, 4
	la $a0, resultSub
	syscall

	# save the number in $t3 to $a0 and print $a0
	li $v0, 1
	move $a0, $t3
	syscall 

        # change to a new line
	li $v0, 4
	la $a0, newline
	syscall 

	# end
	li $v0, 10
	syscall
