;Main.s by Cayden Seiler, Michael Valentino-Manno
;4/9/2019
;465 5 MASTER DEVICE
            INCLUDE 'derivative.inc'
            XDEF _Startup, main, Steve, _Viic
            XREF __SEG_END_SSTACK   
; symbol defined by the linker for the end of the stack
; variable/data section

	ORG $0060

FullKeypad DS.B 1 ;variable for testing
IIC_addr DS.B 1 ;track iic LED address
IIC_addrLCD DS.B 1
IIC_addrLED DS.B 1
msgLength DS.B 1 ;tracks length
current DS.B 1 ;track which byte we sent
IIC_msg DS.B 7 ;enable 32 bit transmission ;NEED 2 BYTES

triggered DS.B 1 ;flag

KEYPRESS_COL DS.B 1
KEYPRESS_ROW DS.B 1
Counter DS.B 1
flag DS.B 1
count DS.B 1
value_n DS.B 1
perCount DS.B 1
BCD DS.B 1	
tets DS.B 2
total DS.B 1
counter DS.B 1
dateCounter DS.B 1
date DS.B 1
dateLeft DS.B 1
dateRight DS.B 1
front DS.B 1
arg DS.B 1
firstTime DS.B 1
boo DS.B 1
secondTime DS.B 1
bones DS.B 1
LCD_MSG DS.B 1
tortoiseWinsTheRace DS.B 1
tempLeft DS.B 1
temperature DS.B 1
	ORG $E000
main:



_Startup:

		LDHX	#__SEG_END_SSTACK ;initialize the stack
		TXS
		
			LDA #%00000000 ;enable keyboard interrupts
			STA KBISC
			
			LDA #%00000011 ;kills watchdog, enables reset and background debug
			STA SOPT1 ;stores
			
			LDA SOPT2
			ORA #%00000010
			STA SOPT2
			
			MOV #$10, IIC_addrLED ;set slave address
			MOV #$12, IIC_addrLCD ;set slave address
			MOV #$C1, IIC_msg ;set msg
			
			JSR IIC_Startup_Master
			
			LDA #1
			STA count	
			
			LDA #$00 ;disable the pull ups on inputs
			STA PTAPE
			STA value_n
			STA perCount
			STA dateCounter
			STA front
			STA firstTime
			STA boo
			STA secondTime
			STA bones
			STA LCD_MSG
			STA tortoiseWinsTheRace
			CLRH
			LDA #%00001111 ;setup inputs enabled
			STA KBIPE
			
			LDA #%11111111 ;rising edge sensitive
			STA KBIES
			
			BSET 5, PTBDD ;Initialize needed ports/pins as outputs
			BSET 4, PTBDD
			BSET 3, PTBDD 
			BSET 2, PTBDD
			
			BCLR 3, PTADD
			CLRH
			
			LDA #%00000010 ;enable keyboard interrupts
			STA KBISC
			LDX #1
			CLI ;enables interrupts

mainLoop:
	LDA #0
	STA total
	
	JSR DELAY ;used for clarity on oscope
	JSR DELAY
	JSR DELAY
	
	LDA #$20
	STA PTBD

	JSR dododelay
	
	LDA KEYPRESS_COL
	STA IIC_msg
	
	LDA #$08
	STA PTBD

	JSR dododelay

	LDA #$10
	STA PTBD
	
	JSR dododelay
		
	LDA #$04
	STA PTBD
	
	JSR dododelay
	
	JSR toSend
	
	JSR dododelay
	CLRH
	
	JSR spooky
	
	JSR zombie
	JSR race
	LDX boo
	CPX #1
	BEQ hare 
	
	BRA mainLoop ;loop forever

zombie:
	LDX bones
	CPX #1
	BEQ skeletons
	RTS
returnMain2:
	BRA mainLoop
skeletons: ;sends to DS1337
	LDA #1 ;set msg length 1 byte
	STA msgLength
	LDA LCD_MSG
	STA IIC_msg
	LDA IIC_addrLCD
    STA IIC_addr
    
	JSR IIC_DataWrite ;lcd
    
	JSR dododelay	
	JSR dododelay

	CLRH
	LDA #$D0
	STA IIC_addr
	LDA #2
	STA msgLength
	LDA #$00
	LDX #0
	STA IIC_msg,X
	LDX #1
	LDA #$01
	STA IIC_msg,X
	JSR IIC_DataWrite
	JSR DELAY
	LDA #0
	STA bones
	
	RTS
