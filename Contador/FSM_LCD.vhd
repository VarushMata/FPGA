--------------------------------------------------------------------------------------------------------------
-- Este programa codifica el valor de los interruptores [SW7-SW0]
-- en el caracter ASCII para visualizarse en el LCD
--------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity LCD is
generic(
	M_I: STD_LOGIC_VECTOR(7 downto 0) := x"49";
	n: STD_LOGIC_VECTOR(7 downto 0) := x"6E";
	g: STD_LOGIC_VECTOR(7 downto 0) := x"67"; 
	e: STD_LOGIC_VECTOR(7 downto 0) := x"65"; 
	space: STD_LOGIC_VECTOR(7 downto 0) := x"20"; -- [space] 32
	s: STD_LOGIC_VECTOR(7 downto 0) := x"73"; -- C 67
	l: STD_LOGIC_VECTOR(7 downto 0) := x"6C"; -- I 73
	o: STD_LOGIC_VECTOR(7 downto 0) := x"6F"; -- I 73
	u: STD_LOGIC_VECTOR(7 downto 0) := x"75"; -- I 73
	r: STD_LOGIC_VECTOR(7 downto 0) := x"72"; -- I 73	
	d: STD_LOGIC_VECTOR(7 downto 0) := x"64"; -- [ 91
	c: STD_LOGIC_VECTOR(7 downto 0) := x"63"; -- I 73
	T1: STD_LOGIC_VECTOR(23 downto 0) := x"000FFF" -- espera de 81.9us
);
Port (
	CLOCK : in STD_LOGIC; --reloj de 50MHz
	REINI : in STD_LOGIC; --boton de reinicio a BTN0
	INICIA : in STD_LOGIC;
	LCD_RS : out STD_LOGIC; --del LCD (JC4)
	LCD_RW : out STD_LOGIC; --read/write del LCD (JC5)
	LCD_E : out STD_LOGIC; --enable del LCD (JC6)
	DATA : out STD_LOGIC_VECTOR (7 downto 0); --bus de datos de la LCD (JB10-7,4-1)
	UNI,DEC,CEN : in STD_LOGIC_VECTOR (3 downto 0)

);

end LCD;
architecture LCD of LCD is
-- FSM states
type STATE_TYPE is (
CONTROL,RST,ST0,ST1,FSET,EMSET,DO,CLD,RETH,SDDRAMA,WRITE1,WRITE2,
WRITE3,WRITE4,WRITE5,WRITE6,WRITE7,WRITE8,WRITE9,WRITE10,WRITE11,
WRITE12,WRITE13,WRITE14,WRITE15,SSDRAMA2,WRITE16,WRITE17,WRITE18,
WRITE19,WRITE20,WRITE21,WRITE22,SSDRAMA3,WRITE23,WRITE24,WRITE25);
-- seales
signal State,Next_State : STATE_TYPE;
signal CONT1 : STD_LOGIC_VECTOR(23 downto 0) := X"000000"; -- 16,777,216 = 0.33554432 s MAX
signal CONT2 : STD_LOGIC_VECTOR(4 downto 0) :="00000"; -- 32 = 0.64us
signal RESET : STD_LOGIC :='0';
signal READY : STD_LOGIC :='0';

-------------------
begin
-------------------------------------------------------------------
--Contador de Retardos CONT1--
process(CLOCK,RESET)
begin
	if RESET='1' then CONT1 <= (others => '0');
	elsif CLOCK'event and CLOCK='1' then CONT1 <= CONT1 + 1;
	end if;
end process;
-------------------------------------------------------------------
--Contador para Secuencias CONT2--
process(CLOCK,READY)
begin
	if CLOCK='1' and CLOCK'event then
		if READY='1' then CONT2 <= CONT2 + 1;
		else CONT2 <= "00000";
		end if;
	end if;
end process;
-------------------------------------------------------------------
--Actualizacin de estados--
process (CLOCK, Next_State)
begin
if CLOCK='1' and CLOCK'event then State <= Next_State;
end if;
end process;
-------------------------------------------------------------------
--FSM--
process(CONT1,CONT2,State,CLOCK,REINI)
begin
	if REINI = '1' THEN Next_State <= CONTROL;
	elsif CLOCK='0' and CLOCK'event then
	case State is
		when CONTROL =>
			LCD_RS<='0';
			LCD_RW<='0';
			LCD_E<='0';
			DATA<=X"00";
			if inicia = '1' then
				next_state <= RST;
			else
				next_state <= Control;
			end if;
		when RST => 
			if CONT1=X"000000"then 
				LCD_RS<='0';
				LCD_RW<='0';
				LCD_E<='0';
				DATA<=X"00";
				Next_State<=ST0;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=ST0;
			end if;
		when ST0 => 
			if CONT1=X"1312D0" then 
				READY<='1';
				DATA<=X"38"; 
				Next_State<=ST0;
			elsif CONT2>"00001" and CONT2<"01110" then
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=ST1;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=ST0;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); 
		when ST1 => 
			if CONT1=X"0035E8" then 
				READY<='1';
				DATA<=X"38"; 
				Next_State<=ST1;
			elsif CONT2>"00001" and CONT2<"01110" then 
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=FSET;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=ST1;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); 
		when FSET => 
			if CONT1=X"0007D0" then 
				READY<='1';
				DATA<=X"38"; 
				Next_State<=FSET;
			elsif CONT2>"00001" and CONT2<"01110" then
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=EMSET;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=FSET;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); 
		when EMSET => 
			if CONT1=X"0007D0" then 
				READY<='1';
				DATA<=X"06"; --000001-I/D-SH
				Next_State<=EMSET;
			elsif CONT2>"00001" and CONT2<"01110" then
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=DO;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=EMSET;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); 
		when DO => 
			if CONT1=X"0007D0" then 
				READY<='1';
				DATA<=X"0C"; 
				Next_State<=DO;
			elsif CONT2>"00001" and CONT2<"01110" then
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=CLD;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=DO;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); 
		when CLD => 
			if CONT1=X"0007D0" then
				READY<='1';
				DATA<=X"01"; 
				Next_State<=CLD;
			elsif CONT2>"00001" and CONT2<"01110" then
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=RETH;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=CLD;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); 
		when RETH => 
			if CONT1=X"0007D0" then 
				READY<='1';
				DATA<=X"02"; 
				Next_State<=RETH;
			elsif CONT2>"00001" and CONT2<"01110" then
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=SDDRAMA;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=RETH;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); 
		when SDDRAMA => 
			if CONT1=X"014050" then
				READY<='1';
				DATA<=X"80"; 
				Next_State<=SDDRAMA;
			elsif CONT2>"00001" and CONT2<"01110" then
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE1;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=SDDRAMA;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE1 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=M_I; --DATA<=x"53";
				Next_State<=WRITE1;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE2;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else	
				Next_State<=WRITE1;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE2 => --Write Data in DD RAM (i 69,  A1)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=n; --DATA<=x"69";
				Next_State<=WRITE2;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE3;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE2;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE3 => --Write Data in DD RAM (m 6D)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=g; --DATA<=x"6D";
				Next_State<=WRITE3;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE4;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE3;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE4 => --Write Data in DD RAM (b 62)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=r; --DATA<=x"62";
				Next_State<=WRITE4;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE5;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE4;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE5 => --Write Data in DD RAM (o 6F)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=e; --DATA<=x"6F";
				Next_State<=WRITE5;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE6;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE5;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE6 => --Write Data in DD RAM (l 6C)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=s; --DATA<=x"6C";
				Next_State<=WRITE6;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE7;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE6;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE7 => --Write Data in DD RAM (o 6F)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=e; --DATA<=x"6F";
				Next_State<=WRITE7;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE8;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE7;
			end if;
				RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE8 => --Write Data in DD RAM (s 73)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=space; --DATA<=x"73";
				Next_State<=WRITE8;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE9;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE8;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE9 => --Write Data in DD RAM (space 20)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=d; --DATA<=x"20";
				Next_State<=WRITE9;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE10;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE9;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE10 => --Write Data in DD RAM (A 41)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=u; --DATA<=X"41";
				Next_State<=WRITE10;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE11;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE10;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE11 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=l; --DATA<=X"53";
				Next_State<=WRITE11;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE12;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE11;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE12 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=c; --DATA<=X"53";
				Next_State<=WRITE12;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE13;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE12;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE13 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=e; --DATA<=X"53";
				Next_State<=WRITE13;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE14;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE13;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE14 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=s; --DATA<=X"53";
				Next_State<=WRITE14;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE15;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE14;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE15 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=l; --DATA<=X"53";
				Next_State<=WRITE15;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=SSDRAMA2;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE15;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when SSDRAMA2 => --Write Data in DD RAM (S 53)
			if CONT1=x"014050" then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"C0"; --DATA<=X"53";
				Next_State<=SSDRAMA2;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE16;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=SSDRAMA2;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE16 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"44"; --DATA<=X"53";
				Next_State<=WRITE16;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE17;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE16;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE17 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"55"; --DATA<=X"53";
				Next_State<=WRITE17;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE18;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE17;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1
		when WRITE18 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"4C"; --DATA<=X"53";
				Next_State<=WRITE18;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE19;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE18;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1
		when WRITE19 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"43"; --DATA<=X"53";
				Next_State<=WRITE19;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE20;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE19;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1
		when WRITE20 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"45"; --DATA<=X"53";
				Next_State<=WRITE20;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE21;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE20;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1
		when WRITE21 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"53"; --DATA<=X"53";
				Next_State<=WRITE21;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE22;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE21;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1
		when WRITE22 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"3A"; --DATA<=X"53";
				Next_State<=WRITE22;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=SSDRAMA3;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE22;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1
		when SSDRAMA3 => --Write Data in DD RAM (S 53)
			if CONT1=x"014050" then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"CA"; --DATA<=X"53";
				Next_State<=SSDRAMA3;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE23;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=SSDRAMA3;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
		when WRITE23 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"00" or CEN; --DATA<=X"53";
				Next_State<=WRITE23;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE24;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE23;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1
		when WRITE24 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"00" or DEC;--DATA<=X"53";
				Next_State<=WRITE24;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=WRITE25;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE24;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1
		when WRITE25 => --Write Data in DD RAM (S 53)
			if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000
				READY<='1';
				LCD_RS<='1';
				DATA<=x"00" or UNI; --DATA<=X"53";
				Next_State<=WRITE25;
			elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns
				LCD_E<='1';
			elsif CONT2="1111" then
				READY<='0';
				LCD_E<='0';
				Next_State<=SSDRAMA3;
			elsif inicia = '0' then
				next_state <= CONTROL;
			else
				Next_State<=WRITE25;
			end if;
			RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1
	end case;
end if;

end process; --FIN DEL PROCESO DE LA MQUINA DE ESTADOS
end LCD; --FIN DE LA ARQUITECTURA
