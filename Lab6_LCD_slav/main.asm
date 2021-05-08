;Main.s by Cayden Seiler, Michael Valentino-Manno
;4/9/2019
;465 LAB 5 LCD SLAV DEVICE
            INCLUDE 'derivative.inc'
            

; export symbols
            XDEF _Startup, main, _Viic
            ; we export both '_Startup' and 'main' as symbols. Either can
            ; be referenced in the linker .prm file or from C/C++ later on
            
            
            
            XREF __SEG_END_SSTACK   ; symbol defined by the linker for the end of the stack

	ORG $0060
		IIC_addr: DS.B 1
		msgLength: DS.B 1
		CURRENT: DS.B 1
		IIC_MSG: DS.B 7
		Counter: DS.B 1
		value_n: DS.B 1
		perCount:	 DS.B 1
		total: DS.B 1 
		total2: DS.B 1
		total3: DS.B 1		
		count: DS.B 1
		temp: DS.B 1
		BCDcount: DS.B 1
		BCD: DS.B 1	
		BCDH: DS.B 1
		BCDL: DS.B 1	
		tets: DS.B 2
		disp_msg: DS.B 1
		dataFlag: DS.B 1
		recFlag: DS.B 1
		top4_Date: DS.B 1
		bot4_Date: DS.B 1
		topTemp: DS.B 1
		botTemp: DS.B 1

	ORG $E000

main:
_Startup:
		LDHX	#__SEG_END_SSTACK ;initialize the stack
		TXS
		
			CLI ;enables interrupts
			
			LDA #%00000011 ;kills watchdog, enables reset and background debug
			STA SOPT1 ;stores

			LDA #$00
			STA total
			STA total2
			STA total3
			STA dataFlag
			STA recFlag
			
			BSET 7, PTBDD
			BSET 6, PTBDD
			BSET 5, PTBDD ;Initialize needed ports/pins as outputs
			BSET 4, PTBDD
			BSET 3, PTBDD 
			BSET 2, PTBDD
			BSET 1, PTBDD
			BSET 0, PTBDD
			
			BSET 0, PTADD
			BSET 1, PTADD
			
			LDA #%10000000
			STA SOPT2
			
			
            LDA #%00000000 ;initializes ADC
            STA ADCCFG
			
			LDA #%00011010 ;internal sensor unused in this 
			STA ADCSC1
			
			
			BCLR 3, PTADD 
			BCLR 2, PTADD

			JSR IIC_Startup_slave
			JSR LCDInitial

mainLoop:
			JSR DanOrMac
			;LDX #1
			;LDA IIC_MSG, X ;Load recieved IIC
			;CLRX
			
			LDA #7
			STA msgLength
			
			LDA #%00011010
			STA ADCSC1
			JSR DanOrMac ;used for determining message sent
			JSR dothedelay
			JSR DanOrMac ;needs to be often so we check all
			JSR dothedelay
			JSR DanOrMac ;messages
			JSR dothedelay
			JSR DanOrMac
			JSR dothedelay
			JSR DanOrMac			
			JSR areWePainters

	 		LDA IIC_MSG
			STA disp_msg

			JSR DanOrMac

			JSR doWeLCD ;WE NEED LATER
            BRA mainLoop
           
areWePainters:
			LDX recFlag
			CPX #1
			BEQ vanGogh
			RTS
vanGogh:
			
			JSR DaVinci
			RTS
			
DaVinci: ;davinci paints seconds on LCD screen
	CLRH
	
	LDX #0
	LDA IIC_MSG,X  
	AND #%11110000
	STA BCDH
	JSR top4Bits
	
	JSR Message_sec
	JSR dothedelay
	JSR dothedelay
	JSR dothedelay
	
	LDX #0
	LDA IIC_MSG,X  
	AND #%00001111
	STA bot4_Date
	CLRH
	LDX bot4_Date
	JSR bot4Bits
	
	JSR Message_top
	JSR dothedelay
	JSR dothedelay
	JSR dothedelay
	
	LDA #%00101111
	STA disp_msg
	;JSR Message_top
	JSR dothedelay
	JSR dothedelay
	JSR dothedelay
	
	RTS
			
