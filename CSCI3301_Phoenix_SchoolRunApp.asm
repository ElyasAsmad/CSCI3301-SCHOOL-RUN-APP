# CSCI 3301 Computer Architecture and Assembly Language (CAAL)	Section: 1
# Title: : SCHOOL RUN APP : DROP OFF AND PICK-UP
# Group Phoenix, Members:
# 	1. Nur Arisha Nadira binti Norisham (2011256)
#	2. Elyas bin Asmad (2116893)
#	3. Irdina Batrisyia binti Nor Azli (2117188)
#	4. Sayyidah Nafisah binti Johari (2118242)
#CarPlateSensor
#This code will check if the car is registered in the database
#If the car is not registered, the alarm will goes off

#initializing all the variables
.data 

	first_greeting:		.asciiz "Welcome to SMI Al-Amin Gombak!"

	userSchoolOption: 	.asciiz "Choose an option:\n"
	optionToEnter:		.asciiz "1) I am entering the school\n"
	optionToLeave:		.asciiz "2) I am leaving the school\n"
	optionToExit:		.asciiz "3) Exit \n"
	schoolOptionPrompt: .asciiz "Enter your choice (1/2/3): "
	schoolOptionFirst:	.byte '1'
	schoolOptionSecond:	.byte '2'
	schoolOptionThird:	.byte '3'
	
	exitMessage:		.asciiz "Thank you for using our service!\n"

	invalidParkingException: 	.asciiz "There are no car parked here yet.\n"
	noParkingException:			.asciiz "Sorry, there are no parking left.\n"

	askWeight:		.asciiz "Enter car weight (whole number only): "
	carPresence: 		.asciiz "\nAre there any car entering the car park? (Y/N): "
	carInput: 		.space 6
	displayCarslot: 	.asciiz "\nAvailable parking slots are 10\n"

	leaveMessage:		.asciiz "You leaved the school parking! \n"

	#database consist of car plate number
	database_car:	.asciiz "ABC 1234", "WXY 6789", "WHY 1430" 

	db_state: .word 0
	current_user_idx: .word 0
	
	#database for student
	database_student: .asciiz "ALI", "AHMAD", "ABU"
	
	#to allocate space if necessary
	plate:		.space 10
	
	#message string for welcome message
	welcome_msg:	.asciiz "\nWelcome! This is an plate number authentication process\n" 
	
	#message string to prompt input message from camera sensor
	input_msg:	.asciiz "Incoming car plate number: " 
	
	#message to tell the car did not exist in the database
	invalid_msg:	.asciiz "Your car is not registered" 
	
	#message for user if they entered a valid username
	valid_msg: 	.asciiz "The car is registered: " 
	student_name: 	.asciiz "\nStudent Name is: "
	#initializing \n for authentication purpose
	line: 		.asciiz "\n"
	max_studentArray: .word 14
	
	height:         .float   0.0             # Variable to store the height (in meters)
	threshold_high: .float   2.1             # Maximum height limit (in meters)
	prompt:         .asciiz  "Enter car's height (in meters): "
	result:         .asciiz  "Car's height is: "
	alert_msg:      .asciiz  "Alert: Car's height exceeds the limit. Entry not allowed."
	within_msg:     .asciiz  "Car's height is within the acceptable limit. You may proceed."
	
	# Drop off / pick-up subsystem (2116893 - Elyas Asmad)

	parkingMsg:		.asciiz "Parking spaces available: "
	
	##################################################################
	# This is the initial value of the total parking space available #
	parking:		.word 10
	##################################################################

	parkingErrorMsg:	.asciiz "Sorry, there are no more available parking spaces left."
	dropPickPrompt:		.asciiz "Do you wish to drop off or pick up your son? (D/P): "
	invalidOptionError:		.asciiz "You have entered an invalid option. Please try again."
	dropOption:		.byte 'D'
	pickOption: 		.byte 'P'
	userOption:		.byte ' '
	outputMsg:		.asciiz "SUCCESS! Your output is: "
	spacer: 		.asciiz "\n\n"
	plateNumbers:	.space 40

	dropOffMessage: .asciiz "Please confirm student attendance (Y/N): "
	dropOffPositive: .asciiz "Student is safely arrived at the school."
	dropOffNegative: .asciiz "Student has not arrived at school yet."

	dpOptionY: .byte 'Y'
	dpOptionN: .byte 'N'

	pickupMessage: .asciiz "Are you the parents of this student (Y/N): "
	pickupNegative: .asciiz "You are not the parent of the student."
	pickupPositive: .asciiz "Your parents has arrived!"

	unknownErr: .asciiz "An unknown error has occured."
	
