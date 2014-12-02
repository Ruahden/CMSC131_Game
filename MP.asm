title MP - Game

.model small 
.stack 100h
.386
.data
	cursorRow				db	15
	cursorColumn			db	11
	character				db	0
	characterColor			db	0
	tempCursorRow			db	0
	
	tempIndex				dw	0
	
	keyPress				db 	0
	
	menuString				db	'Start Game$','High Score$','Quit$'
	menuKeys	 			db 	13,72,80 								; enter, up, down
	menuChoice				db 	0 										; 0 - start game, 1 - high-score, 2 - quit
	indicator				db 	4 										; 0 - start game, 1 - high-score, 2 - quit

	nameInputString			db	'Please enter your 3-letter initial.','$'
	nameInputKeys			db 	13, 72, 75, 77, 80 						; enter, up, left, right, down
	nameInputChoice			db 	0 										; 0 - 1st letter, 1 - 2nd letter, 2 - 3rd letter
	nameInput				db	'AAA$'
	
	score 					dw	0
	tempScore				dw	0
	
	buffer					db	2000 dup(0)
	
	landIndex				dw	1845,1880,1883,1904,1947,1980,1993
	landIndexMinimum		dw 	1839,1839,1839,1839,1919,1919,1919
	landIndexMaximum		dw	1919,1919,1919,1919,1999,1999,1999
	landLineSize			dw	5,2,1,6,8,3,2
	
	delayTime				db	1
	
	locationDifference		dw	0
	tempLocation			dw 	0
	tempMinimum				dw	0
	
	obstacleLocation		dw	0
	
