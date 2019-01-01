;/////////////////////////////////////////////////////////////////////////////////
;// Code Generator: BoostC Compiler - http://www.sourceboost.com
;// Version       : 6.60
;// License Type  : Pro License
;// Limitations   : PIC18 max code size:Unlimited, max RAM banks:Unlimited
;/////////////////////////////////////////////////////////////////////////////////

	include "P18F452.inc"
__HEAPSTART                      EQU	0x00000034 ; Start address of heap 
__HEAPEND                        EQU	0x000005FF ; End address of heap 
gbl_porta                        EQU	0x00000F80 ; bytes:1
gbl_portb                        EQU	0x00000F81 ; bytes:1
gbl_portc                        EQU	0x00000F82 ; bytes:1
gbl_portd                        EQU	0x00000F83 ; bytes:1
gbl_porte                        EQU	0x00000F84 ; bytes:1
gbl_lata                         EQU	0x00000F89 ; bytes:1
gbl_latb                         EQU	0x00000F8A ; bytes:1
gbl_latc                         EQU	0x00000F8B ; bytes:1
gbl_latd                         EQU	0x00000F8C ; bytes:1
gbl_late                         EQU	0x00000F8D ; bytes:1
gbl_trisa                        EQU	0x00000F92 ; bytes:1
gbl_trisb                        EQU	0x00000F93 ; bytes:1
gbl_trisc                        EQU	0x00000F94 ; bytes:1
gbl_trisd                        EQU	0x00000F95 ; bytes:1
gbl_trise                        EQU	0x00000F96 ; bytes:1
gbl_pie1                         EQU	0x00000F9D ; bytes:1
gbl_pir1                         EQU	0x00000F9E ; bytes:1
gbl_ipr1                         EQU	0x00000F9F ; bytes:1
gbl_pie2                         EQU	0x00000FA0 ; bytes:1
gbl_pir2                         EQU	0x00000FA1 ; bytes:1
gbl_ipr2                         EQU	0x00000FA2 ; bytes:1
gbl_eecon1                       EQU	0x00000FA6 ; bytes:1
gbl_eecon2                       EQU	0x00000FA7 ; bytes:1
gbl_eedata                       EQU	0x00000FA8 ; bytes:1
gbl_eeadr                        EQU	0x00000FA9 ; bytes:1
gbl_rcsta                        EQU	0x00000FAB ; bytes:1
gbl_txsta                        EQU	0x00000FAC ; bytes:1
gbl_txreg                        EQU	0x00000FAD ; bytes:1
gbl_rcreg                        EQU	0x00000FAE ; bytes:1
gbl_spbrg                        EQU	0x00000FAF ; bytes:1
gbl_t3con                        EQU	0x00000FB1 ; bytes:1
gbl_tmr3l                        EQU	0x00000FB2 ; bytes:1
gbl_tmr3h                        EQU	0x00000FB3 ; bytes:1
gbl_ccp2con                      EQU	0x00000FBA ; bytes:1
gbl_ccpr2l                       EQU	0x00000FBB ; bytes:1
gbl_ccpr2h                       EQU	0x00000FBC ; bytes:1
gbl_ccp1con                      EQU	0x00000FBD ; bytes:1
gbl_ccpr1l                       EQU	0x00000FBE ; bytes:1
gbl_ccpr1h                       EQU	0x00000FBF ; bytes:1
gbl_adcon1                       EQU	0x00000FC1 ; bytes:1
gbl_adcon0                       EQU	0x00000FC2 ; bytes:1
gbl_adresl                       EQU	0x00000FC3 ; bytes:1
gbl_adresh                       EQU	0x00000FC4 ; bytes:1
gbl_sspcon2                      EQU	0x00000FC5 ; bytes:1
gbl_sspcon1                      EQU	0x00000FC6 ; bytes:1
gbl_sspstat                      EQU	0x00000FC7 ; bytes:1
gbl_sspadd                       EQU	0x00000FC8 ; bytes:1
gbl_sspbuf                       EQU	0x00000FC9 ; bytes:1
gbl_t2con                        EQU	0x00000FCA ; bytes:1
gbl_pr2                          EQU	0x00000FCB ; bytes:1
gbl_tmr2                         EQU	0x00000FCC ; bytes:1
gbl_t1con                        EQU	0x00000FCD ; bytes:1
gbl_tmr1l                        EQU	0x00000FCE ; bytes:1
gbl_tmr1h                        EQU	0x00000FCF ; bytes:1
gbl_rcon                         EQU	0x00000FD0 ; bytes:1
gbl_wdtcon                       EQU	0x00000FD1 ; bytes:1
gbl_lvdcon                       EQU	0x00000FD2 ; bytes:1
gbl_osccon                       EQU	0x00000FD3 ; bytes:1
gbl_t0con                        EQU	0x00000FD5 ; bytes:1
gbl_tmr0l                        EQU	0x00000FD6 ; bytes:1
gbl_tmr0h                        EQU	0x00000FD7 ; bytes:1
gbl_status                       EQU	0x00000FD8 ; bytes:1
gbl_fsr2l                        EQU	0x00000FD9 ; bytes:1
gbl_fsr2h                        EQU	0x00000FDA ; bytes:1
gbl_plusw2                       EQU	0x00000FDB ; bytes:1
gbl_preinc2                      EQU	0x00000FDC ; bytes:1
gbl_postdec2                     EQU	0x00000FDD ; bytes:1
gbl_postinc2                     EQU	0x00000FDE ; bytes:1
gbl_indf2                        EQU	0x00000FDF ; bytes:1
gbl_bsr                          EQU	0x00000FE0 ; bytes:1
gbl_fsr1l                        EQU	0x00000FE1 ; bytes:1
gbl_fsr1h                        EQU	0x00000FE2 ; bytes:1
gbl_plusw1                       EQU	0x00000FE3 ; bytes:1
gbl_preinc1                      EQU	0x00000FE4 ; bytes:1
gbl_postdec1                     EQU	0x00000FE5 ; bytes:1
gbl_postinc1                     EQU	0x00000FE6 ; bytes:1
gbl_indf1                        EQU	0x00000FE7 ; bytes:1
gbl_wreg                         EQU	0x00000FE8 ; bytes:1
gbl_fsr0l                        EQU	0x00000FE9 ; bytes:1
gbl_fsr0h                        EQU	0x00000FEA ; bytes:1
gbl_plusw0                       EQU	0x00000FEB ; bytes:1
gbl_preinc0                      EQU	0x00000FEC ; bytes:1
gbl_postdec0                     EQU	0x00000FED ; bytes:1
gbl_postinc0                     EQU	0x00000FEE ; bytes:1
gbl_indf0                        EQU	0x00000FEF ; bytes:1
gbl_intcon3                      EQU	0x00000FF0 ; bytes:1
gbl_intcon2                      EQU	0x00000FF1 ; bytes:1
gbl_intcon                       EQU	0x00000FF2 ; bytes:1
gbl_prodl                        EQU	0x00000FF3 ; bytes:1
gbl_prodh                        EQU	0x00000FF4 ; bytes:1
gbl_tablat                       EQU	0x00000FF5 ; bytes:1
gbl_tblptrl                      EQU	0x00000FF6 ; bytes:1
gbl_tblptrh                      EQU	0x00000FF7 ; bytes:1
gbl_tblptru                      EQU	0x00000FF8 ; bytes:1
gbl_pcl                          EQU	0x00000FF9 ; bytes:1
gbl_pclath                       EQU	0x00000FFA ; bytes:1
gbl_pclatu                       EQU	0x00000FFB ; bytes:1
gbl_stkptr                       EQU	0x00000FFC ; bytes:1
gbl_tosl                         EQU	0x00000FFD ; bytes:1
gbl_tosh                         EQU	0x00000FFE ; bytes:1
gbl_tosu                         EQU	0x00000FFF ; bytes:1
gbl_ck_tris                      EQU	0x00000F93 ; bit:6
gbl_cs_tris                      EQU	0x00000F93 ; bit:7
gbl_so_tris                      EQU	0x00000F93 ; bit:5
gbl_ck_out                       EQU	0x00000F8A ; bit:6
gbl_cs_out                       EQU	0x00000F8A ; bit:7
gbl_so_in                        EQU	0x00000F81 ; bit:5
gbl_isthcopen                    EQU	0x0000001D ; bytes:1
gbl_disoff_tris                  EQU	0x00000F93 ; bit:0
gbl_disoff_out                   EQU	0x00000F81 ; bit:0
gbl_5_tbuff                      EQU	0x00000013 ; bytes:4
gbl_5_digit                      EQU	0x0000001E ; bytes:1
gbl_5_interrupt_timer            EQU	0x00000001 ; bytes:2
gbl_map                          EQU	0x00000009 ; bytes:10
gbl_open                         EQU	0x00000017 ; bytes:4
CompGblVar32                     EQU	0x0000001F ; bit:0
interrupt_1_mask                 EQU	0x00000030 ; bytes:1
CompTempVar114                   EQU	0x00000031 ; bytes:1
CompTempVar116                   EQU	0x00000031 ; bytes:1
CompTempVar118                   EQU	0x00000032 ; bytes:1
CompTempVar121                   EQU	0x00000033 ; bytes:1
format_00000_arg_value           EQU	0x00000021 ; bytes:2
CompTempVar123                   EQU	0x00000023 ; bytes:1
CompTempVar124                   EQU	0x00000024 ; bytes:1
main_1_data                      EQU	0x00000003 ; bytes:2
CompGblVar33                     EQU	0x0000001F ; bit:1
CompGblVar34                     EQU	0x0000001F ; bit:2
CompTempVarRet129                EQU	0x00000022 ; bytes:2
max6675_re_00008_1_i             EQU	0x00000020 ; bytes:1
max6675_re_00008_1_temp          EQU	0x0000001B ; bytes:2
CompTempVar130                   EQU	0x00000021 ; bytes:1
CompTempVar133                   EQU	0x00000021 ; bytes:1
__div_16_1_00003_arg_a           EQU	0x00000023 ; bytes:2
__div_16_1_00003_arg_b           EQU	0x00000025 ; bytes:2
CompTempVarRet139                EQU	0x0000002E ; bytes:2
__div_16_1_00003_1_r             EQU	0x0000002B ; bytes:2
__div_16_1_00003_1_i             EQU	0x0000002D ; bytes:1
__rem_16_1_00004_arg_a           EQU	0x00000027 ; bytes:2
__rem_16_1_00004_arg_b           EQU	0x00000029 ; bytes:2
CompTempVarRet141                EQU	0x0000002E ; bytes:2
__rem_16_1_00004_1_c             EQU	0x0000002B ; bytes:2
__rem_16_1_00004_1_i             EQU	0x0000002D ; bytes:1
CompGblVar35                     EQU	0x0000001F ; bit:3
CompGblVar36                     EQU	0x0000001F ; bit:4
delay_100u_00000_arg_del         EQU	0x00000031 ; bytes:1
Int1Context                      EQU	0x00000005 ; bytes:4
	ORG 0x00000000
	GOTO	_startup
	ORG 0x00000008
	GOTO	interrupt
	ORG 0x0000000C