.text

main:

	la $a0, first_greeting
	jal print_string

	la $a0, spacer
	jal print_string
	
	# Display available parking spaces left ------------------------------------

	la $a0, parkingMsg		# Print parkingMsg to console
	jal print_string		# String print subroutine
	
	lw $a0, parking			# Load parking spaces from memory
	jal print_int			# Int Print subroutine

	la $a0, spacer
	jal print_string

	# Display school menu option

	la $a0, userSchoolOption
	jal print_string

	la $a0, optionToEnter		# Option 1 - Enter the school
	jal print_string

	la $a0, optionToLeave		# Option 2 - Leave the school
	jal print_string

	la $a0, optionToExit		# Option 3 - Exit program
	jal print_string

	la $a0, schoolOptionPrompt	# User prompt message
	jal print_string

	jal read_char			# User input is in $v0
	add $s0, $zero, $v0		# Move user input from $v0 to $s0
	
	la $a0, spacer
	jal print_string
	
	# ---------------------------------------------------
	# Check validity of user's input
	# ---------------------------------------------------
	
	lb $t0, schoolOptionFirst		# Load '1' into $t0 from memory
	lb $t1, schoolOptionSecond		# Load '2' into $t1 from memory
	lb $t2, schoolOptionThird		# Load '3' into $t2 from memory

	seq $t0, $t0, $s0				# Set $t0 if user enters '1'
	seq $t1, $t1, $s0				# Set $t1 if user enters '2'
	seq $t2, $t2, $s0				# Set $t2 if user enters '3'
	
	or $t3, $t0, $t1				# Check if user enters either '1' or '2'
	or $t3, $t3, $t2				# Check if user enters either ('1' or '2') or '3'
	
	beqz $t3, schoolOptionError		# If user enter answer other than '1' or '2' or '3'
	
	li $t3, 0						# Reset $t3 to 0

	beq $t0, 1, enter_school_main	# If user input == '1', go to enter_school_main subroutine
	beq $t1, 1, leave_school_main	# If user input == '2', go to leave_school_main subroutine
	beq $t2, 1, exit_system			# If user input == '3', go to exit_system subroutine
	
	la $a0, unknownErr				# Error handling if somehow the validation part is bypassed
	jal print_string
	
	li $v0, 10				# EXIT program SYSCALL service
	syscall

schoolOptionError:					# Invalid option subroutine

	la $a0, invalidOptionError
	jal print_string
	
	la $a0, spacer
	jal print_string
	
	j main

