# Ryan Lov, Matthew Kwong, Jason Agus, Max Lau
# CS2640.01
# Caesar Cipher

.data
# Dialog/Message Prompts
promptOperation:			.asciiz "Would you like to encrypt or decrypt? (Yes for Encrypt) (No For Decrypt) "
promptInput:				.asciiz "Enter a string: "
promptShift:				.asciiz "Enter a shift value: "
promptEncryptResult:		.asciiz "Encrypted String: \n"
promptDecryptResult:		.asciiz "Decrypted String: \n"

# Input Buffer
buffer: 		.space 500

# Constants
LOWER_START:	.word 97
LOWER_END:		.word 122

UPPER_START:	.word 65
UPPER_END:		.word 90

ALPHA_RANGE:	.word 26

.text
main:

# Prompt user for string input
li			$v0, 54
la			$a0, promptInput
la 			$a1, buffer
la			$a2, 499
syscall


# Prompt user for Encrypt or Decrypt
li			$v0, 50
la			$a0, promptOperation
syscall

beq			$a0, 2, exit
move		$t2, $a0 # $v0 = 0 if encrypt, 1 if decrypt

# Prompt user for shift value
li			$v0, 51
la			$a0, promptShift
syscall

# $a0 = shift value
bgt			$a1, 0, exit # exit if cancel or read failed

j MODSTR


# print the cipher text
result:

	# If decrypting, print the decrypted prompt
	# else print the encrypted prompt
	jal 	JINGLE
	
	la		$a0, promptEncryptResult
	la		$t0, promptDecryptResult
	movn	$a0, $t0, $t2
	
	li		$v0, 59
	la		$a1, buffer
	syscall
	
	
	
	j	exit

# --------------------------------
# MOD STRING THROUGH CHAR LOOP
# --------------------------------
MODSTR:
la			$t0, buffer # $t0 = string pointer
move		$t1, $a0 # $t1 = shift value
# $t2 = 0 if encrypt, 1 if decrypt

# if decrypting, shift the other way
sub			$t3, $zero, $t1 # negative shift
movn		$t1, $t3, $t2 

loop: 
	# RESERVE $A0 FOR THE CHAR (WILL BE MOFDIFIED AFTER SHIFT)
	# load char into $a0 with unsiged since ascii is positive
	lbu		$a0, ($t0)

	# exit conditions
	beq		$a0, 10, return # exit if newline
	beq		$a0, 0, return # exit if null terminating byte



	# $a3 = 65 if char uppercase
	lw		$a1, UPPER_START
	lw		$a2, UPPER_END
	jal		IS_BETWEEN
	movn	$a3, $a1, $v0
	move 	$v1, $v0

	# $a3 = 97 if char lowercase
	lw		$a1, LOWER_START
	lw		$a2, LOWER_END
	jal		IS_BETWEEN
	movn	$a3, $a1, $v0

	# continue conditions
	nor		$v0, $v0, $v1 # $v0 = -1 if char is not a letter
	beq		$v0, -1, continue # continue if not a letter

	# shift character by shift value
	add		$a0, $a0, $t1

	# Shift char
	move 	$a1, $a3
	lw		$a2, ALPHA_RANGE # range of characters
	jal		MODCHAR


	# store shifted char back into buffer
	move	$a0, $v0
	sb		$a0, ($t0)

continue:
	addi	$t0, $t0, 1 # increment string pointer
	j		loop

return:
	j		result



exit:
	li	$v0, 10
	syscall


# --------------------------------
# Functions
# --------------------------------

# MODCHAR
# ($a0 = a, $a1 = b, $a2 = c)
# 	wraps a between b & b+c (inclusive)
# $v0 returns the shifted char
MODCHAR:
	sub		$s0, $a0, $a1 # a-b
	
	# mod doesnt work with negative number so use
	# the adjusted formula: (x % y + y) % y
	
	# (a-b) % c
	div		$s0, $a2 
	mfhi	$s0

	# (a-b) % c + c
	add		$s0, $s0, $a2
	div		$s0, $a2
	mfhi	$s0

	# (a-b) % c + c + b
	add		$v0, $s0, $a1

	jr		$ra


# IS_BETWEEN
# ($a0 = val, $a1 = a, $a2 = b)
#	checks if val is between a and b
# $v0 returns 1 a <= val <= b(inclusive), 0 otherwise
IS_BETWEEN:
    sge		$s0, $a0, $a1 # a <= val
    sle		$s1, $a0, $a2 # val <= b
    and		$v0, $s0, $s1
    jr		$ra


# JINGLE
# plays a little jingle when the operation is complete :D
JINGLE:
	.macro playNote(%note, %duration)
		li $v0, 33
		li $a0, %note
		li $a1, %duration
		li $a2, 97
		li $a3, 100
		syscall
	.end_macro

	playNote(80, 150)
	playNote(76, 150)
	playNote(80, 150)
	playNote(82, 150)
	playNote(84, 150)
	playNote(82, 150)
	playNote(80, 150)
	playNote(76, 150)
	playNote(75, 650)
jr $ra