delay_100u_00000
; { delay_100us ; function begin
	MOVF delay_100u_00000_arg_del, F
	BTFSS STATUS,Z
	GOTO	label4026531851
	RETURN
label4026531851
	MOVLW 0x18
label4026531852
	ADDLW 0xFF
	BTFSS STATUS,Z
	GOTO	label4026531852
	DECFSZ delay_100u_00000_arg_del, F
	GOTO	label4026531851
	RETURN
; } delay_100us function end

	ORG 0x00000028
__rem_16_1_00004
; { __rem_16_16 ; function begin
; VAR_LIFETIME_BEGIN:$ret Id:0x10000286
	CLRF CompTempVarRet141
	CLRF CompTempVarRet141+D'1'
	CLRF __rem_16_1_00004_1_c
	CLRF __rem_16_1_00004_1_c+D'1'
	CLRF __rem_16_1_00004_1_i
label268436110
	BTFSC __rem_16_1_00004_1_i,4
	RETURN
	BCF STATUS,C
	RLCF __rem_16_1_00004_1_c, F
	RLCF __rem_16_1_00004_1_c+D'1', F
	RLCF __rem_16_1_00004_arg_a, F
	RLCF __rem_16_1_00004_arg_a+D'1', F
	RLCF CompTempVarRet141, F
	RLCF CompTempVarRet141+D'1', F
	MOVF __rem_16_1_00004_arg_b, W
	SUBWF CompTempVarRet141, W
	MOVF __rem_16_1_00004_arg_b+D'1', W
	CPFSEQ CompTempVarRet141+D'1'
	SUBWF CompTempVarRet141+D'1', W
	BNC	label268436115
	MOVF __rem_16_1_00004_arg_b, W
	SUBWF CompTempVarRet141, F
	MOVF __rem_16_1_00004_arg_b+D'1', W
	SUBWFB CompTempVarRet141+D'1', F
	BSF __rem_16_1_00004_1_c,0
label268436115
	INCF __rem_16_1_00004_1_i, F
	BRA	label268436110
	RETURN
; } __rem_16_16 function end

	ORG 0x00000060