enter_school_main:						# This is subroutine called whenever user enters the school

	jal check_enter_parking_state

	#######################
		#Check height
	#######################
	# Prompt user for input

    li $v0, 4                           # Print string
    la $a0, prompt                      # Load address of prompt string
    syscall

    # Read height from user
    li $v0, 6                           # Read float
    syscall
    mov.s $f0, $f0                      # Store the height in $f0

    # Store the height in memory
    s.s $f0, height

    # Load maximum limit
    l.s $f1, threshold_high

    # Compare height with maximum limit
    c.lt.s $f1, $f0                     # Set FP status register if maximum limit < height
    bc1t height_exceeds_limit           # Branch to height_exceeds_limit if maximum limit < height

    # Height is within the acceptable limit
    li $v0, 4                           # Print string
    la $a0, within_msg                  # Load address of within_msg string
    syscall

	#######################
	#Check number plate#
	#######################
	#print welcome message

	la $a0, welcome_msg #load address of welcome_msg into $a0
	jal print_string #using jump and link to PrintString procedure to print welcome message


	#print input message
	la $a0, input_msg #load address of input_msg into $a0
	jal print_string #using jump and link to PrintString procedure to print prompt input message

	#get input from user
	la $a0, plate 
	li $a1, 10 #maximum 10 character
	li $v0, 8 #syscall service to read input string
	syscall
	
	#load plate number, database and line into registers
	la $s1, plate #load input from camera sensor into $s1
	la $s2, database_car #load database into $s2
	lb $s3, line #load \n into $s3
	la $s5, database_student #load db students into $s5
	lw $s6, max_studentArray #

	j loop_checkDB
	
leave_school_main:						# This is subroutine called whenever user leaves the school

	jal check_leave_parking_state

	#print input message
	la $a0, input_msg #load address of input_msg into $a0
	jal print_string #using jump and link to PrintString procedure to print prompt input message

	#get input from user
	la $a0, plate 
	li $a1, 10 #maximum 10 character
	li $v0, 8 #syscall service to read input string
	syscall
	
	#load plate number, database and line into registers
	la $s1, plate #load input from camera sensor into $s1
	la $s2, database_car #load database into $s2
	lb $s3, line #load \n into $s3
	la $s5, database_student #load db students into $s5
	lw $s6, max_studentArray #

	# Used to return to this subroutine
	lw $s7, db_state
	addi $s7, $s7, 100
	sw $s7, db_state

	j loop_checkDB

valid_leave_school:

	la $a0, spacer
	jal print_string #using jump and link to PrintString procedure to print prompt input message

	la $a0, leaveMessage
	jal print_string

	jal exit_parking

	la $a0, spacer
	jal print_string

	j main
	
exit_system:
	la $a0, exitMessage
	jal print_string

	lw $s7, parking

check_enter_parking_state:

	lw $s7, parking								# Get current total parking spaces available

	beq $s7, 0, no_parking_exception

	jr $ra										# Return to the caller function

check_leave_parking_state:

	lw $s7, parking								# Get current total parking spaces available

	beq $s7, 10, invalid_parking_exception		# If somehow a car is trying to leave, but the parking
												# spaces is still full (no parked car yet), display error

	jr $ra										# Return to the caller function

invalid_parking_exception:

	la $a0, invalidParkingException
	jal print_string

	la $a0, spacer
	jal print_string

	j main

no_parking_exception:

	la $a0, noParkingException
	jal print_string

	la $a0, spacer
	jal print_string

	j main

#doing loop to authenticate if plate number existed in the database
loop_checkDB:

	lb $t1, 0($s1) #load character from plate[0] into $t1
	lb $t2, 0($s2) #load character from database[0] into $t2 
	
	sub $t7, $t1, $t2 #subtract plate[0] - database[0] to see if it is the same character
	
	addi $t3, $t3, 1 #counter input from camera sensor
	addi $t5, $t5, 1 #counter database
	li $t6, 26 #max database array
	
	beq $t7, $zero, contEqual #if letter same - go to contEqual
	beq $t7, $s3, valid #if reach \n, go to valid
	bnez $t7, notEqual #if the character is not equal, go to notEqual
	
	j invalid #ending the loop if  username not exist in database
	
#if the result from substraction is equal with each other
contEqual:

	addi $s1, $s1, 1 #add increment for character in username entered
	addi $s2, $s2, 1 #add increment for character in database
		
	j loop_checkDB #continue looping 
	
#if not equal subtractions
#go to next data
notEqual: 
	
	addi $s2, $s2, 1 #increment character in database
	addi $t5, $t5, 1 #counter database
	bgt $t5, $t6, invalid #if counter db greater than size db, means it cannot find any similar data until end of db
	
	lbu $t4,($s2) #load byte database to $t4
	bne $t4, $zero, notEqual   # Continue looping until reaching the null character
	addi $s2, $s2, 1 #increment character in database if found the null character
	
	j nextStudent    # go to repeatPlate to reset array input from camera sensor from the first input character
	