.code

	; ***
	; PRESET PROCEEDURES
	; ***
	
		; *** clearRegisters - CLEARS ALL THE REGISTER FOR ASSURANCE PURPOSES
		; * ACCEPT:
		; * 	none
		; * RETURN:
		; * 	none
		clearRegisters proc
			xor ax,ax
			xor bx,bx
			xor cx,cx
			xor dx,dx
			ret
		clearRegisters endp
		
		clearBuffer proc
			mov bx, 0
			clearBufferLoop:
				mov buffer[bx], 0
				inc bx
				cmp bx, 2000
			jne clearBufferLoop
			ret
		clearBuffer endp
		
		; *** setDelay - CREATES A DELAY FOR ANIMATION PURPOSES
		; * ACCEPT:
		; * 	delayTime - the duration of the delay 
		; * RETURN:
		; * 	none
		setDelay proc
			mov ah, 00
			int 1Ah
			mov bx, dx

			jmp_delay:
				int 1Ah
				sub dx, bx
				cmp dl, delayTime
			jl jmp_delay
			ret
		setDelay endp
			
			
		; *** textMode - CLEARS THE CONSOLE AND CHANGES IT TO TEXT MODE (PIXEL: 320 x 200, TEXT: 80 x 25)
		; * ACCEPT:
		; * 	none
		; * RETURN:
		; * 	none
			textMode proc
				mov ax, 0Eh 		; 320 x 200 (TEXT: 80 x 25)
				int 10h
				ret
			textMode endp
		
			clearPage proc
				mov ax, 0Eh			; 320 x 200 (TEXT: 80 x 25)
				int 10h
				ret
			clearPage endp
		
		; *** positionCursor - POSITIONS THE CURSOR IN THE CONSOLE
		; * ACCEPT:
		; * 	cursorColumn - column position of the cursor
		; * 	cursorRow - row position of the cursor
		; * RETURN:
		; * 	none
			positionCursor proc
				mov dh, cursorRow
				mov dl, cursorColumn
				xor bh, bh
				mov ah, 02h
				int 10h
				ret
			positionCursor endp
			
		; *** printCharacter - PRINTS THE CHARACTER IN THE CONSOLE
		; * ACCEPT:
		; * 	character - the character to print
		; * 	characterColor - the color of the character
		; * RETURN:
		; * 	none
			printCharacter proc
				mov al, character	
				mov bl, characterColor
				xor bh, bh
				mov cx, 1
				mov ah, 09h
				int 10h
				ret
			printCharacter endp
	
			printCharacters proc
				mov ax, @DATA
				mov es, ax
				
				mov bp, OFFSET buffer 		
				mov ah, 13H 				
				mov al, 01H					
				xor bh, bh 					; VIDEO PAGE = 0
				mov bl, 0Fh 				; WHITE
				mov cx, 2000 				; LENGTH OF THE STRING
				mov dh, 0					; ROW TO PLACE STRING
				mov dl, 0			 		; COLUMN TO PLACE STRING
				int 10H
				ret
			printCharacters endp
	
	; ***
	; MENU PROCEEDURES
	; ***
	
		; *** buildMenu - BUILDS THE UI FOR THE MENU
		; * ACCEPT:
		; * 	menuString - the string to be shown at the menu
		; * RETURN:
		; * 	none
			buildMenu proc
				call clearRegisters
			
				mov al, cursorRow
				mov tempCursorRow, al
				
				mov cursorRow, 15
				printBlankPointer:
					call positionCursor
						
					mov character, ' '
					call printCharacter
					
					inc cursorRow
					cmp cursorRow, 18
				jne printBlankPointer
				
				mov al, tempCursorRow
				mov cursorRow, al
				
				call positionCursor
					
				mov character, '>'
				mov characterColor, 0Fh
				call printCharacter
				
				mov cursorRow, 15
				mov cursorColumn, 13
				mov bx, 0
				cursorRowLoop:
					mov tempIndex, bx
						call positionCursor
					mov bx, tempIndex
						lea dx, menuString[bx]
						mov ah, 09h
						int 21h
					add bx, 11
					inc cursorRow
					cmp cursorRow, 18
				jne cursorRowLoop
				
				mov al, tempCursorRow
				mov cursorRow, al
				
				ret
			buildMenu endp
	
				; *** buildLogo - BUILDS THE LOGO FOR THE MENU SCREEN
				; * ACCEPT:
				; *		none
				; * RETURN:
				; *		none
					buildLogo proc
						
						
						ret
					buildLogo endp
	
		; *** handleMenuKeyPress - GETS THE KEY AND STORES IT IN keyPress
		; * ACCEPT:
		; *		menuKeys - all possible keys to click in the menu
		; * RETURN:
		; *		KeyPress - the key pressed
			handleMenuKeyPress proc
				call clearRegisters
				
				mov ah, 00h        	
				int 16h  
			
				cmp al, 0
				jne notExtendedKeys
					mov bx, 0
					checkIfOtherKey:
						cmp ah, menuKeys[bx]
						je extendedKey
						
						inc bx
						cmp bx, 3
					jne checkIfOtherKey
					ret
					extendedKey:
						mov keyPress, ah					
					ret
				notExtendedKeys:
					mov bx, 0
					checkIfAnotherKey:
						cmp al, menuKeys[bx]
						je normalKey
							
						inc bx
						cmp bx, 3
					jne checkIfAnotherKey
					ret	
					normalKey:
						mov keyPress, al
					ret
			handleMenuKeyPress endp
	
		; *** handleMenuFunction - Handles the menu function
		; * ACCEPT:
		; *		keyPress - the pressed key
		; * RETURN:
		; *		menuChoice - the current menu chosen
		; * 	indicator - similar to that of menuChoice
			handleMenuFunction proc
				call clearRegisters
				
				mov cursorColumn, 11
				
				cmp keyPress, 80
					je downArrow
				cmp keyPress, 72
					je upArrow
				cmp keyPress, 13
					je enterKey
					
				downArrow:
					cmp menuChoice, 2
					jge doNotDown
						inc menuChoice
						inc cursorRow
					doNotDown:
						call buildMenu
				ret
				upArrow:
					cmp menuChoice, 0
					jle doNotUp
						dec menuChoice
						dec cursorRow
					doNotUp:
						call buildMenu
				ret
				enterKey:
					mov al, menuChoice
					mov indicator, al
				ret
			handleMenuFunction endp
	
	
	; ***
	; HIGH SCORE PROCEEDURES
	; ***
	
		; *** buildHighScore - 
		; * 
			buildHighScore proc 
				ret
			buildHighScore endp
	
	; ***
	; MAIN GAME PROCEEDURES
	; ***
	
		; *** buildLand - builds the land graphics
		; * ACCEPT:
		; *		pixelIndex - the index of the pixel in mode 13 int 10h
		; *		pixelRowMinimum - the minimum position for the pixel
		; *		pixelRowMaximum - the maximum position for the pixel
		; *		pixelLineSize - the size of continuously printed pixels
		; * RETURN:
		; *		none
			buildLand proc 
				call clearRegisters
				
				mov bx, 1760		; position: 22 x 80
				landLoop:
					mov buffer[bx], '-'
					inc bx
					cmp bx, 1840
				jne landLoop
				
				mov bx, 0
				landLoop1:
					mov tempIndex, bx
				
					cmp tempScore, 80
					jne notFull
						mov tempScore, 0
					notFull:
				
					mov ax, landIndex[bx]
					mov cx, landIndexMinimum[bx] 
					mov dx, landIndexMaximum[bx] 
					mov si, landLineSize[bx]
					
					mov bx, ax
					sub bx, tempScore
				
					lineLoop:
						mov tempLocation, bx
						mov tempMinimum, cx

						sub cx, bx
						cmp cx, 0
						jl notOtherEnd
							mov locationDifference, cx
							mov bx, dx
							sub bx, locationDifference
						notOtherEnd:
							mov buffer[bx], '-'
						
						mov cx, tempMinimum
						mov bx, tempLocation
						inc bx
						dec si
					jnz lineLoop
					
					mov bx, tempIndex
			
					add bx, 2
					cmp bx, 14
				jne landLoop1
				
				ret
			buildLand endp
			
		buildObstacles proc
			cmp score, 30
			jl doNotStartObstacle
				
				inc obstacleLocation
				
				mov ax, obstacleLocation
				mov tempLocation, ax
				
				call createObstacle
				
				cmp obstacleLocation, 30
				jl doNotStartObstacle
				
					mov ax, obstacleLocation
					sub ax, 29
					mov tempLocation, ax
					
					call createObstacle
				
			doNotStartObstacle:
			ret
		buildObstacles endp
		
			createObstacle proc
			
				; 18 x 80
				mov bx, 1440
				sub bx, tempLocation
				
				; si = line size
				cmp tempLocation, 3
				jg maxSize
					mov si, tempLocation
					jmp completeSize
				maxSize:
					cmp tempLocation, 80
					jge subtractLines
						mov si, 3
				completeSize:
					mov buffer[bx], '^'
					add bx, 80
					cmp bx, 1760
				jl completeSize
				subtractLines:
				ret				
			createObstacle endp
			
				
		; *** handleGameKeyPress - GETS THE KEY AND STORES IT IN keyPress
		; * ACCEPT:
		; *		gameKeys - all possible keys to click in the game
		; * RETURN:
		; *		KeyPress - the key pressed
			handleGameKeyPress proc
				call clearRegisters
				
				mov ah, 00h        	
				int 16h  
						
				cmp al, 0
				jne notExtendedKeys
					cmp ah, 72
					je extendedKey
						ret
					extendedKey:
						mov keyPress, ah					
					ret
				notExtendedKeys:
					cmp al, 32
					je normalKey
						ret	
					normalKey:
						mov keyPress, al
					ret
			handleGameKeyPress endp
			
		; *** handleGameFunction - THE MAIN GAME PROCESS
		; * ACCEPT:
		; *		
		; * RETURN:
		; *		
			handleGameFunction proc
				ret
			handleGameFunction endp
			
			; *** buildNameInput - BUILDS THE PAGE FOR NAME INPUT
			; * ACCEPT:
			; *		nameInputString - the string to be shown at the menu
			; * RETURN:
			; *		none
				buildNameInput proc 
					call clearRegisters
					
					mov cursorRow, 12
					mov cursorColumn, 35
					mov bx, 0
					nameInputCharacterLoop:
						mov tempIndex, bx
						
						call positionCursor
						
						mov bx, tempIndex
						
						mov al, nameInput[bx]
						mov character, al
						call printCharacter
					
						add cursorColumn, 5
					
						mov bx, tempIndex
						inc bx
						cmp bx, 3
					jne nameInputCharacterLoop
					
					mov cursorRow, 8
					mov cursorColumn, 22
					call positionCursor
					
					lea dx, nameInputString[0]
					mov ah, 09h
					int 21h
					
					mov cursorRow, 11
					cursorRowLoop:
						mov cursorColumn, 35
						cursorColumnLoop:
							call positionCursor
							
							mov characterColor, 0Fh
							
							cmp cursorRow, 11
								je upArrowButton
							cmp cursorRow, 13
								je downArrowButton

							upArrowButton:
								mov character, '^'
								call printCharacter
								jmp backToColumnLoop
							downArrowButton:
								mov character, 'v'
								call printCharacter
								jmp backToColumnLoop
							backToColumnLoop:
								
							add cursorColumn, 5
							cmp cursorColumn, 50
						jne cursorColumnLoop
						add cursorRow, 2
						cmp cursorRow, 15
					jne cursorRowLoop
					
					mov cursorRow, 15
					mov cursorColumn, 35
					printBlankDiamond:
						call positionCursor
						
						mov character, ' '
						call printCharacter
					
						add cursorColumn, 5
						cmp cursorColumn, 50
					jne printBlankDiamond
					
					cmp nameInputChoice, 0
						je firstLetterDiamond
					cmp nameInputChoice, 1
						je secondLetterDiamond
					cmp nameInputChoice, 2
						je thirdLetterDiamond
						
					firstLetterDiamond:
						mov cursorColumn, 35
						jmp proceedBuildNameInput
					secondLetterDiamond:
						mov cursorColumn, 40
						jmp proceedBuildNameInput
					thirdLetterDiamond:
						mov cursorColumn, 45
					
					proceedBuildNameInput:
						
					call positionCursor
					
					mov character, 4
					call printCharacter
					
					ret
				buildNameInput endp
			
			; *** handleNameInputKeyPress - GETS THE KEY AND STORES IT IN keyPress
			; * ACCEPT:
			; *		nameInputKeys - all possible keys to click in the name input panel
			; * RETURN:
			; *		keyPress - the pressed key	
				handleNameInputKeyPress proc
					call clearRegisters
				
					mov ah, 00h        	
					int 16h  
				
					cmp al, 0
					jne notExtendedKeys
						mov bx, 0
						checkIfOtherKey:
							cmp ah, nameInputKeys[bx]
							je extendedKey
							
							inc bx
							cmp bx, 5
						jne checkIfOtherKey
						ret
						extendedKey:
							mov keyPress, ah					
						ret
					notExtendedKeys:
						mov bx, 0
						checkIfAnotherKey:
							cmp al, nameInputKeys[bx]
							je normalKey
								
							inc bx
							cmp bx, 5
						jne checkIfAnotherKey
						ret	
						normalKey:
							mov keyPress, al
						ret
				handleNameInputKeyPress endp
	
			; *** handleNameInputFunction - Handles the name input function
			; * ACCEPT:
			; *		keyPress - the pressed key
			; * RETURN:
			; *		
				handleNameInputFunction proc
					call clearRegisters
					
					mov cursorColumn, 31
					
					cmp keyPress, 72
						je upArrow
					cmp keyPress, 77
						je rightArrow
					cmp keyPress, 80
						je downArrow
					cmp keyPress, 75
						je leftArrow
					cmp keyPress, 13
						je enterKey
					
					upArrow:
						mov bl, nameInputChoice
						xor bh, bh
						
						cmp nameInput[bx], 'A'
						jle doNotDecrement
							dec nameInput[bx]
						doNotDecrement:
							call buildNameInput
						ret
					rightArrow:
						cmp nameInputChoice, 2
						jge doNotRight
							inc nameInputChoice
						doNotRight:
							call buildNameInput
						ret
					downArrow:
						mov bl, nameInputChoice
						xor bh, bh
						
						cmp nameInput[bx], 'Z'
						jge doNotIncrement
							inc nameInput[bx]
						doNotIncrement:
							call buildNameInput
						ret
					leftArrow:
						cmp nameInputChoice, 0
						jle doNotLeft
							dec nameInputChoice
						doNotLeft:
							call buildNameInput
						ret
					enterKey:
						
						; DO SOMETHING HERE TO STORE HIGHSCORE
						
					ret
				handleNameInputFunction endp
	
	; ***
	; THE MAIN PROGRAM
	; ***
	main    proc
	
	mov ax, @data
	mov ds, ax
	
		call textMode
		
		call buildMenu
		gameMenu:

			call handleMenuKeyPress
			call handleMenuFunction
		
			cmp indicator, 2
				je endGame
			cmp indicator, 1
				je highScore
			cmp indicator, 0
				je startGame	
				
		jmp gameMenu
			
		highScore:
			call buildHighScore
		jmp endGame
		startGame:
			
			mov dx, score
			mov tempScore, dx
			
			gameLoop: 
				mov ah, 01h
				int 16h

				jnz gotKey 
				
				; SETUPS THE ENVIRONMENT
					call clearBuffer
					call buildLand
					call buildObstacles
				; PRINTS THE BUFFER
					call printCharacters
				
				; 
				call handleGameFunction
				 
				inc score
				inc tempScore
				call setDelay
					
			jmp gameLoop   	
			gotKey:
				call handleGameKeyPress
				cmp keyPress, 72
			jne gameLoop
			
			call clearPage
			
			; *** ONLY CALL THIS WHEN THE SCORE MEETS THE HIGH SCORE
				call buildNameInput
				nameInputLoop:
					call handleNameInputKeyPress
					call handleNameInputFunction
					cmp keyPress, 13
				jne nameInputLoop
				
			; PUT HUGH SCODE PROCEEDURES HERE
			
		endGame:
	
		call textMode
	
	mov ax, 4c00h
    int 21h
	
	main    endp
    end main