__div_16_1_00003
; { __div_16_16 ; function begin
	CLRF __div_16_1_00003_1_r
	CLRF __div_16_1_00003_1_r+D'1'
; VAR_LIFETIME_BEGIN:$ret Id:0x1000026E
	CLRF CompTempVarRet139
	CLRF CompTempVarRet139+D'1'
	CLRF __div_16_1_00003_1_i
label268436086
	BTFSC __div_16_1_00003_1_i,4
	RETURN
	BCF STATUS,C
	RLCF CompTempVarRet139, F
	RLCF CompTempVarRet139+D'1', F
	RLCF __div_16_1_00003_arg_a, F
	RLCF __div_16_1_00003_arg_a+D'1', F
	RLCF __div_16_1_00003_1_r, F
	RLCF __div_16_1_00003_1_r+D'1', F
	MOVF __div_16_1_00003_arg_b, W
	SUBWF __div_16_1_00003_1_r, W
	MOVF __div_16_1_00003_arg_b+D'1', W
	CPFSEQ __div_16_1_00003_1_r+D'1'
	SUBWF __div_16_1_00003_1_r+D'1', W
	BNC	label268436091
	MOVF __div_16_1_00003_arg_b, W
	SUBWF __div_16_1_00003_1_r, F
	MOVF __div_16_1_00003_arg_b+D'1', W
	SUBWFB __div_16_1_00003_1_r+D'1', F
	BSF CompTempVarRet139,0
label268436091
	INCF __div_16_1_00003_1_i, F
	BRA	label268436086
	RETURN
; } __div_16_16 function end

	ORG 0x00000098