nextStudent:
	addi $s5, $s5, 1 #increment character in database
	addi $t8, $t8, 1 #counter database
	lbu $t4,($s5) #load byte database to $t4
	bne $t4, $zero, nextStudent   # Continue looping until reaching the null character

	subi $t8, $t8,1
	
	j repeatPlate
	
#reset plate number from camera sensor
repeatPlate:
	sub $s1, $s1, $t3 #subtract plate with counter plate
	addi $s1, $s1, 1 #add plate with 1 to go to the first input character
	sub $t3, $t3, $t3 #reset counter plate
	j loop_checkDB #jump to loop
	
	#print this if the plate number scanned is invalid
invalid:
		
	la $a0, invalid_msg #print invalid message
	jal print_string

	la $a0, spacer
	jal print_string
	
	j main				# Return to main
		
	#print this if the plate number scanned is valid
valid: 
	bne $t2, $zero, notEqual #if plate[0] - db[0] = \n or 0xa when db has not done scanning, it will go to not equal
	la $a0, valid_msg #print valid message
	jal print_string 
	
	la $a0, plate #print plate number scanned besides "The car is registered:  "
	jal print_string
	
	la $a0, student_name #print student_name:
	jal print_string
	beqz $t8, printNameFirst
	j printName #Jump to printName 

printNameFirst:
	la $a0, ($s5) #load address db student to $a0
	jal print_string

	bnez $t9, printName

	lw $s7, db_state					# Check whether need to jump to other subroutine (This is a shared function)
	beq $s7, 100, valid_leave_school	# if $s7 == 100 then goto valid_leave_school

	j weight

printName:
	addiu $s5, $s5, 1 #add increment to database_student
	la $a0, ($s5) #load address db student to $a0
	jal print_string

	bnez $t9, printName

	lw $s7, db_state					# Check whether need to jump to other subroutine (This is a shared function)
	beq $s7, 100, valid_leave_school	# if $s7 == 100 then goto valid_leave_school
	
	beqz $t9, weight

	j weight

weight:
	#######################
		#Check Weight#
	#######################	
	la $a0, carPresence #to detect is there is any car
	jal print_string

	li $v0, 8           # input true or false is there is any car
	la $a0, carInput    # load address of input buffer
	li $a1, 6          # maximum length of input
	syscall
	la $s4, ($a0)
	lbu $t3, 0($s4)

	li $t1, 0x59 		# load value Y in t1
	li $t2, 0x4E		# load value N in t2
	

	beq $t3, $t1, true 	# compare input
	j end


true:

	la $a0, askWeight  #ask if there is any car to detect weight
	jal print_string
		
	li $v0, 5	#get car weight input
	syscall

	# Decrement parking space by 1, because a car has entered parking lot
	jal enter_parking

	j dropOrPick
	
height_exceeds_limit:
    li $v0, 4                           # Print string
    la $a0, alert_msg                   # Load address of alert_msg string
    syscall
    
	j main								# Return to main menu

dropOrPick:	

	la $a0, dropPickPrompt
	jal print_string

	jal read_char			# User input is in $v0
	add $s0, $zero, $v0		# Move user input from $v0 to $s0
	
	la $a0, spacer
	jal print_string
	
	# ---------------------------------------------------
	
	lb $t0, dropOption		# Load 'D' into $t0 from memory
	lb $t1, pickOption		# Load 'P' into $t1 from memory

	seq $t0, $t0, $s0
	seq $t1, $t1, $s0
	
	or $t2, $t0, $t1
	
	beqz $t2, dorpWrongOption
	
	beq $t0, 1, dropOff
	beq $t1, 1, pickup
	
	la $a0, unknownErr
	jal print_string
	
	li $v0, 10				# EXIT program SYSCALL service
	syscall
	
