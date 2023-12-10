.data
test: .asciiz "I M goINg iNsANeAAAA"

LOWER_START: .word 97
LOWER_END: .word 122

UPPER_START: .word 65
UPPER_END: .word 90

ALPHA_RANGE:  .word 26
.text
main:

# load string into $t0
la $t0, test

# Loop through each char of the string
loop: 
	# RESERVE $A0 FOR THE CHAR (WILL BE MOFDIFIED AFTER SHIFT)
	# load char into $a0 with unsiged since ascii is positive
	lbu   $a0, ($t0)

	# exit conditions
	beq $a0, 10, return # exit if newline
	beq $a0, 0, return # exit if null terminating byte
	beq $a0, 32, continue # continue if space


	# $a3 = 65 if char uppercase
	lw    $a1, UPPER_START
	lw    $a2, UPPER_END
	jal   IS_BETWEEN
	movn $a3, $a1, $v0


	# $a3 = 97 if char lowercase
	lw    $a1, LOWER_START
	lw    $a2, LOWER_END
	jal   IS_BETWEEN
	movn $a3, $a1, $v0



	# hardcode shift char by 100
	addi $a0, $a0, 100



	move $a1, $a3
	lw $a2, ALPHA_RANGE # range of characters
	jal MODCHAR


	# store shifted char back into buffer
	move $a0, $v0
	sb $a0, ($t0)

continue:
	addi $t0, $t0, 1 # increment string pointer
	j     loop

return:
	j     exit

exit:
	# print the cipher texzt
	li $v0,4
	la $a0, test
	syscall

	li    $v0, 10
	syscall


# --------------------------------
# Functions
# --------------------------------

# MODCHAR
# ($a0 = a, $a1 = b, $a2 = c)
# 	shfits the range of char(a) between b & c
# $v0 returns (a-b) % c + b
MODCHAR:
	sub $s0, $a0, $a1 # a-b
	div $s1, $s0, $a2 # % c
	mfhi $s0
	add $v0, $s0, $a1 # + b
	jr   $ra


# IS_BETWEEN
# ($a0 = val, $a1 = a, $a2 = b)
#	checks if val is between a and b
# $v0 returns 1 a <= val <= b(inclusive), 0 otherwise
IS_BETWEEN:
    sge $s0, $a0, $a1 # a <= val
    sle $s1, $a0, $a2 # val <= b
    and $v0, $s0, $s1
    jr $ra
	