max6675_re_00008
; { max6675_read_temp ; function begin
	BTFSC CompGblVar33,1
	BRA	label268435983
	CLRF max6675_re_00008_1_i
	BSF CompGblVar33,1
label268435983
	BTFSC CompGblVar34,2
	BRA	label268435984
	CLRF max6675_re_00008_1_temp
	CLRF max6675_re_00008_1_temp+D'1'
	BSF CompGblVar34,2
label268435984
	BCF gbl_cs_out,7
	NOP
	CLRF max6675_re_00008_1_i
label268435991
	MOVLW 0x10
	CPFSLT max6675_re_00008_1_i
	BRA	label268435992
	CLRF CompTempVar130
	BTFSC gbl_so_in,5
	INCF CompTempVar130, F
	MOVF CompTempVar130, W
	IORWF max6675_re_00008_1_temp, F
	BCF STATUS,C
	RLCF max6675_re_00008_1_temp, F
	RLCF max6675_re_00008_1_temp+D'1', F
	BSF gbl_ck_out,6
	NOP
	BCF gbl_ck_out,6
	INCF max6675_re_00008_1_i, F
	BRA	label268435991
label268435992
	BTFSS max6675_re_00008_1_temp,2
	BRA	label268436009
	MOVLW 0x01
	MOVWF gbl_isthcopen
	BRA	label268436012
label268436009
	CLRF gbl_isthcopen
label268436012
	BSF gbl_cs_out,7
	MOVF max6675_re_00008_1_temp, W
	MOVWF CompTempVar133
	MOVF max6675_re_00008_1_temp+D'1', W
; VAR_LIFETIME_BEGIN:$ret Id:0x1000020B
	MOVWF CompTempVarRet129+D'1'
	RLCF CompTempVarRet129+D'1', W
	RRCF CompTempVarRet129+D'1', F
	RRCF CompTempVar133, F
	RLCF CompTempVarRet129+D'1', W
	RRCF CompTempVarRet129+D'1', F
	RRCF CompTempVar133, F
	RLCF CompTempVarRet129+D'1', W
	RRCF CompTempVarRet129+D'1', F
	RRCF CompTempVar133, W
	MOVWF CompTempVarRet129
	RETURN
; } max6675_read_temp function end

	ORG 0x000000FC
