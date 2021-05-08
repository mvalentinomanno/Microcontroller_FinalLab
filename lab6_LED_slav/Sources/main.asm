;Main.s by Cayden Seiler, Michael Valentino-Manno
;4/9/2019
;465 LAB 5 LED SLAV DEVICE
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
		IIC_MSG: DS.B 1
		

	ORG $E000


main:
_Startup:
		LDHX	#__SEG_END_SSTACK ;initialize the stack
		TXS
		
			CLI ;enables interrupts
			
			LDA #%00000011 ;kills watchdog, enables reset and background debug
			STA SOPT1 ;stores
			
			BSET 7, PTBDD
			BSET 6, PTBDD
			BSET 5, PTBDD ;Initialize needed ports/pins as outputs
			BSET 4, PTBDD
			BSET 3, PTBDD 
			BSET 2, PTBDD
			BSET 1, PTBDD
			BSET 0, PTBDD
			
			LDA #%10000000
			STA SOPT2
			
			BCLR 3, PTADD 
			BCLR 2, PTADD
			
			CLRH
			
			LDA #$00
	        STA PTBD
			
			JSR IIC_Startup_slave
			
mainLoop:

			LDX #1
			LDA IIC_MSG, X ;Load recieved IIC
			CLRX
			

			JSR ledSelect
            BRA mainLoop  
            
zero: ;CODE FROM HERE DOWN CONVERTS KEYPRESS INTO HEX VALUYE
	LDA #$00
	STA PTBD
	RTS
one:
	LDA #$01
	STA PTBD
	RTS
two:
	LDA #$2
	STA PTBD
	RTS
three:
	LDA #$03
	STA PTBD
	RTS
four:
	LDA #$04
	STA PTBD
	RTS
five:
	LDA #$05
	STA PTBD
	RTS
six:
	LDA #$06
	STA PTBD
	RTS
seven:
	LDA #$07
	STA PTBD
	RTS
eight:
	LDA #$08
	STA PTBD
	RTS
nine:
	LDA #$09
	STA PTBD
	RTS
AAA:
	LDA #$0A
	STA PTBD
	RTS
BBB:
	LDA #$0B
	STA PTBD
	RTS
CCC:
	LDA #$0C
	STA PTBD
	RTS
DDD:
	LDA #$0D
	STA PTBD
	RTS
EEE:
	LDA #$0E
	STA PTBD
	RTS
FFF:
	LDA #$0F
	STA PTBD
	RTS

ledSelect:

            LDX IIC_MSG
            
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
            
IIC_Startup_slave:
	;SET BAUD RATE
	LDA #%10000111
	STA IICF
	;SET SLAVE ADDRESS
	LDA #$10
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
	RTI
            


