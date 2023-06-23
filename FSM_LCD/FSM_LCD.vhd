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
M_H: STD_LOGIC_VECTOR(7 downto 0) := x"48";
e: STD_LOGIC_VECTOR(7 downto 0) := x"65";
l: STD_LOGIC_VECTOR(7 downto 0) := x"6C"; 
o: STD_LOGIC_VECTOR(7 downto 0) := x"6F"; 
space: STD_LOGIC_VECTOR(7 downto 0) := x"20"; -- [space] 32
M_W: STD_LOGIC_VECTOR(7 downto 0) := x"57"; -- C 67
r: STD_LOGIC_VECTOR(7 downto 0) := x"72"; -- I 73
d: STD_LOGIC_VECTOR(7 downto 0) := x"64"; -- [ 91
T1: STD_LOGIC_VECTOR(23 downto 0) := x"000FFF" -- espera de 81.9us
);
Port (
CLOCK : in STD_LOGIC; --reloj de 50MHz
REINI : in STD_LOGIC; --boton de reinicio a BTN0
INICIA : in STD_LOGIC;
LCD_RS : out STD_LOGIC; --del LCD (JC4)
LCD_RW : out STD_LOGIC; --read/write del LCD (JC5)
LCD_E : out STD_LOGIC; --enable del LCD (JC6)
DATA : out STD_LOGIC_VECTOR (7 downto 0) --bus de datos de la LCD (JB10-7,4-1)

);

end LCD;
architecture LCD of LCD is
-- FSM states
type STATE_TYPE is (
CONTROL,RST,ST0,ST1,FSET,EMSET,DO,CLD,RETH,SDDRAMA,WRITE1,WRITE2,
WRITE3,WRITE4,WRITE5,WRITE6,WRITE7,WRITE8,WRITE9,WRITE10,
WRITE11);
-- señales
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
--Actualización de estados--
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
		if inicia = '0' then
			next_state <= RST;
		else
			LCD_RS<='0';
			LCD_RW<='0';
			LCD_E<='0';
			DATA<=X"00";
			next_state <= Control;
		end if;
	when RST => 
		if CONT1=X"000000"then 
			LCD_RS<='0';
			LCD_RW<='0';
			LCD_E<='0';
			DATA<=X"00";
			Next_State<=ST0;
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

	else

	Next_State<=SDDRAMA;

end if;
RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

---------------------------------------------------------------------------------------
--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--DATOS--
---------------------------------------------------------------------------------------
when WRITE1 => --Write Data in DD RAM (S 53)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';
LCD_RS<='1';
DATA<=M_H; --DATA<=x"53";
Next_State<=WRITE1;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then
READY<='0';
LCD_E<='0';
Next_State<=WRITE2;

else

Next_State<=WRITE1;

end if;
RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
when WRITE2 => --Write Data in DD RAM (i 69, í A1)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';
LCD_RS<='1';
DATA<=e; --DATA<=x"69";
Next_State<=WRITE2;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then
READY<='0';
LCD_E<='0';
Next_State<=WRITE3;


else

Next_State<=WRITE2;

end if;

RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
when WRITE3 => --Write Data in DD RAM (m 6D)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';
LCD_RS<='1';
DATA<=l; --DATA<=x"6D";
Next_State<=WRITE3;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then
READY<='0';
LCD_E<='0';
Next_State<=WRITE4;

else

Next_State<=WRITE3;

end if;
RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
when WRITE4 => --Write Data in DD RAM (b 62)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';
LCD_RS<='1';
DATA<=l; --DATA<=x"62";
Next_State<=WRITE4;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then
READY<='0';
LCD_E<='0';
Next_State<=WRITE5;

else

Next_State<=WRITE4;

end if;
RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
when WRITE5 => --Write Data in DD RAM (o 6F)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';
LCD_RS<='1';
DATA<=o; --DATA<=x"6F";
Next_State<=WRITE5;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then

READY<='0';
LCD_E<='0';
Next_State<=WRITE6;

else

Next_State<=WRITE5;

end if;
RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
when WRITE6 => --Write Data in DD RAM (l 6C)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';
LCD_RS<='1';
DATA<=space; --DATA<=x"6C";
Next_State<=WRITE6;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then
READY<='0';
LCD_E<='0';
Next_State<=WRITE7;

else

Next_State<=WRITE6;

end if;
RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
when WRITE7 => --Write Data in DD RAM (o 6F)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';
LCD_RS<='1';
DATA<=M_W; --DATA<=x"6F";
Next_State<=WRITE7;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then
READY<='0';
LCD_E<='0';
Next_State<=WRITE8;

else

Next_State<=WRITE7;

end if;
RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
when WRITE8 => --Write Data in DD RAM (s 73)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';

LCD_RS<='1';
DATA<=o; --DATA<=x"73";
Next_State<=WRITE8;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then
READY<='0';
LCD_E<='0';
Next_State<=WRITE9;

else

Next_State<=WRITE8;

end if;
RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
when WRITE9 => --Write Data in DD RAM (space 20)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';
LCD_RS<='1';
DATA<=r; --DATA<=x"20";
Next_State<=WRITE9;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then
READY<='0';
LCD_E<='0';
Next_State<=WRITE10;

else

Next_State<=WRITE9;

end if;
RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
when WRITE10 => --Write Data in DD RAM (A 41)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';
LCD_RS<='1';
DATA<=l; --DATA<=X"41";
Next_State<=WRITE10;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then
READY<='0';
LCD_E<='0';
Next_State<=WRITE11;

else

Next_State<=WRITE10;

end if;

RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0
when WRITE11 => --Write Data in DD RAM (S 53)
if CONT1=T1 then -- estado de espera por 0.335s X"FFFFFF"=750,000

READY<='1';
LCD_RS<='1';
DATA<=d; --DATA<=X"53";
Next_State<=WRITE11;

elsif CONT2>"00001" and CONT2<"01110" then--rango de 12*20ns=240ns

LCD_E<='1';
elsif CONT2="1111" then
READY<='0';
LCD_E<='0';
Next_State<=RST;

else

Next_State<=WRITE11;

end if;
RESET<= CONT2(0)and CONT2(1)and CONT2(2)and CONT2(3); -- CONT1 = 0

end case;
end if;
end process; --FIN DEL PROCESO DE LA MÁQUINA DE ESTADOS
end LCD; --FIN DE LA ARQUITECTURA