max6675_in_00007
; { max6675_init ; function begin
	BCF gbl_ck_tris,6
	BCF gbl_ck_out,6
	BCF gbl_cs_tris,7
	BSF gbl_cs_out,7
	BSF gbl_so_tris,5
	RETURN
; } max6675_init function end

	ORG 0x00000108
init_Timer_00009
; { init_Timer0 ; function begin
	BSF gbl_t0con,7
	BSF gbl_t0con,6
	BCF gbl_t0con,5
	BCF gbl_t0con,3
	BCF gbl_t0con,0
	BSF gbl_t0con,1
	BCF gbl_t0con,2
	CLRF gbl_tmr0l
	BCF gbl_intcon,2
	BSF gbl_intcon,5
	BSF gbl_intcon,7
	RETURN
; } init_Timer0 function end

	ORG 0x00000120
format_00000
; { format ; function begin
	MOVLW 0x0A
	MULWF format_00000_arg_value
	MOVF PRODL, W
	MOVWF CompTempVar123
	MOVF PRODH, W
	MOVWF CompTempVar124
	MOVLW 0x0A
	MULWF format_00000_arg_value+D'1'
	MOVF PRODL, W
	ADDWF CompTempVar124, F
	MOVF CompTempVar123, W
	MOVWF format_00000_arg_value
	MOVF CompTempVar124, W
	MOVWF format_00000_arg_value+D'1'
	BCF STATUS,C
	RRCF format_00000_arg_value+D'1', F
	RRCF format_00000_arg_value, F
	BCF STATUS,C
	RRCF format_00000_arg_value+D'1', F
	RRCF format_00000_arg_value, F
	MOVF format_00000_arg_value, W
	MOVWF __rem_16_1_00004_arg_a
	MOVF format_00000_arg_value+D'1', W
	MOVWF __rem_16_1_00004_arg_a+D'1'
	MOVLW 0x0A
	MOVWF __rem_16_1_00004_arg_b
	CLRF __rem_16_1_00004_arg_b+D'1'
	CALL __rem_16_1_00004
; VAR_LIFETIME_END:$ret Id:0x10000286
	MOVF CompTempVarRet141, W
	MOVWF gbl_5_tbuff
	MOVF format_00000_arg_value, W
	MOVWF __div_16_1_00003_arg_a
	MOVF format_00000_arg_value+D'1', W
	MOVWF __div_16_1_00003_arg_a+D'1'
	MOVLW 0x0A
	MOVWF __div_16_1_00003_arg_b
	CLRF __div_16_1_00003_arg_b+D'1'
	CALL __div_16_1_00003
	MOVF CompTempVarRet139, W
	MOVWF __rem_16_1_00004_arg_a
; VAR_LIFETIME_END:$ret Id:0x1000026E
	MOVF CompTempVarRet139+D'1', W
	MOVWF __rem_16_1_00004_arg_a+D'1'
	MOVLW 0x0A
	MOVWF __rem_16_1_00004_arg_b
	CLRF __rem_16_1_00004_arg_b+D'1'
	CALL __rem_16_1_00004
; VAR_LIFETIME_END:$ret Id:0x10000286
	MOVF CompTempVarRet141, W
	MOVWF gbl_5_tbuff+D'1'
	MOVF format_00000_arg_value, W
	MOVWF __div_16_1_00003_arg_a
	MOVF format_00000_arg_value+D'1', W
	MOVWF __div_16_1_00003_arg_a+D'1'
	MOVLW 0x64
	MOVWF __div_16_1_00003_arg_b
	CLRF __div_16_1_00003_arg_b+D'1'
	CALL __div_16_1_00003
	MOVF CompTempVarRet139, W
	MOVWF __rem_16_1_00004_arg_a
; VAR_LIFETIME_END:$ret Id:0x1000026E
	MOVF CompTempVarRet139+D'1', W
	MOVWF __rem_16_1_00004_arg_a+D'1'
	MOVLW 0x0A
	MOVWF __rem_16_1_00004_arg_b
	CLRF __rem_16_1_00004_arg_b+D'1'
	CALL __rem_16_1_00004
; VAR_LIFETIME_END:$ret Id:0x10000286
	MOVF CompTempVarRet141, W
	MOVWF gbl_5_tbuff+D'2'
	MOVF format_00000_arg_value, W
	MOVWF __div_16_1_00003_arg_a
	MOVF format_00000_arg_value+D'1', W
	MOVWF __div_16_1_00003_arg_a+D'1'
	MOVLW 0xE8
	MOVWF __div_16_1_00003_arg_b
	MOVLW 0x03
	MOVWF __div_16_1_00003_arg_b+D'1'
	CALL __div_16_1_00003
	MOVF CompTempVarRet139, W
	MOVWF __rem_16_1_00004_arg_a
; VAR_LIFETIME_END:$ret Id:0x1000026E
	MOVF CompTempVarRet139+D'1', W
	MOVWF __rem_16_1_00004_arg_a+D'1'
	MOVLW 0x0A
	MOVWF __rem_16_1_00004_arg_b
	CLRF __rem_16_1_00004_arg_b+D'1'
	CALL __rem_16_1_00004
; VAR_LIFETIME_END:$ret Id:0x10000286
	MOVF CompTempVarRet141, W
	MOVWF gbl_5_tbuff+D'3'
	RETURN
; } format function end

	ORG 0x000001DA