doWeLCD:   
			LDX dataFlag
			CPX #1
			BEQ lcdSelect 
			
			LDX dataFlag
			CPX #3
			RTS 

zero: ;These sectioons of code converts keypress into
	LDA #$00  ;HEX and ascii
	STA value_n
	LDA #%00110000
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
one:
	LDA #$01
	STA value_n
	LDA #%00110001
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS

lcdSelect:
			LDA dataFlag
			INCA
			STA dataFlag
			LDA IIC_MSG
			STA disp_msg
            LDX disp_msg          
            CPX #%00100010	
			BEQ zero		
            CPX #%10000001	
			BEQ one		
            CPX #%10000010	
			BEQ two			
            CPX #%10000100
			BEQ three         
            CPX #%01000001	
			BEQ four			
            CPX #%01000010
			BEQ five			
            CPX #%01000100
			BEQ six			
            CPX #%00010001
			BEQ seven			
            CPX #%00010010
			BEQ eight						
			JSR LED_SELECT2		
			RTS
two:
	LDA #$02
	STA value_n
	LDA #%00110010
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
three:
	LDA #$03
	STA value_n
	LDA #%00110011
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
four:
	LDA #$04
	STA value_n
	LDA #%00110100
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
five:
	LDA #$05
	STA value_n
	LDA #%00110101
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
six:
	LDA #$06
	STA value_n
	LDA #%00110110
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
seven:
	LDA #$07
	STA value_n
	LDA #%00110111
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
eight:
	LDA #$08
	STA value_n
	LDA #%00111000
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
nine:
	LDA #$09
	STA value_n
	LDA #%00111001
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
AAA:
	LDA #$0A
	STA value_n
	LDA #%01000001
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS			
BBB:
	LDA #$0b
	STA value_n
	LDA #%01000010
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
LED_SELECT2:
            CPX #%00010100
			BEQ nine                       
            CPX #%10001000	
			BEQ AAA	
            CPX #%01001000	
			BEQ BBB	
            CPX #%00011000	
			BEQ CCC			
            CPX #%00101000	
			BEQ DDD			
            CPX #%00100001	
			BEQ EEE			
            CPX #%00100100	
			BEQ FFF		
			RTS
CCC:
	LDA #$0C
	STA value_n
	LDA #%01000011
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
DDD:
	LDA #$0D
	STA value_n
	LDA #%01000100
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
EEE:
	LDA #$0E
	STA value_n
	LDA #%01000101
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS
FFF:
	LDA #$0F
	STA value_n
	LDA #%01000110
	STA disp_msg
	;JSR Message_n
	LDA #$00
	STA disp_msg
	RTS       
DanOrMac:
	CLRH
	LDX IIC_MSG
	CPX #$FF
	BEQ MacDad
	CPX #$EE
	BEQ DirtyDan
	CPX #$DD
	BEQ Stop
	CPX #$CC
	BEQ tempRec
	RTS
Stop: ;displays stop
			LDA #%01010011 ;S
			STA disp_msg
			JSR Message_state
			JSR dothedelay
			
			LDA #%01010100 ;T
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01001111 ;O
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01010000 ;P
			STA disp_msg
			JSR Message_top
			JSR dothedelay
	LDA #00
	STA IIC_MSG
				
	RTS
MacDad: ;displays MAC representing our cooling state
			LDA #%01001101 ;M
			STA disp_msg
			JSR Message_state
			JSR dothedelay
			
			LDA #%01000001 ;A
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01000011 ;C
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00010000 ;" "
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			LDA #00
	STA IIC_MSG
				
	RTS
tempRec:
	JSR checkK
	RTS
DirtyDan: ;displays DAN representing our heating state
			LDA #%01000100 ;D
			STA disp_msg
			JSR Message_state
			JSR dothedelay
			
			LDA #%01000001 ;A
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01001110 ;N
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00010000 ;" "
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			LDA #00
	STA IIC_MSG
	RTS