spooky: ;checks flag
	LDX secondTime
	CPX #1
	BEQ scaryGhosts
	RTS
scaryGhosts: ;resets flag
	LDA #1
	STA boo
	RTS
returnMain:
	BRA returnMain2
race:
	LDX tortoiseWinsTheRace ;checks flag
	CPX #4 ;4 so the temp is written approximatly 2 seconds
	BEQ tortoise
	RTS
hare: ;hare receives the seconds from the DS1337
	CLRH
	LDA #$D0
	STA IIC_addr
	LDA #1
	STA msgLength
	LDA #$00
	LDX #0
	STA IIC_msg,X
	
	JSR IIC_DataWrite
	JSR dododelay
	JSR dododelay
	JSR dododelay
	
	LDA #$D1
	STA IIC_addr
	LDA #1
	STA msgLength
	JSR IIC_DataWrite
	
	JSR dododelay
	JSR dododelay
	
	LDA IIC_addrLCD
	STA IIC_addr
	LDA #1
	STA msgLength
	JSR IIC_DataWrite
	
	LDA tortoiseWinsTheRace
	INCA
	STA tortoiseWinsTheRace
	
    JSR dododelay
	JSR dododelay
    JSR dododelay
	JSR dododelay
    JSR dododelay
	
	BRA returnMain
returnMain3:
	BRA returnMain
tortoise: ;receives temperature and sends to LCD
	;LDA #$00
	;STA IIC_addr
	;STA IIC_msg ;DO WE NEED 
	;LDA #1
	;STA msgLength
	;JSR IIC_DataWrite	
   ; JSR dododelay
   ; JSR dododelay	
	
	LDA #%10010001
	STA IIC_addr
	LDA #1
	STA msgLength
	JSR IIC_DataWrite	
    JSR dododelay
    JSR dododelay
    CLRH
    LDX #0
    LDA IIC_msg,X
    LSLA
    STA tempLeft
    LDX #1
    LDA IIC_msg,X
    LSRA
    LSRA
    LSRA
    LSRA
    LSRA
    LSRA
    LSRA
    STA temperature
    AND #%00000001
    ADD tempLeft
    STA tempLeft
	
    STA temperature
    CLRH
    LDX #1
    STA IIC_msg,X
    NOP
    LDA #$CC
    LDX #0
    STA IIC_msg,X
	
	LDA #2 ;set msg length 1 byte   SEND TEMP TO LCD
	STA msgLength
	LDA IIC_addrLCD
    STA IIC_addr
	JSR IIC_DataWrite ;lcd

	JSR dododelay
    JSR dododelay

	LDA #0
	STA tortoiseWinsTheRace
	RTS
sendit: ;unused in this lab
	LDA #0
	STA triggered
	LDA #1
	STA flag
	LDA IIC_addrLCD
    STA IIC_addr
    CLRH
    LDX #1 ;?
	;JSR IIC_DataWrite ;lcd NEED THIS EVENTUALLY
	BRA returnMain3

toSend: ;unused in this lab
    LDX triggered
	CPX #01
	BEQ sendit
	RTS

BCDcalc: ;converts to binary coded decimal
	CLRH
	LDA total
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
	STA IIC_msg
	STA total
	RTS
	
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
	
delayy:
	
	LDA Counter
	DECA
	STA Counter
	
	BEQ return
	BRA delayy

return:

	RTS
	
dothedelay:

	LDA #%11111111
	STA Counter
	LDA #0
	BRA delayy

Steve: ;steve is our keyboard intterupt
	LDA PTAD
	AND #%00001111
	STA KEYPRESS_COL
	
	LDA PTBD
	ASLA
	ASLA
	AND #%11110000
	STA KEYPRESS_ROW
	
	ADD KEYPRESS_COL
	STA KEYPRESS_COL
	STA IIC_msg
		
	JSR dododelay
	JSR dododelay
	
	CLRH
	
	LDA #1 ;set msg length 1 byte
	STA msgLength

	LDA IIC_addrLED
    STA IIC_addr
    
	JSR IIC_DataWrite ;led
	
	JSR dododelay
	JSR dododelay
	
	CLRH
	LDX IIC_msg
	JSR numSelect
	
	JSR whatTime
	LDA #1
	STA triggered
	STA firstTime
	
	BSET 2, KBISC ;clear keyboard interrupt
	RTI
