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
	askWeight:		.asciiz "Enter car weight (whole number only): "
	carPresence: 		.asciiz "\nAre there any car entering the car park? (Y/N): "
	carInput: 		.space 6
	displayCarslot: 	.asciiz "\nAvailable parking slots are 10\n"

	#database consist of car plate number
	database_car:	.asciiz "ABC 1234", "WXY 6789", "WHY 1430" 
	
	#database for student
	database_student: .asciiz "ALI", "AHMAD", "ABU"
	
	#to allocate space if necessary
	plate:		.space 10
	
	#message string for welcome message
	welcome_msg:	.asciiz "\nWelcome! This is an authentication process\n" 
	
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
	

	
.text

Main:
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
	jal PrintString #using jump and link to PrintString procedure to print welcome message


	#print input message
	la $a0, input_msg #load address of input_msg into $a0
	jal PrintString #using jump and link to PrintString procedure to print prompt input message

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
		bnez $t7 notEqual #if the character is not equal, go to notEqual
		
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
	invalid :
		
		la $a0, invalid_msg #print invalid message
		jal PrintString
		j end
		
	#print this if the plate number scanned is valid
	valid : 
		
		la $a0, valid_msg #print valid message
		jal PrintString 
		
		la $a0, plate #print plate number scanned besides "The car is registered:  "
		jal PrintString
		
		la $a0, student_name #print student name:
		jal PrintString
	
	
		j printName
		
	printName:
		addiu $s5, $s5, 1
		la $a0, ($s5)
		jal PrintString
		bnez $t9, printName
		beqz $t9, weight
		

weight:
#######################
    #Check Weight#
#######################	
		la $a0, carPresence #to detect is there is any car
		jal PrintString
	
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
	jal PrintString
		
	li $v0, 5	#get car weight input
	syscall
	
	la $a0, displayCarslot
	jal PrintString #display available car slot
	
	j end
	
	
	 height_exceeds_limit:
    li $v0, 4                           # Print string
    la $a0, alert_msg                   # Load address of alert_msg string
    syscall
    j end                              # Jump to exit
	

	#procedure to print string
	PrintString:

 		li $v0, 4 #syscall 4
		syscall
		
		jr $ra #return
	
	#end of program 
	end: 	
		li $v0, 10
		syscall