checkK: ;checks if kelvin is in the 200s or 300s
	CLRH
	LDX #1
	LDA IIC_MSG,X
	SUB #27
	BCS fma200
	BCC fma300
	RTS
fma200: ;kelvin in 200s, write 2, add 73 to temperature
	CLRH
	LDX #1
	LDA IIC_MSG,X
	ADD #73
	STA topTemp
	
	LDA #%00110010 ;WRITES FIRST KELBIN NUMBER
	STA disp_msg
	JSR Message_temp
	JSR dothedelay	
	
	LDA topTemp
	STA temp
	JSR BCDcalc
	JSR top4Bits
	
	JSR Message_top ;WRITES second KELBIN NUMBER
	JSR dothedelay	
		
	CLRH	
	LDX BCDL
	JSR bot4Bits
	JSR Message_top ;WRITES third KELBIN NUMBER
	JSR dothedelay	
		LDA #00
	STA IIC_MSG
	RTS
fma300: ;kelvin in 300s, write 3, subtract 27 from temperature
	CLRH
	LDX #1
	LDA IIC_MSG,X
	SUB #27
	STA topTemp	
	
	LDA #%00110011 ;WRITES FIRST KELBIN NUMBER
	STA disp_msg
	JSR Message_temp
	JSR dothedelay	
	
	LDA topTemp
	STA temp
	JSR BCDcalc
	JSR top4Bits
	
	JSR Message_top ;WRITES second KELBIN NUMBER
	JSR dothedelay	
		
	CLRH	
	LDX BCDL
	JSR bot4Bits
	JSR Message_top ;WRITES third KELBIN NUMBER
	JSR dothedelay	
		LDA #00
	STA IIC_MSG
	RTS
LCDInitial:
			JSR dododelay ;first delay >15ms (16.9ms)
			JSR dododelay
			
			BCLR 1, PTAD
			
			LDA #$38
			JSR LCD_WRITE
;--------------------------------
			JSR dothedelay ;second delay >4.1ms (4.17ms)
			JSR dothedelay
			JSR dothedelay
			JSR dothedelay
			JSR dothedelay
			JSR dothedelay
			JSR dothedelay

			LDA #$38
			JSR LCD_WRITE
;--------------------------------
			JSR dothedelay ;third delay >.1ms (835us)
			
			LDA #$38
			JSR LCD_WRITE
			
		;	LDA #$38
		;	JSR LCD_WRITE
			
			LDA #%00111100
			JSR LCD_WRITE
			
			LDA #%00001000
			JSR LCD_WRITE
;--------------------------------		
			JSR dothedelay ;delay >.1ms (1670us)
			JSR dothedelay
			JSR dothedelay
			 
			LDA #$01
			JSR LCD_WRITE
			
			JSR dothedelay ;delay >.1ms (1670us)
			JSR dothedelay
			JSR dothedelay
			
			LDA #$06
			JSR LCD_WRITE
			
			LDA #$0F
			JSR LCD_WRITE
			
			LDA #$02
			JSR LCD_WRITE
			
			JSR dothedelay ;delay >.1ms (1670us)
			JSR dothedelay
			JSR dothedelay
			
			LDA #%01010100 ;write T
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01000101 ;write E
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01000011 ;write C
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00010000 ;write space
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01110011 ;write s
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01110100 ;t
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01100001 ;a
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01110100 ;t
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01100101 ;e
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00111010   ;:
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00010000 ; space
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01010100 ; T
			STA disp_msg
			JSR Message_bot
			JSR dothedelay
			
			LDA #%00111001 ; 9
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00110010 ; 2
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00111010 ; :
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00010000 ; space
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00010000 ; space
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00010000 ; space
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01001011 ; K
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01000000 ;@
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01010100 ;T
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00111010 ; :
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00010000 ; space
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00010000 ; space
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%00010000 ; space
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #%01110011 ; space
			STA disp_msg
			JSR Message_top
			JSR dothedelay
			
			LDA #$00
			STA disp_msg
			
			RTS ;ffufuu
;--------------------------------	

LCD_WRITE:
			;LDA IIC_MSG
			STA PTBD
			
			BSET 0, PTAD
			BCLR 0, PTAD
			JSR wha
			RTS    
			