dropOff:

	la $a0, dropOffMessage
	jal print_string
	
	jal read_char			# User input is in $v0
	add $s0, $zero, $v0		# Move user input from $v0 to $s0
	
	la $a0, spacer
	jal print_string
	
	jal checkYNInput

	lb $t0, dpOptionY		# Load 'Y' into $t0 from memory
	seq $t0, $t0, $s0
	
	beq $t0, 1, dropOffYes
	
	j dropOffNo
	
dropOffYes:

	la $a0, dropOffPositive
	jal print_string

	la $a0, spacer
	jal print_string

	j main					# Return to the main menu

dropOffNo:

	# Save the return address to pickup subroutine
	# Note: this is because, we are jumping to another subroutine,
	# 		and the original $ra will be overwritten
	add $t9, $zero, $ra

	la $a0, dropOffNegative
	jal print_string

	la $a0, spacer
	jal print_string
	
	add $ra, $zero, $t9
	li $t9, 0			# Reset $t9

	j main					# Return to the main menu

pickup:

	la $a0, pickupMessage
	jal print_string

	jal read_char			# User input is in $v0
	add $s0, $zero, $v0		# Move user input from $v0 to $s0
	
	la $a0, spacer
	jal print_string

	jal checkYNInput
	
	lb $t0, dpOptionY		# Load 'Y' into $t0 from memory
	seq $t0, $t0, $s0
	
	beq $t0, 1, pickupYes
	
	jal pickupNo

	# EXIT PROGRAM	
	li $v0, 10
	syscall
	
pickupYes:

	la $a0, pickupPositive
	jal print_string
	
	la $a0, spacer
	jal print_string

	j main
	
pickupNo:

	# Save the return address to pickup subroutine
	# Note: this is because, we are jumping to another subroutine,
	# 		and the original $ra will be overwritten
	add $t9, $zero, $ra

	la $a0, pickupNegative
	jal print_string
	
	add $ra, $zero, $t9
	li $t9, 0			# Reset $t9
	
	jr $ra
	
checkYNInput:

	lb $t0, dpOptionY		# Load 'D' into $t0 from memory
	lb $t1, dpOptionN		# Load 'P' into $t1 from memory

	seq $t0, $t0, $s0
	seq $t1, $t1, $s0
	
	or $t2, $t0, $t1
	
	beqz $t2, ynWrongOption
	
	jr $ra
	
ynWrongOption: 

	la $a0, invalidOptionError
	jal print_string
	
	la $a0, spacer
	jal print_string
	
	j dropOrPick

	
dorpWrongOption:			# dorp stands for drop or pickup

	la $a0, invalidOptionError
	jal print_string
	
	la $a0, spacer
	jal print_string
	
	j dropOrPick

# This subroutine will be called whenever user decided
# to enter the parking lot
enter_parking:

	lw $s7, parking			# Load parking spaces from memory
	subi $s7, $s7, 1
	sw $s7, parking			# Store the new value of parking space available
							# in parking

	jr $ra

# This subroutine will be called whenever user decided
# to exit the parking lot
exit_parking:

	lw $s7, parking			# Load parking spaces from memory
	addi $s7, $s7, 1
	sw $s7, parking			# Store the new value of parking space available
							# in parking
	
	jr $ra

# --------------------------------------------------------------------------
# SYSTEM UTILITY SUBROUTINES -----------------------------------------------
# --------------------------------------------------------------------------

print_string:
 	li $v0, 4 			# Print string SYSCALL service 
	syscall
	jr $ra #return

print_int:
	li $v0, 1			# Print int SYSCALL service 
	syscall
	jr $ra
	
print_char:				# Print char SYSCALL service 
	li $v0, 11
	syscall
	jr $ra
	
read_char:
	li $v0, 12			# Read char SYSCALL service 
	syscall
	jr $ra
	
#end of program 
end: 					# Terminate program SYSCALL service 
	li $v0, 10
	syscall