whatTime:;handles the automatic intterupt firing on startup
	LDX firstTime
	CPX #1
	BEQ second
	RTS
second:
	LDA #1
	STA secondTime
	STA bones
	RTS
zero: ;CODE FROM HERE DOWN CONVERTS KEYPRESS INBTO HEX
	LDA #$00
	STA value_n
	STA dateRight
	LDA #$DD
	STA LCD_MSG
	RTS
one:
	LDA #$01
	STA value_n
	STA dateRight
	LDA #$FF
	STA LCD_MSG
	RTS
two:
	LDA #$02
	STA value_n
	STA dateRight
	RTS
three:
	LDA #$03
	STA value_n
	STA dateRight
	RTS

numSelect:
           ; LDX IIC_msg          
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
			RTS
four:
	LDA #$04
	STA value_n
	STA dateRight
	RTS
five:
	LDA #$05
	STA value_n
	STA dateRight
	RTS
six:
	LDA #$06
	STA value_n
	STA dateRight
	RTS
seven:
	LDA #$07
	STA value_n
	STA dateRight
	RTS
eight:
	LDA #$08
	STA value_n
	STA dateRight
	LDA #$EE
	STA LCD_MSG
	RTS
nine:
	LDA #$09
	STA value_n
	STA dateRight
	RTS	
	
_Viic:
	BSET IICS_IICIF, IICS ;clear interrupt
	BRSET IICC_MST, IICC, _Viic_master ;check master, should never be slave
	RTI

_Viic_master:
	BRSET IICC_TX, IICC, _Viic_master_TX ;for transfer
	BRA _Viic_master_RX ;for receive

_Viic_master_TX:
	LDA msgLength
	SUB current
	BNE _Viic_master_rxAck ;not the last byte
	
	BCLR IICC_MST, IICC ;is last byte
	BSET IICS_ARBL, IICS
	
	RTI

_Viic_master_rxAck:
	BRCLR IICS_RXAK, IICS, _Viic_master_EoAC ;ack received from the slave device
	BCLR IICC_MST,IICC ;no ack from slave received
	RTI

_Viic_master_EoAC:
	;read from or transfer to slave?
	LDA IIC_addr ;check if transfer or read
	AND #%00000001
	BNE _Viic_master_toRxMode
	
	LDX current
	LDA IIC_msg,X ;NEED TO USE INDEX OFFSET TO SEND BOTH BYTES OF IIC msg
	STA IICD
	
	;LDA #255
	;loop_test:
	;DECA 
	;BNE loop_test
	
	;INCX
	;CPX #2
;	BNE _Viic_master_EoAC ;yes
	
	LDA current
	INCA
	STA current
	
	RTI

_Viic_master_toRxMode:
	BCLR IICC_TX, IICC ;dummy read for EoAC
	LDA IICD
	RTI

_Viic_master_RX:
	BCLR IICC_TXAK, IICC ;tx ack
	;last byte to be read
	LDA msgLength
	SUB current
	BEQ _Viic_master_rxStop
	
	;2nd to last byte to be read?
	DECA
	BEQ _Viic_master_txAck
	BRA _Viic_master_readData

_Viic_master_rxStop:
	BCLR IICC_MST, IICC ;send stop bit
	BRA _Viic_master_readData

_Viic_master_txAck:
	BSET IICC_TXAK, IICC ;tx ack
	BRA _Viic_master_readData

_Viic_master_readData:
	CLRH
	LDX current

	;read byte from IICD and store into IIC_msg
	LDA IICD
	STA IIC_msg, X ;store msg into indexed location
	
	LDA current ;inc current
	INCA
	STA current
	
	RTI ;leave interrupt

IIC_Startup_Master:
	;set baud rate to 50kbps
	LDA #%10000111
	STA IICF
	
	;enable IIC and interrupts
	BSET IICC_IICEN,IICC
	BSET IICC_IICIE,IICC
	RTS

IIC_DataWrite:
	LDA #0 ;initialize current
	STA current
	
	BSET 5, IICC ;IICC_MST, IICC ; set master mode
	BSET IICC_TX, IICC ;set transmit
	LDA IIC_addr ;send slave address
	STA IICD
	RTS

DELAY:
	LDA #255
	STA $120
	loop1:
		LDA #255
		STA $121
		loop2:
			LDA $121
			DECA
			STA $121
			BNE loop2
		LDA $120
		DECA
		STA $120
		BNE loop1
	RTS
	