LCD_ADDR:
			BSET 1, PTAD
			RTS
			

			
Message_top: ;writes to cursor location
			LDA #$84
			JSR LCD_ADDR
			;CLRX
			LDA disp_msg
			JSR LCD_WRITE
			
			RTS
			
Message_sec: ;writes to spot where we want seconds 
			BCLR 1, PTAD
			LDA #$CC
			JSR LCD_WRITE
			JSR dothedelay
			
			JSR LCD_ADDR
			;CLRX
			LDA disp_msg
			JSR LCD_WRITE
			
			RTS
Message_state: ;writes to spot where we want the state
			BCLR 1, PTAD
			LDA #$8B
			JSR LCD_WRITE
			JSR dothedelay
			
			JSR LCD_ADDR
			;CLRX
			LDA disp_msg
			JSR LCD_WRITE
			
			RTS
			
Message_temp: ;writes to spot where we want the temperature
			BCLR 1, PTAD
			LDA #%11000100
			JSR LCD_WRITE
			JSR dothedelay
			
			JSR LCD_ADDR
			;CLRX
			LDA disp_msg
			JSR LCD_WRITE
			
			RTS
Message_beg: ;writes to the first spot
			BCLR 1, PTAD
			LDA #$10
			JSR LCD_WRITE
			JSR dothedelay
			
			JSR LCD_ADDR
			;CLRX
			LDA disp_msg
			JSR LCD_WRITE
			
			RTS
	
Message_bot: ;writes to the bottom line
			BCLR 1, PTAD
			LDA #%11000000
			JSR LCD_WRITE
			JSR dothedelay	
			
			JSR LCD_ADDR
			;CLRX
			LDA disp_msg
			JSR LCD_WRITE
			
			RTS				
	
BCDcalc: ;converts decimal into hinary coded decimal
	CLRH
	LDA temp
	LDX #10
	DIV
	LSLA
	LSLA
	LSLA
	LSLA
	STA BCD
	STHX tets
	LDA tets
	ADD BCD
	STA BCD
	AND #%00001111
	STA BCDL
	LDA BCD
	AND #%11110000
	STA BCDH
	RTS
dothedelay:

	LDA #%11111111
	STA Counter
	LDA #0
	BRA delayy
	
dododelay:

	JSR dothedelay
	JSR dothedelay
	JSR dothedelay
	JSR dothedelay
	JSR dothedelay
	JSR dothedelay
	JSR dothedelay
	JSR dothedelay
	JSR dothedelay
	JSR dothedelay	
	
	
	RTS
	
wha:
	LDA #100
	STA Counter
t:
	LDA Counter
	DECA
	STA Counter
	BEQ return
	BRA t
	
delayy:
	
	LDA Counter
	DECA
	STA Counter
	
	BEQ return
	BRA delayy
	
return:
	RTS
	

returnToAvg:
	RTS

returnAvgCont: ;unused in this lab
	LDHX #$0000
	LDA total2
	LDX value_n
	
	DIV              
	
	STA total2
	
	RTS
     
IIC_Startup_slave:
	;SET BAUD RATE
	LDA #%10000111
	STA IICF
	;SET SLAVE ADDRESS
	LDA #$12
	STA IICA
	;ENABLE IIC AND INTERRUPTS
	BSET IICC_IICEN, IICC
	BSET IICC_IICIE, IICC
	BCLR IICC_MST, IICC
	RTS

_Viic:
	;CLEAR INTERRUPT
	BSET IICS_IICIF, IICS
	;MASTER MODE?
	LDA IICC
	AND #%00100000
	BEQ _Viic_slave ;YES
	;NO
	RTI

_Viic_slave:
	;ARBITRATION LOST?
	LDA IICS
	AND #%00010000
	BEQ _Viic_slave_iaas ;NO
	BCLR 4, IICS ;IF YES, CLEAR ARBITRATION LOST BIT

_Viic_slave_iaas:
	;ADDRESSED AS SLAVE?
	LDA IICS
	AND #%01000000
	BNE _Viic_slave_srw ;YES
	BRA _Viic_slave_txRx ;NO