main
; { main ; function begin
	BTFSC CompGblVar32,0
	BRA	label268435773
	CLRF main_1_data
	CLRF main_1_data+D'1'
	BSF CompGblVar32,0
label268435773
	CLRF gbl_trisd
	SETF gbl_portd
	CLRF gbl_trisc
	CLRF gbl_portc
	BCF gbl_disoff_tris,0
	BSF gbl_disoff_out,0
	CALL init_Timer_00009
	CALL max6675_in_00007
label268435784
	MOVLW 0x96
	CPFSLT gbl_5_interrupt_timer
	TSTFSZ gbl_5_interrupt_timer+D'1'
	TSTFSZ gbl_5_interrupt_timer+D'1'
	BRA	label4026531891
	BRA	label268435784
label4026531891
	BTFSC gbl_5_interrupt_timer+D'1',7
	BRA	label268435784
	CLRF gbl_5_interrupt_timer
	CLRF gbl_5_interrupt_timer+D'1'
	BCF gbl_intcon,5
	CALL max6675_re_00008
	MOVF CompTempVarRet129, W
	MOVWF main_1_data
; VAR_LIFETIME_END:$ret Id:0x1000020B
	MOVF CompTempVarRet129+D'1', W
	MOVWF main_1_data+D'1'
	MOVF main_1_data, W
	MOVWF format_00000_arg_value
	MOVF main_1_data+D'1', W
	MOVWF format_00000_arg_value+D'1'
	CALL format_00000
	BSF gbl_intcon,5
	BRA	label268435784
; } main function end

	ORG 0x0000022A
_startup
	BCF CompGblVar32,0
	CLRF gbl_isthcopen
	CLRF gbl_5_tbuff
	CLRF gbl_5_tbuff+D'1'
	CLRF gbl_5_digit
	CLRF gbl_5_interrupt_timer
	CLRF gbl_5_interrupt_timer+D'1'
	MOVLW 0x40
	MOVWF gbl_map
	MOVLW 0x79
	MOVWF gbl_map+D'1'
	MOVLW 0x24
	MOVWF gbl_map+D'2'
	MOVLW 0x30
	MOVWF gbl_map+D'3'
	MOVLW 0x19
	MOVWF gbl_map+D'4'
	MOVLW 0x12
	MOVWF gbl_map+D'5'
	MOVLW 0x02
	MOVWF gbl_map+D'6'
	MOVLW 0x78
	MOVWF gbl_map+D'7'
	CLRF gbl_map+D'8'
	MOVLW 0x10
	MOVWF gbl_map+D'9'
	MOVLW 0x48
	MOVWF gbl_open
	MOVLW 0x06
	MOVWF gbl_open+D'1'
	MOVLW 0x0C
	MOVWF gbl_open+D'2'
	MOVLW 0x40
	MOVWF gbl_open+D'3'
	BCF CompGblVar33,1
	BCF CompGblVar34,2
	CLRF gbl_isthcopen
	BCF CompGblVar35,3
	BCF CompGblVar36,4
	GOTO	main
	ORG 0x0000027C