_Viic_slave_iaas2:
	;ADDRESSED AS SLAVE?
	LDA IICS
	AND #%01000000
	BNE _Viic_slave_srw ;YES
	RTI ; NO

_Viic_slave_srw:
	;SLAVE READ/WRITE
	LDA IICS 
	AND #%00000100
	BEQ _Viic_slave_setRx ;SLAVE READS
	BRA _Viic_slave_setTx ;SLAVE WRITE

_Viic_slave_setTx:
	;TRANSMIT DATA
	BSET 4, IICC ; TRANSMIT MODE
	LDX CURRENT
	LDA IIC_MSG, X ;SELECTS CURRENT BYTE OF MESSAGE TO SEND
	STA IICD ;SENDS MESSAGE
	INCX
	STX CURRENT ;INCREMENTS CURRENT
	RTI

_Viic_slave_setRx:
	;MAKES SLAVE REASY TO RECEIVE DATA
	BCLR 4, IICC ;RECEIVE MODE
	LDA #0
	STA CURRENT 
	LDA IICD ;DUMMY READ
	RTI

_Viic_slave_txRx:
	LDA IICC
	AND #%00010000
	BEQ _Viic_slave_read ;RECEIVE
	BRA _Viic_slave_ack ;TRANSMIT

_Viic_slave_ack:
	LDA IICS
	AND #%00000001
	BEQ _Viic_slave_setTx ;YES, TRANSMIT NEXT BYTE
	BRA _Viic_slave_setRx ;NO, SWITCH TO RECEIVE

_Viic_slave_read:
	CLRH
	LDX CURRENT
	LDA IICD
	STA IIC_MSG, X ;STORE RECEIVED DATA IN IIC_MSG
	INCX
	STX CURRENT ;INCREMENT CURRENT
	LDA dataFlag
	INCA
	STA dataFlag
	
	LDA #1
	STA dataFlag
	STA recFlag
	
	RTI
            
	
top4Bits: ;FROM HERE DOWN WE CONVERT OUR BINARY CODED DECIMAL
	CLRH ;NUMBERS INTO ASCII SO WE CAN DISPLAY THEM
	LDX BCDH
	
	CPX #%00000000
	BEQ temp0
	
	CPX #%00010000
	BEQ temp1
	
	CPX #%00100000
	BEQ temp2
	
	CPX #%00110000
	BEQ temp3
	
	CPX #%01000000
	BEQ temp4
	
	CPX #%01010000
	BEQ temp5
	
	CPX #%01100000
	BEQ temp6
	
	CPX #%01110000
	BEQ temp7
	
	CPX #%10000000
	BEQ temp8
	
	CPX #%10010000
	BEQ temp9
	
	RTS

temp0:
	LDA #%00110000
	STA disp_msg
	RTS
temp1:
	LDA #%00110001
	STA disp_msg
	RTS
temp2:
	LDA #%00110010
	STA disp_msg
	RTS
temp3:
	LDA #%00110011
	STA disp_msg
	RTS
temp4:
	LDA #%00110100
	STA disp_msg
	RTS
temp5:
	LDA #%00110101
	STA disp_msg
	RTS
temp6:
	LDA #%00110110
	STA disp_msg
	RTS	
temp7:
	LDA #%00110111
	STA disp_msg
	RTS
temp8:
	LDA #%00111000
	STA disp_msg
	RTS
temp9:
	LDA #%00111001
	STA disp_msg
	RTS

bot4Bits:
	
	CPX #%00000000
	BEQ temp0
	
	CPX #%00000001
	BEQ temp1
	
	CPX #%00000010
	BEQ temp2
	
	CPX #%00000011
	BEQ temp3
	
	CPX #%00000100
	BEQ temp4
	
	CPX #%00000101
	BEQ temp5
	
	CPX #%00000110
	BEQ temp6
	
	CPX #%00000111
	BEQ temp7
	
	CPX #%00001000
	BEQ temp8
	
	CPX #%00001001
	BEQ temp9
	
	RTS