interrupt
; { interrupt ; function begin
	MOVFF FSR0H,  Int1Context
	MOVFF FSR0L,  Int1Context+D'1'
	MOVFF PRODH,  Int1Context+D'2'
	MOVFF PRODL,  Int1Context+D'3'
	BSF gbl_disoff_out,0
	CLRF gbl_tmr0l
	BCF gbl_intcon,2
	MOVLW 0x05
	CPFSGT gbl_5_digit
	BRA	label268435661
	CLRF gbl_5_digit
	CLRF gbl_portc
label268435661
	MOVLW 0x01
	MOVWF CompTempVar114
	MOVF gbl_5_digit, W
label268435669
	ANDLW 0xFF
	BZ	label268435670
	BCF STATUS,C
	RLCF CompTempVar114, F
	ADDLW 0xFF
	BRA	label268435669
label268435670
	MOVF CompTempVar114, W
	MOVWF gbl_portc
	MOVF gbl_5_tbuff+D'3', F
	BNZ	label268435671
	MOVF gbl_5_tbuff+D'2', F
	BNZ	label268435671
	MOVLW 0x0C
	MOVWF interrupt_1_mask
	BRA	label268435680
label268435671
	MOVF gbl_5_tbuff+D'3', F
	BNZ	label268435676
	MOVF gbl_5_tbuff+D'2', F
	BZ	label268435676
	MOVLW 0x08
	MOVWF interrupt_1_mask
	BRA	label268435680
label268435676
	CLRF interrupt_1_mask
label268435680
	MOVLW 0x04
	CPFSLT gbl_5_digit
	BRA	label268435682
	MOVLW 0x01
	MOVWF CompTempVar116
	MOVF gbl_5_digit, W
label268435688
	ANDLW 0xFF
	BZ	label268435689
	BCF STATUS,C
	RLCF CompTempVar116, F
	ADDLW 0xFF
	BRA	label268435688
label268435689
	MOVF interrupt_1_mask, W
	ANDWF CompTempVar116, W
	BZ	label268435690
	SETF gbl_portd
	BRA	label268435693
label268435690
	MOVLW	HIGH(gbl_5_tbuff)

	MOVWF	FSR0H
	MOVLW LOW(gbl_5_tbuff+D'0')
	MOVWF FSR0L
	MOVF gbl_5_digit, W
	ADDWF FSR0L, F
	MOVF INDF0, W
	MOVWF CompTempVar118
	MOVLW	HIGH(gbl_map)

	MOVWF	FSR0H
	MOVLW LOW(gbl_map+D'0')
	MOVWF FSR0L
	MOVF CompTempVar118, W
	ADDWF FSR0L, F
	DECF gbl_5_digit, W
	BNZ	label268435699
	CLRF CompTempVar121
	BRA	label268435701
label268435699
	MOVLW 0x80
	MOVWF CompTempVar121
label268435701
	MOVF CompTempVar121, W
	IORWF INDF0, W
	MOVWF gbl_portd
label268435693
	DECF gbl_isthcopen, W
	BNZ	label268435711
	MOVLW	HIGH(gbl_open)

	MOVWF	FSR0H
	MOVLW LOW(gbl_open+D'0')
	MOVWF FSR0L
	MOVF gbl_5_digit, W
	ADDWF FSR0L, F
	MOVF INDF0, W
	MOVWF gbl_portd
	BRA	label268435711
label268435682
	MOVLW 0x04
	CPFSEQ gbl_5_digit
	BRA	label268435707
	MOVLW 0x9C
	MOVWF gbl_portd
	BRA	label268435711
label268435707
	MOVLW 0x05
	CPFSEQ gbl_5_digit
	BRA	label268435711
	MOVLW 0xC6
	MOVWF gbl_portd
label268435711
	MOVLW 0x05
	MOVWF delay_100u_00000_arg_del
	CALL delay_100u_00000
	SETF gbl_portd
	INCF gbl_5_digit, F
	INFSNZ gbl_5_interrupt_timer, F
	INCF gbl_5_interrupt_timer+D'1', F
	BCF gbl_disoff_out,0
	MOVLW 0x01
	MOVWF delay_100u_00000_arg_del
	CALL delay_100u_00000
	BSF gbl_disoff_out,0
	MOVFF Int1Context+D'3',  PRODL
	MOVFF Int1Context+D'2',  PRODH
	MOVFF Int1Context+D'1',  FSR0L
	MOVFF Int1Context,  FSR0H
	RETFIE 1
; } interrupt function end

	ORG 0x00300002
	DW 0xFEFF
	END
